%% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% Choose 10 optimisation targets for benchmarking the optimiser
% CIEu', CIEv' and Luminance


%% Programming an optimisation benchmark pipeline
% You need to install luxpy in your python enviroment before using this wrapper.
% Follow the instructions on the luxpy page: https://ksmet1977.github.io/luxpy/build/html/installation.html
% Then, you need to adjust your python environment in Matlab:
% Example (Mac): pyenv('Version','/Users/papillonmac/miniconda3/envs/colSci/bin/python.app')
% Example (Win): pyenv('Version','C:\Users\PupilPC2.0\Python37\Python.exe')

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

% Add the folder to path
addpath("A00_Data/")
addpath("A01_Methods/")

rng(1,'twister');

Benchmarking_Optimisation_Targets = readtable("A00_Data/Optimisation_Targets.csv");

for Index_Optim_target = 1:size(Benchmarking_Optimisation_Targets, 1)
    
    for Index_rep = 1:10
        
        % Define optimisation conditions ============================
        qp = [220,...
            Benchmarking_Optimisation_Targets.CIEu1976_Target(Index_Optim_target),...
            Benchmarking_Optimisation_Targets.CIEv1976_Target(Index_Optim_target)];
        tolerance = [0.5, 0.001, 0.001];
        Lum = 11; num_channels = 11;
        population_size = 3000;
        max_iter = 220;
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
        
        filename = ['A02_Results/IndexTarget_' num2str(Benchmarking_Optimisation_Targets.IndexNumber_Target(Index_Optim_target)) '_Rep_' num2str(Index_rep) '.mat'];
        
        Logging_OptimSummary.IndexTarget(:) = Benchmarking_Optimisation_Targets.IndexNumber_Target(Index_Optim_target);
        Logging_OptimSummary.IndexTarget_Repetition(:) = Index_rep;
        RngState = output.rngstate;
        
        save(filename, 'Logging_PopulationArchiv','Logging_OptimSummary', 'RngState');
        
        fprintf('========== Index number [%d / %d] - Repetition [%d / %d] finished ============ \n',....
            Index_Optim_target, size(Benchmarking_Optimisation_Targets, 1),...
            Index_rep, 10);
        
        clearvars Logging_PopulationArchiv Logging_OptimSummary x fval exitflag output last_population scores
        
    end
    
end

