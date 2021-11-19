% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% License CC BY 4.0
% https://github.com/BZandi/Spectral-Optimisation

function [x, fval, exitflag, output, last_population, scores] = runOptim_GA(qp, num_channels, population_size, max_iter, max_time, last_pop, scores)

% Add folder to path
addpath("A01_Methods")
addpath("A00_Data")

% Create an object for the luminaire to caluclate the spectra from code values
LumObject = Luminaire();

% Create an object of the metrics class to calculate the metrics from the spectra
MetricsObject = MetricsClass();

% Define upper and lower boundaries for the optimisation
problem.nvars = num_channels;
problem.lb = zeros(1,num_channels);
problem.ub = ones(1,num_channels);

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

    function [F] = myObjectives(X)
        
        CurrentSpectra = LumObject.get_CH15Spec_Vec(X);
        Metrics = MetricsObject.getMetrics_Vec(CurrentSpectra);
                
        F(:, 1) = abs(Metrics.Luminance - qp(1));
        F(:, 2) = abs(Metrics.CIEx_1931_2 - qp(2));
        F(:, 3) = abs(Metrics.CIEy_1931_2 - qp(3));
    end

    function [state, options, optchanged] = myOutputFunction(options, state, flag)
        % Example of a output function can created using "edit gaoutputfcntemplate" in matlab
        persistent h1 history r
        optchanged = false;
        switch flag
            case 'iter'
                % Find the best objective function, and stop if it is low.
                [states, num_cvs] = size(state.Population);
                tolerance = [0.1, 0.0001, 0.0001];
                
                % below = any(all(state.Score < tolerance, 2));
                FoundOptimisationResult = find((state.Score(:,1) < tolerance(1)) &...
                    (state.Score(:,2) < tolerance(2)) &...
                    (state.Score(:,3) < tolerance(3)));
                
                % Stop the optimisation process before when more than 2 results were found
                if size(FoundOptimisationResult, 1) > 20
                    state.StopFlag = 'y';
                    disp('Spectral optimisation terminated.')
                    disp(['Number of found solutions: ' num2str(size(FoundOptimisationResult, 1))])
                end
        end
    end
end