% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

function [Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging)

% Add global values ===========================
clear global;

global tolerance_GA;
tolerance_GA = tolerance;

global logging_global;
logging_global = Logging;

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
    
    LCone10_Tolerance_Buffer = tolerance(1);
    MCone_10_Tolerance_Buffer = tolerance(2);
    SCone_10_Tolerance_Buffer = tolerance(3);
    Rod_Tolerance_Buffer = tolerance(4);
    Melanopic_Tolerance_Buffer = tolerance(5);
end

global NumIteration;
InitialPopSize_Buffer = population_size;
global NumSol_Buffer; % Number of found solutions that meet the criteria
global Population_Archiv_Buffer;
global IterTime_Buffer;
IterTime_Buffer = [];
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

if Logging == 1
    MetricsObject_LuxPy = MetricsClass_LuxPy(); % Caution: read Matlab/A01_Methods/MetricsClass_LuxPy.m before using.
end

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

tStart = tic;
TStart_Global_PosiXTime = posixtime(datetime('now'));
[x,fval,exitflag,output,last_population,scores] = gamultiobj(problem);

TotalOptimTime_Seconds = toc(tStart);

% Combine the logging values =====================================================================
% ================================================================================================
% ================================================================================================

fprintf('Optimisation is done. Total duration [min]: %d \n', round(TotalOptimTime_Seconds/60, 2))

if Logging == 1
    disp('Begin to process the log data...')
    
    % Two logging values are needed:
    % 1) The first table holds the optimised population with the respective metrics for each iteration
    % 2) The second table is a summary of each iteration
    
    OptimSummaryTable = table(NumIteration', 'VariableNames', {'NumIteration'});
    OptimSummaryTable.ObjectiveClass_Buffer(:) = cellstr(ObjectiveClass_Buffer);
    OptimSummaryTable.OptimiserClass_Buffer(:) = OptimiserClass_Buffer;
    OptimSummaryTable.InitialPopSize_Buffer(:) = InitialPopSize_Buffer;
    
    if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
        OptimSummaryTable.Luminance_Target(:) = Luminance_Target_Buffer;
        OptimSummaryTable.CIEx_1931_2_Target(:) = CIEx_1931_2_Target_Buffer;
        OptimSummaryTable.CIEy_1931_2_Target(:) = CIEy_1931_2_Target_Buffer;
        
        OptimSummaryTable.CIEx_1931_2_Tolerance(:) = CIEx_1931_2_Tolerance_Buffer;
        OptimSummaryTable.CIEy_1931_2_Tolerance(:) = CIEy_1931_2_Tolerance_Buffer;
        OptimSummaryTable.Luminance_Tolerance(:) = Luminance_Tolerance_Buffer;
        
    elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
        OptimSummaryTable.Luminance_Target(:) = Luminance_Target_Buffer;
        OptimSummaryTable.CIEu_1976_2_Target(:) = CIEu_1976_2_Target_Buffer;
        OptimSummaryTable.CIEv_1976_2_Target(:) = CIEv_1976_2_Target_Buffer;
        
        OptimSummaryTable.CIEu_1976_2_Tolerance(:) = CIEu_1976_2_Tolerance_Buffer;
        OptimSummaryTable.CIEv_1976_2_Tolerance(:) = CIEv_1976_2_Tolerance_Buffer;
        OptimSummaryTable.Luminance_Tolerance(:) = Luminance_Tolerance_Buffer;
        
    elseif strcmp(ObjectiveClass, 'Receptorsignals')
        OptimSummaryTable.LCone10_Target(:) = LCone10_Target_Buffer;
        OptimSummaryTable.MCone_10_Target(:) = MCone_10_Target_Buffer;
        OptimSummaryTable.SCone_10_Target(:) = SCone_10_Target_Buffer;
        OptimSummaryTable.Rod_Target(:) = Rod_Target_Buffer;
        OptimSummaryTable.Melanopic(:) = Melanopic_Target_Buffer;
        
        OptimSummaryTable.LCone10_Tolerance(:) = LCone10_Tolerance_Buffer;
        OptimSummaryTable.MCone_10_Tolerance(:) = MCone_10_Tolerance_Buffer;
        OptimSummaryTable.SCone_10_Tolerance(:) = SCone_10_Tolerance_Buffer;
        OptimSummaryTable.Rod_Tolerance(:) = Rod_Tolerance_Buffer;
        OptimSummaryTable.Melanopic_Tolerance(:) = Melanopic_Tolerance_Buffer;
    end
    
    OptimSummaryTable.numberSpectraThreshold(:) = numberSpectraThreshold_GA;
    OptimSummaryTable.NumSol(:) = NumSol_Buffer;
    OptimSummaryTable.Metameric_Tuning_MelEDI(:) = 0;
    OptimSummaryTable.Metameric_Tuning_MelEDI_Rf85(:) = 0;
    OptimSummaryTable.Metameric_Tuning_MelEDI_Rf90(:) = 0;
    
    IterTime_Buffer(1:3) = []; % First three time values are not valid for logging
    IterTime_Buffer = [IterTime_Buffer; TotalOptimTime_Seconds]; % Add last runtime cycle
    OptimSummaryTable.IterOptimTime_Seconds = IterTime_Buffer;
    OptimSummaryTable.TotalOptimTime_Seconds(:) = TotalOptimTime_Seconds;
    
    for i = 1:length(fieldnames(Population_Archiv_Buffer))
        
        CurrentData = Population_Archiv_Buffer.(['Iteration_' num2str(i)]);
        
        if Lum == 15
            CurrentSpectra = LumObject.get_CH15Spec_Vec(CurrentData);
            CurrentMetrics = MetricsObject.getMetrics_Vec(CurrentSpectra);
            CurrentTable = array2table(CurrentData);
            CurrentTable.Properties.VariableNames = {'CH_1' 'CH_2' 'CH_3' 'CH_4' 'CH_5' 'CH_6'...
                'CH_7' 'CH_8' 'CH_9' 'CH_10' 'CH_11' 'CH_12' 'CH_13' 'CH_14' 'CH_15'};
            
        elseif Lum == 11
            CurrentSpectra = LumObject.get_CH11Spec_Vec(CurrentData);
            CurrentMetrics = MetricsObject.getMetrics_Vec(CurrentSpectra);
            CurrentTable = array2table(CurrentData);
            CurrentTable.Properties.VariableNames = {'CH_1' 'CH_2' 'CH_3' 'CH_4' 'CH_5' 'CH_6'...
                'CH_7' 'CH_8' 'CH_9' 'CH_10' 'CH_11'};
        end
        
        CurrentTable = [CurrentTable,...
            CurrentMetrics(:,8),... % Luminance
            CurrentMetrics(:,7),... % MelanopicEDI
            CurrentMetrics(:,12),... % CIEu_1976_2
            CurrentMetrics(:,13),... % CIEv_1976_2
            CurrentMetrics(:,16),... % CIEx_1931_2
            CurrentMetrics(:,17),... % CIEy_1931_2
            CurrentMetrics(:,2),... % SCone_10
            CurrentMetrics(:,3),... % MCone_10
            CurrentMetrics(:,4),... % LCone10
            CurrentMetrics(:,5),... % Rod
            CurrentMetrics(:,6),... % Melanopic
            ];
        
        CurrentTable.Properties.VariableNames{'Luminance'} = 'Luminance_Actual';
        CurrentTable.Properties.VariableNames{'MelanopicEDI'} = 'MelanopicEDI_Actual';
        CurrentTable.Properties.VariableNames{'CIEu_1976_2'} = 'CIEu_1976_2_Actual';
        CurrentTable.Properties.VariableNames{'CIEv_1976_2'} = 'CIEv_1976_2_Actual';
        CurrentTable.Properties.VariableNames{'CIEx_1931_2'} = 'CIEx_1931_2_Actual';
        CurrentTable.Properties.VariableNames{'CIEy_1931_2'} = 'CIEy_1931_2_Actual';
        CurrentTable.Properties.VariableNames{'SCone_10'} = 'SCone_10_Actual';
        CurrentTable.Properties.VariableNames{'MCone_10'} = 'MCone_10_Actual';
        CurrentTable.Properties.VariableNames{'LCone10'} = 'LCone10_Actual';
        CurrentTable.Properties.VariableNames{'Rod'} = 'Rod_Actual';
        CurrentTable.Properties.VariableNames{'Melanopic'} = 'Melanopic_Actual';
        
        CurrentTable.ChannelNumber(:) = Lum;
        
        CurrentMetrics_LuxPy = MetricsObject_LuxPy.getMetrics_Vec(CurrentSpectra);
        CurrentTable.Duv_Actual = CurrentMetrics_LuxPy.Duv;
        CurrentTable.CRI_Ra_Actual = CurrentMetrics_LuxPy.CRI_Ra;
        CurrentTable.Rf_TM30_Actual = CurrentMetrics_LuxPy.Rf_TM30;
        CurrentTable.Rg_TM30_Actual = CurrentMetrics_LuxPy.Rg_TM30;
        CurrentTable.Rfh1_TM30_Actual = CurrentMetrics_LuxPy.Rfh1_TM30;
        
        if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
            CurrentTable.Delta_Luminance = abs(CurrentTable.Luminance_Actual - Luminance_Target_Buffer);
            CurrentTable.Delta_CIEx_1931_2 = abs(CurrentTable.CIEx_1931_2_Actual - CIEx_1931_2_Target_Buffer);
            CurrentTable.Delta_CIEy_1931_2 = abs(CurrentTable.CIEy_1931_2_Actual - CIEy_1931_2_Target_Buffer);
            
            OptimisationResult_Index_Buffer = (CurrentTable.Delta_Luminance < Luminance_Tolerance_Buffer) &...
                (CurrentTable.Delta_CIEx_1931_2 < CIEx_1931_2_Tolerance_Buffer) &...
                (CurrentTable.Delta_CIEy_1931_2 < CIEy_1931_2_Tolerance_Buffer);
            
            CurrentTable.ValidSol = OptimisationResult_Index_Buffer;
            
        elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
            CurrentTable.Delta_Luminance = abs(CurrentTable.Luminance_Actual - Luminance_Target_Buffer);
            CurrentTable.Delta_CIEu_1976_2 = abs(CurrentTable.CIEu_1976_2_Actual - CIEu_1976_2_Target_Buffer);
            CurrentTable.Delta_CIEv_1976_2 = abs(CurrentTable.CIEv_1976_2_Actual - CIEv_1976_2_Target_Buffer);
            
            OptimisationResult_Index_Buffer = (CurrentTable.Delta_Luminance < Luminance_Tolerance_Buffer) &...
                (CurrentTable.Delta_CIEu_1976_2 < CIEu_1976_2_Tolerance_Buffer) &...
                (CurrentTable.Delta_CIEv_1976_2 < CIEv_1976_2_Tolerance_Buffer);
            
            CurrentTable.ValidSol = OptimisationResult_Index_Buffer;
            
        elseif strcmp(ObjectiveClass, 'Receptorsignals')
            CurrentTable.Delta_LCone10 = abs(CurrentTable.LCone10_Actual - LCone10_Target_Buffer);
            CurrentTable.Delta_MCone_10 = abs(CurrentTable.MCone_10_Actual - MCone_10_Target_Buffer);
            CurrentTable.Delta_SCone_10 = abs(CurrentTable.SCone_10_Actual - SCone_10_Target_Buffer);
            CurrentTable.Delta_Rod = abs(CurrentTable.Rod_Actual - Rod_Target_Buffer);
            CurrentTable.Delta_Melanopic = abs(CurrentTable.Melanopic_Actual - Melanopic_Target_Buffer);
            
            OptimisationResult_Index_Buffer = (CurrentTable.Delta_LCone10 < LCone10_Tolerance_Buffer) &...
                (CurrentTable.Delta_MCone_10 < MCone_10_Tolerance_Buffer) &...
                (CurrentTable.Delta_SCone_10 < SCone_10_Tolerance_Buffer) &...
                (CurrentTable.Delta_Rod < Rod_Tolerance_Buffer) &...
                (CurrentTable.Delta_Melanopic < Melanopic_Tolerance_Buffer);
            
            CurrentTable.ValidSol = OptimisationResult_Index_Buffer;
        end
        
        % If at least two solutions are in the iteration, then calc the metameric contrast of the melanopicEDI
        if size(find(CurrentTable.ValidSol),1) >= 2
            
            % Metameric difference without any colour fidelity condition
            ValidSolution_Table = CurrentTable(find(CurrentTable.ValidSol), :);
            OptimSummaryTable.Metameric_Tuning_MelEDI(i) = max(ValidSolution_Table.MelanopicEDI_Actual)-min(ValidSolution_Table.MelanopicEDI_Actual);
            
            % Metameric difference using a colour fidelity condition of Rf >= 85
            ValidSolution_Table_Rf85 = ValidSolution_Table(ValidSolution_Table.Rf_TM30_Actual >= 85,:);          
            if size(ValidSolution_Table_Rf85, 1) >=2
                OptimSummaryTable.Metameric_Tuning_MelEDI_Rf85(i) = max(ValidSolution_Table_Rf85.MelanopicEDI_Actual)-min(ValidSolution_Table_Rf85.MelanopicEDI_Actual);
            end
            
            % Metameric difference using a colour fidelity condition of Rf >= 90
            ValidSolution_Table_Rf90 = ValidSolution_Table(ValidSolution_Table.Rf_TM30_Actual >= 90,:);          
            if size(ValidSolution_Table_Rf90, 1) >=2
                OptimSummaryTable.Metameric_Tuning_MelEDI_Rf90(i) = max(ValidSolution_Table_Rf90.MelanopicEDI_Actual)-min(ValidSolution_Table_Rf90.MelanopicEDI_Actual);
            end
        end
        
        % Save caluclations of the current round
        Population_Archiv_Buffer.(['Iteration_' num2str(i)]) = CurrentTable;
        fprintf('Logging step [%d / %d] is finished. \n', i, length(fieldnames(Population_Archiv_Buffer)))
        
    end
    
    Logging_PopulationArchiv = Population_Archiv_Buffer;
    Logging_OptimSummary = OptimSummaryTable;
    disp('Log data created.')
    
else
    Logging_PopulationArchiv = [];
    Logging_OptimSummary = [];
    
end

clear global;

% ============================================================================================
% ============================================================================================
% ============================================================================================

    function [F] = myObjectives(X)
        
        if Logging == 1
        CurrentTime = posixtime(datetime('now'));
        IterTime_Buffer = [IterTime_Buffer;CurrentTime-TStart_Global_PosiXTime];
        end
        
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
                if size(FoundOptimisationResult, 1) >= numberSpectraThreshold_GA
                    state.StopFlag = 'y';
                    disp('Spectral optimisation terminated.')
                    disp(['Number of found solutions: ' num2str(size(FoundOptimisationResult, 1))])
                end
                
                if logging_global == 1
                    % Protocoll of the optimisation ==========================================
                    NumIteration(state.Generation) = state.Generation;
                    NumSol_Buffer(state.Generation) = size(FoundOptimisationResult, 1);
                    Population_Archiv_Buffer.(['Iteration_' num2str(state.Generation)]) = state.Population;
                    % ========================================================================
                end
        end
    end
end