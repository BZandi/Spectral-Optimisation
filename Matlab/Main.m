% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% License GNU GPLv3
% https://github.com/BZandi/Spectral-Optimisation

% Add the folder to path
addpath("A00_Data/")
addpath("A01_Methods/")

%% Run spectral optimisation using the multi-objective genetic algorithm

% Define optimisation conditions ------------------
% Target objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
qp = [500, 0.333, 0.333];
% Tolerances for the objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
tolerance = [0.1, 0.0001, 0.0001];
num_channels = 15; % We use a 15-channel LED luminiare
population_size = 5000; % Size of the initial population
max_iter = 100000; % Count of iterations (Generations) of the optimisation
max_time = 1200; % Maximum optimisation time in seconds
last_pop = [];
scores = [];
% --------------------------------------

% Run the optimisation
% Note that you need to adjust the tolerances in the myOutputFunction() inside
% the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.1, 0.0001, 0.0001]"
[x, fval, exitflag, output, last_population, scores] = runOptim_GA(qp,...
    num_channels, population_size, max_iter, max_time, last_pop, scores);

% The population needs to be filtered to show only the code value results that filled the threshold conditions
MetricsObject = MetricsClass();
LumObject = Luminaire();

RowNumber = find((scores(:,1) < tolerance(1)) &...
    (scores(:,2) < tolerance(2)) &...
    (scores(:,3) < tolerance(3)));

% Filter the results
OptimisedSpectra = LumObject.get_CH15Spec_Vec(last_population(RowNumber, :));
OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);
