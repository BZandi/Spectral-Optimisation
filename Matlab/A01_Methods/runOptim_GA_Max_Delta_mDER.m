% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% In this script the metameric melanopic EDI difference is maximised, while the
% pre-defined objectives of chromaticity coordinate and luminance are used as constraints.

% Note that previously the runOptim_GA.m scripts needs to be runed
% to retreive pre-optimised code values

% !!CAUTION !! : This script is currently under development

% ToDo list:
% 1) the logging function needs to be added
% 2) add also the possibility for optimising CIEu'v' code values
% 3) Extent myOutputFunction()

% Example how to call this method:
% ========================================================
% ========================================================
% ========================================================

% qp = [220, 0.4483, 0.4480];
% % Tolerances for the objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
% tolerance = [0.5, 0.0001, 0.0001];
% Lum = 11; % We use a 11-channel LED luminiare
% num_channels = 11; % We use a 11-channel LED luminiare
% population_size = 3000; % Size of the initial population
% max_iter = 100; % Count of iterations (Generations) of the optimisation
% max_time = 200400; % Maximum optimisation time in seconds
% last_pop = [];
% scores = [];
% ObjectiveClass = 'Luminance_CIExy_1931_2'; % Can also be 'Luminance_CIEuv_1976_2' or 'Receptorsignals'
% 
% % Stoping criterium can also be the number of found spectra
% % Break if you find this number of spectra
% NumberSpectra = 5000;
% 
% % Indicate if you wish to log the results: 1->true, 0->false
% % Caution: logging is very time consuming
% Logging = 0;
% 
% % Run the optimisation
% % Note that you need to adjust the tolerances in the myOutputFunction() inside
% % the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.5, 0.0001, 0.0001]"
% [Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
%     num_channels, population_size, max_iter, max_time, last_pop, scores, Logging);
% 
% MetricsObject = MetricsClass();
% LumObject = Luminaire_CH11();
% 
% RowNumber = find((scores(:,1) < tolerance(1)) &...
%     (scores(:,2) < tolerance(2)) &...
%     (scores(:,3) < tolerance(3)));
% 
% % Filter the results
% OptimisedSpectra = LumObject.get_CH11Spec_Vec(last_population(RowNumber, :));
% OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);
% 
% fprintf('VORHER -- Melanopic-EDI change across the optimisation results: %d \n',...
%     round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1));
% 
% Vorher = round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1);
% 
% [Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA_Max_Delta_mDER(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
%     num_channels, population_size, max_iter, max_time, last_population, [], Logging);
% 
% % The population needs to be filtered to show only the code value results that filled the threshold conditions
% MetricsObject = MetricsClass();
% LumObject = Luminaire_CH11();
% 
% % Filter the results
% OptimisedSpectra = LumObject.get_CH11Spec_Vec(last_population);
% 
% OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);
% 
% RowNumber = find((OptimisedMetrics.Luminance-qp(1) < tolerance(1)) &...
%     (OptimisedMetrics.CIEx_1931_2-qp(2) < tolerance(2)) &...
%     (OptimisedMetrics.CIEy_1931_2-qp(3) < tolerance(3)));
% 
% OptimisedMetrics = OptimisedMetrics(RowNumber,:);
% 
% fprintf('NACHHER -- Melanopic-EDI change across the optimisation results: %d \n',...
%     round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1));
% 
% Nacher = round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1);
% 
% fprintf('Vorher %d ---- Nachher %d \n', Vorher/qp(1), Nacher/qp(1))

% ========================================================
% ========================================================
% ========================================================

function [Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = ....
    runOptim_GA_Max_Delta_mDER(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging)

Logging_PopulationArchiv = [];
Logging_OptimSummary = [];

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

end

global NumIteration;
InitialPopSize_Buffer = population_size;
global NumSol_Buffer; % Number of found solutions that meet the criteria
global Population_Archiv_Buffer;
global IterTime_Buffer;
IterTime_Buffer = 1;

global maxmDER_Buffer;
maxmDER_Buffer = 0;

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
problem.Aineq = [];
problem.Bineq = [];

% Set the name of the solver
problem.solver = 'gamultiobj';
problem.options = optimoptions('gamultiobj');

% Define the output function, which is used for checking the tolerances
problem.options = optimoptions(problem.options, 'OutputFcn', @myOutputFunction);

% Define the objectives
problem.fitnessfcn = @myObjectives;

% Define nonlinear-constrain
problem.nonlcon = @nonlcon;

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

        if Lum == 15
            CurrentSpectra = LumObject.get_CH15Spec_Vec(X);
        elseif Lum == 11
            CurrentSpectra = LumObject.get_CH11Spec_Vec(X);
        end

        fprintf('Anzahl der Population: %d \n', size(X,1))
        Metrics = MetricsObject.getMetrics_Vec(CurrentSpectra);

        if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')

            Metrics = MetricsObject.getMetrics_Vec(CurrentSpectra);
            MelanopicDER = Metrics.MelanopicEDI./Metrics.Luminance;
            tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);

            F(:, 1) = 3 - MelanopicDER; % Maximising melanopic DER
            % F(:, 1) = -3 + MelanopicDER; % Minismising melanopic DER
            F(:, 2) = abs(tolerance_Euclidian- sqrt((Metrics.CIEx_1931_2 - qp(2)).^2 + (Metrics.CIEy_1931_2 - qp(3)).^2));

            % Debugging Code ---------------
            fprintf('Count of population: %d \n', size(X,1))
            ZeileMax = Metrics(find(Metrics.MelanopicEDI == max(Metrics.MelanopicEDI)),:);
            % Berechne die Anzahl der Spektren, welche eine Leuchtdichte < 0.1 haben
            FoundOptimisationResult = find((abs(Metrics.Luminance-qp(1)) < tolerance(1)));
            fprintf('Count of spectra with a luminance below the threshold: %d \n', size(FoundOptimisationResult,1));
            % Berechne die Anzahl der Spektren, welche eine Farbortdifferent < 0.0014 aufweisen
            tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);
            CostValuesCIExy = sqrt((Metrics.CIEx_1931_2- qp(2)).^2 + (Metrics.CIEy_1931_2 - qp(3)).^2);
            FoundOptimisationResult = find((abs(CostValuesCIExy) < tolerance_Euclidian));
            fprintf('Count of spectra with a Delta xy below the threshold: %d \n', size(FoundOptimisationResult,1));
            fprintf('Mean of CIExy cost value:  %.5f \n', mean(CostValuesCIExy));
            fprintf ('Maximum MDER Difference:  %.4f \n', max(MelanopicDER)-min(MelanopicDER))

            IterTime_Buffer = IterTime_Buffer + 1;
            if isempty(MelanopicDER)
                MelanopicDERMax = maxmDER_Buffer(end-1);
            else
                MelanopicDERMax= max(MelanopicDER);
            end
            maxmDER_Buffer = [maxmDER_Buffer, MelanopicDERMax];

            scatter(1:IterTime_Buffer, maxmDER_Buffer,80, 'filled', 'b');hold on;
            plot(1:IterTime_Buffer, maxmDER_Buffer, '--b'); hold off;
            xlabel('Iterations'); ylabel('mDER');
            drawnow
            % ------------------------------
        end

    end

    function [c, ceq] = nonlcon(X)
        if Lum == 15
            CurrentSpectra = LumObject.get_CH15Spec_Vec(X);
        elseif Lum == 11
            CurrentSpectra = LumObject.get_CH11Spec_Vec(X);
        end

        Metrics = MetricsObject.getMetrics_Vec(CurrentSpectra);

        tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);
        c = [abs(Metrics.Luminance - qp(1))-tolerance(1)];

        ceq = [];

        % Debugging Code ---------------
        % fprintf('Mittelwert Leuchtdichtedifferenz: %.2f, Mittelwert Farbortdifferenz: %.2f \n',...
        %    mean(c(:, 1)),  mean(c(:, 2)));
        % ------------------------------

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

                    tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);

                    %FoundOptimisationResult = find((state.Score(:,1) < tolerance(1)) &...
                    %    (state.Score(:,2) < tolerance_Euclidian));

                    %FoundOptimisationResult = find((state.Score(:,2) < tolerance_Euclidian));

                    FoundOptimisationResult = 0;

                end

                % Stop the optimisation process before when more than 2 results were found
                if size(FoundOptimisationResult, 1) >= numberSpectraThreshold_GA
                    state.StopFlag = 'y';
                    disp('Spectral optimisation terminated.')
                    disp(['Number of found solutions: ' num2str(size(FoundOptimisationResult, 1))])
                end

        end
    end
end