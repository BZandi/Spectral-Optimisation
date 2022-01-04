%% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% Choose 10 optimisation targets for benchmarking the optimiser
% CIEu', CIEv' and Luminance


%% Programming an optimisation benchmark pipeline
% ======================================
% Optimisation conditions:
% Luminance: 220 cd/m2, Tolerance 0.5
% CIEuv-1976-2° Tolerance: 0.001
% Population: 5000
% Luminaire: 11-channel
% Repetitions for each target: 10
% Seed for repeatability: rng(1,'twister');
% Optimise until 200 iterations
% No time condition
% ======================================
% TODO: Metameric Contrast of MelanopicEDI when considering Rf > 85, Rf > 90.
% Current time: 39 min
rng(1,'twister');

Benchmarking_Optimisation_Targets = readtable("A00_Data/Optimisation_Targets.csv");
Index_Optim_target = 1;

% Define optimisation conditions ============================
qp = [200,...
    Benchmarking_Optimisation_Targets.CIEu1976_Target(Index_Optim_target),...
    Benchmarking_Optimisation_Targets.CIEv1976_Target(Index_Optim_target)];
tolerance = [0.5, 0.001, 0.001];
Lum = 11; num_channels = 11;
population_size = 3000;
max_iter = 200;
max_time = 1000200;
last_pop = [];
scores = [];
ObjectiveClass = 'Luminance_CIEuv_1976_2'; %'Luminance_CIEuv_1976_2' or 'Receptorsignals'

NumberSpectra = 3000;
Logging = 1;
% =============================================================

tic
[Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging);
toc

MetricsObject = MetricsClass();
LumObject = Luminaire_CH11();

RowNumber = find((scores(:,1) < tolerance(1)) &...
    (scores(:,2) < tolerance(2)) &...
    (scores(:,3) < tolerance(3)));

% Filter the results
OptimisedSpectra = LumObject.get_CH11Spec_Vec(last_population(RowNumber, :));
OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);

fprintf('Melanopic-EDI change across the optimisation results: %d \n',...
    round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1));


