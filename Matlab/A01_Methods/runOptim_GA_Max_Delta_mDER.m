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

function [Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = ....
    runOptim_GA_Max_Delta_mDER(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging, OptimState)

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

global OptimState_global;
OptimState_global = OptimState;
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

            if OptimState_global == 'Maximise'
                F(:, 1) = abs(3 - MelanopicDER); % Maximising melanopic DER
            elseif OptimState_global == 'Minimise'
                F(:, 1) = -3 + MelanopicDER; % Minismising melanopic DER
            end
            %F(:, 2) = abs(tolerance_Euclidian- sqrt((Metrics.CIEx_1931_2 - qp(2)).^2 + (Metrics.CIEy_1931_2 - qp(3)).^2));

            % Debugging Code ---------------
            % ------------------------------
            fprintf('Count of population: %d \n', size(X,1))
            ZeileMax = Metrics(find(Metrics.MelanopicEDI == max(Metrics.MelanopicEDI)),:);
            % Berechne die Anzahl der Spektren, welche eine Leuchtdichte < 0.1 haben
            FoundOptimisationResult = find((abs(Metrics.Luminance-qp(1)) < tolerance(1)));

            fprintf('Count of spectra with a luminance below the threshold: %d \n', size(FoundOptimisationResult,1));
            % Berechne die Anzahl der Spektren, welche eine Farbortdifferent < 0.0014 aufweisen
            tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);
            CostValuesCIExy = sqrt((Metrics.CIEx_1931_2- qp(2)).^2 + (Metrics.CIEy_1931_2 - qp(3)).^2);
            FoundOptimisationResult = find(CostValuesCIExy < tolerance_Euclidian);

            fprintf('Count of spectra with a Delta xy below the threshold: %d \n', size(FoundOptimisationResult,1));
            fprintf('Global Maximum MDER:  %.4f \n', max(MelanopicDER));
            fprintf('Global Mnimum MDER:  %.4f \n', min(MelanopicDER));

            RowNumber_2 = find((Metrics.Luminance-qp(1) < tolerance(1)) &...
                (CostValuesCIExy < tolerance_Euclidian));
            OptimisedMetrics_2 = Metrics(RowNumber_2,:);
            After_Max_Value = round(max(OptimisedMetrics_2.MelanopicEDI))/qp(1);

            fprintf('Actual Maximum MDER:  %.4f \n', max(OptimisedMetrics_2.MelanopicEDI)/qp(1));
            fprintf('Actual Mnimum MDER:  %.4f \n', min(OptimisedMetrics_2.MelanopicEDI)/qp(1));

            IterTime_Buffer = IterTime_Buffer + 1;
            if OptimState_global == 'Maximise'

                if isempty(After_Max_Value) %isempty(MelanopicDER)
                    MelanopicDERMax = maxmDER_Buffer(end);
                else
                    MelanopicDERMax= max(OptimisedMetrics_2.MelanopicEDI)/qp(1);
                end

            elseif OptimState_global == 'Minimise'
                if isempty(After_Max_Value) %isempty(MelanopicDER)
                    MelanopicDERMax = maxmDER_Buffer(end);
                else
                    MelanopicDERMax= min(OptimisedMetrics_2.MelanopicEDI)/qp(1);
                end
            end
            maxmDER_Buffer = [maxmDER_Buffer, MelanopicDERMax];

            scatter(1:IterTime_Buffer, maxmDER_Buffer,80, 'filled', 'b');hold on;
            plot(1:IterTime_Buffer, maxmDER_Buffer, '--b'); hold off;
            xlabel('Iterations'); ylabel('mDER');
            drawnow
            % ------------------------------
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
        %c = [abs(Metrics.Luminance - qp(1))-tolerance(1)];
        c = [abs(Metrics.Luminance - qp(1))-tolerance(1),...
            sqrt((Metrics.CIEx_1931_2 - qp(2)).^2 + (Metrics.CIEy_1931_2 - qp(3)).^2)-tolerance_Euclidian];

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