% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% License GNU GPLv3
% https://github.com/BZandi/Spectral-Optimisation

function [x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores)

% Add global values ===========================
global tolerance_GA;
tolerance_GA = tolerance;

global numberSpectraThreshold_GA
numberSpectraThreshold_GA = NumberSpectra;
% =============================================

% Protocoll Values ============================
if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
    CIEx_1931_2_Target_Buffer = qp(2);
    CIEy_1931_2_Target_Buffer = qp(3);
    Luminance_Target_Buffer = qp(1);
    
    CIEx_1931_2_Tolerance_Buffer = tolerance(2);
    CIEy_1931_2_Tolerance_Buffer = tolerance(3);
    Luminance_Tolerance_Buffer = tolerance(1);
    
elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
    CIEu_1976_2_Target_Buffer = qp(2);
    CIEv_1976_2_Target_Buffer = qp(3);
    Luminance_Target_Buffer = qp(1);
    
    CIEu_1976_2_Tolerance_Buffer = tolerance(2);
    CIEv_1976_2_Tolerance_Buffer = tolerance(3);
    Luminance_Tolerance_Buffer = tolerance(1);
    
elseif strcmp(ObjectiveClass, 'Receptorsignals')
    LCone10_Target_Buffer = qp(1);
    MCone_10_Target_Buffer = qp(2);
    SCone_10_Target_Buffer = qp(3);
    Rod_Target_Buffer = qp(4);
    Melanopic_Target_Buffer = qp(5);
end

StartTime = posixtime(datetime('now'));
global NumIteration
InitialPopSize_Buffer = population_size;
global NumSol_Buffer % Number of found solutions that meet the criteria
global Metameric_Delta_MelEDI_Buffer
TotalOptimTime_Seconds_Buffer = [];
ObjectiveClass_Buffer = ObjectiveClass;
OptimiserClass_Buffer = {'MuliObjGA'};

% =============================================


% Add folder to path
addpath("A01_Methods")
addpath("A00_Data")

if Lum == 15
    % Create an object for the luminaire to caluclate the spectra from code values
    LumObject = Luminaire();
elseif Lum == 11
    LumObject = Luminaire_CH11();
end

% Create an object of the metrics class to calculate the metrics from the spectra
MetricsObject = MetricsClass();

% Define upper and lower boundaries for the optimisation
problem.nvars = num_channels;
problem.lb = zeros(1,num_channels);

if Lum == 15
    problem.ub = ones(1,num_channels);
elseif Lum == 11
    problem.ub = repmat(1.023, 1, num_channels);
end

% The optimisation follows a linear equation of  A*b=x
problem.Aeq = [];
problem.beq = [];

% Set the name of the solver
problem.solver = 'gamultiobj';
problem.options = optimoptions('gamultiobj');

% Define the output function, which is used for checking the tolerances
problem.options = optimoptions(problem.options, 'OutputFcn', @myOutputFunction);

% Define the objectives
problem.fitnessfcn = @myObjectives;

% Adjust if the optimisation should run in parallel or not: true or false
% When using UseVectorized than this should be set to false
problem.options = optimoptions(problem.options, 'UseParallel', false);

% As the metrics and luminaire class is vectorised it can be set to true
problem.options = optimoptions(problem.options, 'UseVectorized', true);

% The PopulationSize defines the size of the starting values
problem.options = optimoptions(problem.options, 'PopulationSize', population_size);

% Define the type of population: 'double','doubleVector','bitstring', 'custom'
problem.options = optimoptions(problem.options, 'PopulationType', 'doubleVector');

% Output options: 'final','off', 'iter', 'diagnose'
problem.options = optimoptions(problem.options, 'Display', 'iter');

% How to proceed with the crosover: 'crossoverintermediate', 'crossoverheuristic'
% 'crossoversinglepoint', 'crossovertwopoint', 'crossoverarithmetic'
problem.options = optimoptions(problem.options, 'CrossoverFcn', 'crossoverheuristic');

% checks if new population has to be initialized
if ~isnan(last_pop)
    problem.options = optimoptions(problem.options, 'InitialPopulation', last_pop);
    problem.options = optimoptions(problem.options, 'InitialPopulationMatrix', last_pop);
    problem.options = optimoptions(problem.options, 'InitialScoresMatrix', scores);
else
    % Create initial population: 'gacreationuniform', 'gacreationlinearfeasible', 'gacreationlinearfeasible'
    problem.options = optimoptions(problem.options, 'CreationFcn', 'gacreationuniform');
end

% The constrain tolerance can be set to zero as we use a custom tolerance checker
problem.options = optimoptions(problem.options, 'ConstraintTolerance', 0);

% Fraction of the best results without in the next generation
problem.options = optimoptions(problem.options, 'CrossoverFraction', 0.8);

% Stopping the optimisation if
problem.options = optimoptions(problem.options, 'MaxGenerations', max_iter);
problem.options = optimoptions(problem.options, 'MaxStallGenerations', Inf);
problem.options = optimoptions(problem.options, 'MaxTime', max_time);

[x,fval,exitflag,output,last_population,scores] = gamultiobj(problem);

% TODO:
% Saving an optimsation report during the caluclation.
% Which information could be needed:
% Two types of tables are needed
% 1) The first table holds the optimised population with the respective metrics for each iteration
% 2) The second table is a summary of each iteration with the following information

    function [F] = myObjectives(X)
        
        if Lum == 15
            CurrentSpectra = LumObject.get_CH15Spec_Vec(X);
        elseif Lum == 11
            CurrentSpectra = LumObject.get_CH11Spec_Vec(X);
        end
        
        Metrics = MetricsObject.getMetrics_Vec(CurrentSpectra);
        
        if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
            F(:, 1) = abs(Metrics.Luminance - qp(1));
            F(:, 2) = abs(Metrics.CIEx_1931_2 - qp(2));
            F(:, 3) = abs(Metrics.CIEy_1931_2 - qp(3));
            
        elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
            F(:, 1) = abs(Metrics.Luminance - qp(1));
            F(:, 2) = abs(Metrics.CIEu_1976_2 - qp(2));
            F(:, 3) = abs(Metrics.CIEv_1976_2 - qp(3));
            
        elseif strcmp(ObjectiveClass, 'Receptorsignals')
            F(:, 1) = abs(Metrics.LCone10 - qp(1));
            F(:, 2) = abs(Metrics.MCone_10 - qp(2));
            F(:, 3) = abs(Metrics.SCone_10 - qp(3));
            F(:, 4) = abs(Metrics.Rod - qp(4));
            F(:, 5) = abs(Metrics.Melanopic - qp(5));
        end
        
    end

    function [state, options, optchanged] = myOutputFunction(options, state, flag)
        % Example of a output function can created using "edit gaoutputfcntemplate" in matlab
        optchanged = false;
        switch flag
            case 'iter'
                % Find the best objective function, and stop if it is low.
                [states, num_cvs] = size(state.Population);
                
                % Check how many solutions where found
                if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
                    FoundOptimisationResult = find((state.Score(:,1) < tolerance(1)) &...
                        (state.Score(:,2) < tolerance(2)) &...
                        (state.Score(:,3) < tolerance(3)));
                    
                elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
                    FoundOptimisationResult = find((state.Score(:,1) < tolerance(1)) &...
                        (state.Score(:,2) < tolerance(2)) &...
                        (state.Score(:,3) < tolerance(3)));
                    
                elseif strcmp(ObjectiveClass, 'Receptorsignals')
                    FoundOptimisationResult = find((state.Score(:,1) < tolerance(1)) &...
                        (state.Score(:,2) < tolerance(2)) &...
                        (state.Score(:,3) < tolerance(3)) &...
                        (state.Score(:,4) < tolerance(4)) &...
                        (state.Score(:,5) < tolerance(5)));
                end
                
                % Stop the optimisation process before when more than 2 results were found
                if size(FoundOptimisationResult, 1) > numberSpectraThreshold_GA
                    state.StopFlag = 'y';
                    disp('Spectral optimisation terminated.')
                    disp(['Number of found solutions: ' num2str(size(FoundOptimisationResult, 1))])
                end
                
                % Protocoll of the optimisation ==========================================
                NumIteration(state.Generation) = state.Generation;
                NumSol_Buffer(state.Generation) = size(FoundOptimisationResult, 1);
                % ========================================================================
        end
    end
end