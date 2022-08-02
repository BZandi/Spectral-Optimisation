% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% Add the folder to path
addpath("A00_Data/")
addpath("A01_Methods/")

% Setting some adjustments for getting a better plot style
set(groot, 'DefaultLineLineWidth', 2);
set(groot, 'DefaultAxesLineWidth', 1);
set(groot, 'DefaultAxesFontName', 'Charter');
set(groot, 'DefaultAxesFontSize', 7);
set(groot, 'DefaultAxesFontWeight', 'normal');
set(groot, 'DefaultAxesXMinorTick', 'on');
set(groot, 'DefaultAxesXGrid', 'on');
set(groot, 'DefaultAxesYGrid', 'on');
set(groot, 'DefaultAxesGridLineStyle', ':');
set(groot, 'DefaultAxesUnits', 'normalized');
set(groot, 'DefaultAxesOuterPosition',[0, 0, 1, 1]);
set(groot, 'DefaultFigureUnits', 'inches');
set(groot, 'DefaultFigurePaperPositionMode', 'manual');
set(groot, 'DefaultFigurePosition', [0.1, 11, 8.5, 4.5]);
set(groot, 'DefaultFigurePaperUnits', 'inches');
set(groot, 'DefaultFigurePaperPosition', [0.1, 11, 8.5, 4.5]);

%% Example of how to generate arbitrary spectra using the different available luminaires
close all;
% Luminaire 1: 15-channel LED luminaire =========================
% See the following paper for more information about the luminaire:
% Zandi, B., Klabes, J. & Khanh, T.Q.
% Prediction accuracy of L- and M-cone based human pupil light models.
% Sci Rep 10, 10988 (2020). https://doi.org/10.1038/s41598-020-67593-3

% Step one: Create an object of the luminaire class
LumObject_CH15 = Luminaire();

% Step two: Create an array of code values
% Note: For the 15-channel LED luminiaire the code values need to be between 0 to 1
% with a resolution of three digits, meaning 0.001, 0.002,...
PWM_Array = [0.001, 0.05, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;...% First set of code values
    0.001, 0.05, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]; % Second set of code values

% Step three: Estimate the spectra from the simulated luminaire and caluclate the luminance
MetricsObject = MetricsClass();

Spectra = LumObject_CH15.get_CH15Spec_Vec(PWM_Array);
Metrics = MetricsObject.getMetrics_Vec(Spectra);

% Step four: Plot the results
figure; gcaObject = gca;
set(gcf, 'Position', [0.1 11 6 3]);
plot(Spectra.Wavelength, Spectra.Gesamtspektrum_1/max(Spectra.Gesamtspektrum_1)); hold on;
plot(Spectra.Wavelength, Spectra.Gesamtspektrum_2/max(Spectra.Gesamtspektrum_2)); hold off;
xlabel("Wavelength (nm)"); ylabel("Relative Radiance (a.u.)")
title("Simulated Spectra of the 15-channel LED luminaire")
subtitle({['Luminance of Spectrum 1: ' num2str(round(Metrics.Luminance(1), 2))],...
    ['Luminance of Spectrum 2: ' num2str(round(Metrics.Luminance(2), 2))]});
gcaObject.TitleHorizontalAlignment = 'left';
legend({'Spectrum 1', 'Spectrum 2'})

% ===============================================================

% Luminaire 2: 11-channel LED luminaire =========================
% See the following paper for more information about the luminaire:
% Zandi, B., Stefani, O., Herzog, A. et al.
% Optimising metameric spectra for integrative lighting to modulate the circadian system without affecting visual appearance.
% Sci Rep 11, 23188 (2021). https://doi.org/10.1038/s41598-021-02136-y

% Step one: Create an object of the luminaire class
LumObject_CH11 = Luminaire_CH11();

% Step two: Create an array of code values
% Note: For the 11-channel LED luminiaire the code values need to be between 0 to 1.023.
% with a resolution of three digits, meaning 0, 0.001,...,1.023
PWM_Array = [0.001, 0.05, 0.5, 0, 0, 0.5, 0, 0, 0, 0, 0;...% First set of code values
    0.5, 0.05, 0.5, 0, 0, 0, 0.5, 1, 1, 1, 1.023]; % Second set of code values

% Step three: Estimate the spectra from the simulated luminaire and caluclate the luminance
MetricsObject = MetricsClass();

Spectra = LumObject_CH11.get_CH11Spec_Vec(PWM_Array);
Metrics = MetricsObject.getMetrics_Vec(Spectra);

% Step four: Plot the results
figure; gcaObject = gca;
set(gcf, 'Position', [0.1 11 6 3]);
plot(Spectra.Wavelength, Spectra.Gesamtspektrum_1/max(Spectra.Gesamtspektrum_1)); hold on;
plot(Spectra.Wavelength, Spectra.Gesamtspektrum_2/max(Spectra.Gesamtspektrum_2)); hold off;
xlabel("Wavelength (nm)"); ylabel("Relative Radiance (a.u.)")
title("Simulated Spectra of the 11-channel LED luminaire")
subtitle({['Luminance of Spectrum 1: ' num2str(round(Metrics.Luminance(1), 2))],...
    ['Luminance of Spectrum 2: ' num2str(round(Metrics.Luminance(2), 2))]});
gcaObject.TitleHorizontalAlignment = 'left';
legend({'Spectrum 1', 'Spectrum 2'})

% ===============================================================


%% Run spectral optimisation using the multi-objective genetic algorithm (15-channel LED luminiaire)

% Define optimisation conditions ============================
% Target objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
qp = [500, 0.333, 0.333];
% Tolerances for the objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
tolerance = [0.1, 0.0001, 0.0001];
Lum = 15; % We use a 15-channel LED luminiare
num_channels = 15; % We use a 15-channel LED luminiare
population_size = 5000; % Size of the initial population
max_iter = 100000; % Count of iterations (Generations) of the optimisation
max_time = 1200; % Maximum optimisation time in seconds
last_pop = [];
scores = [];
ObjectiveClass = 'Luminance_CIExy_1931_2'; % Can also be 'Luminance_CIEuv_1976_2' or 'Receptorsignals'

% Stoping criterium can also be the number of found spectra
% Break if you find this number of spectra
NumberSpectra = 20;

% Indicate if you wish to log the results: 1->true, 0->false
% Caution: logging is very time consuming
Logging = 1;
% =============================================================

% Run the optimisation
% Note that you need to adjust the tolerances in the myOutputFunction() inside
% the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.1, 0.0001, 0.0001]"
[Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging);

% The population needs to be filtered to show only the code value results that filled the threshold conditions
MetricsObject = MetricsClass();
LumObject = Luminaire();

RowNumber = find((scores(:,1) < tolerance(1)) &...
    (scores(:,2) < tolerance(2)) &...
    (scores(:,3) < tolerance(3)));

% Filter the results
OptimisedSpectra = LumObject.get_CH15Spec_Vec(last_population(RowNumber, :));
OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);

fprintf('Melanopic-EDI change across the optimisation results: %d \n',...
    round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1));

%% Run spectral optimisation using the multi-objective genetic algorithm (11-channel LED luminiaire)

% Define optimisation conditions ============================
% Target objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
qp = [500, 0.333, 0.333];
% Tolerances for the objectives [Luminance in cd/m2, CIEx-1931, CIEy-1931]
tolerance = [0.1, 0.0001, 0.0001];
Lum = 11; % We use a 11-channel LED luminiare
num_channels = 11; % We use a 11-channel LED luminiare
population_size = 3000; % Size of the initial population
max_iter = 150; % Count of iterations (Generations) of the optimisation
max_time = 200400; % Maximum optimisation time in seconds
last_pop = [];
scores = [];
ObjectiveClass = 'Luminance_CIExy_1931_2'; % Can also be 'Luminance_CIEuv_1976_2' or 'Receptorsignals'

% Stoping criterium can also be the number of found spectra
% Break if you find this number of spectra
NumberSpectra = 5000;

% Indicate if you wish to log the results: 1->true, 0->false
% Caution: logging is very time consuming
Logging = 1;
% =============================================================

% Run the optimisation
% Note that you need to adjust the tolerances in the myOutputFunction() inside
% the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.1, 0.0001, 0.0001]"
[Logging_PopulationArchiv, Logging_OptimSummary, x, fval, exitflag, output, last_population, scores] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging);

% The population needs to be filtered to show only the code value results that filled the threshold conditions
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

%% [UNDER DEVELOPMENT] - Optimising the maximum metameric melanopic EDI contrast
% Here, two optimisation trials are conducted to maximise or minimise the melanopic EDI
% for a given chromaticity and luminance. This process may take a while, but the metameric contrast
% might be higher than the previous approach.

% =============================================================
% Define optimisation conditions ============================
% Target objectives [Luminance in cd/m2, CIEu'-1976_2, CIEv'-1976_2]
qp = [220, 0.239748, 0.539096];
% Tolerances for the objectives [Luminance in cd/m2, CIEu'-1976_2, CIEv'-1976_2]
tolerance = [0.5, 0.001, 0.001];
Lum = 11; % We use a 11-channel LED luminiare
num_channels = 11; % We use a 11-channel LED luminiare
population_size = 3000; % Size of the initial population
max_iter = 150; % Count of iterations (Generations) of the optimisation
max_time = 200400; % Maximum optimisation time in seconds
last_pop = [];
scores = [];
ObjectiveClass = 'Luminance_CIEuv_1976_2'; % Can also be 'Luminance_CIEuv_1976_2' or 'Receptorsignals'

% Stoping criterium can also be the number of found spectra
% Break if you find this number of spectra
NumberSpectra = 5000;

% Indicate if you wish to log the results: 1->true, 0->false
% Caution: logging is very time consuming
Logging = 0;

% NEW Values (Do not forget) ==================================

% ---- IMPORTANT 1 : ----- If Rf = [], than Rf_Actual should also be Rf_Actual = []

% ---- IMPORTANT 2 : ----- Before using a Rf value read the file MetricsClass_LuxPy.m

% This value is used for maximsation in the optimisation
Rf = []; % Options: 1) 100 or 2) []

% With this value only spectra are considered with x > Rf_Actual
Rf_Actual = []; % 1) Value (Example: 80) or 2) []

% Number of Iterations for minimsation or maximisation run
max_iter_OPTIM_MAX_MIN = 150;

% =============================================================
% =============================================================


MetricsObject = MetricsClass();
LumObject = Luminaire_CH11();

% 1) Run first optimisation trial (find spectra for chromaticity and luminance) ========================
% Note that you need to adjust the tolerances in the myOutputFunction() inside
% the runOptim_GA() function. Currently the thresholds are set to "tolerance = [0.1, 0.0001, 0.0001]"
[Logging_PopulationArchiv_1, Logging_OptimSummary_1, x_1, fval_1, exitflag_1, output_1, last_population_1, scores_1] = runOptim_GA(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter, max_time, last_pop, scores, Logging);

% The population needs to be filtered to show only the code value results that filled the threshold conditions
RowNumber_1 = find((scores_1(:,1) < tolerance(1)) &...
    (scores_1(:,2) < tolerance(2)) &...
    (scores_1(:,3) < tolerance(3)));

% Filter the results
OptimisedSpectra = LumObject.get_CH11Spec_Vec(last_population_1(RowNumber_1, :));
OptimisedMetrics = MetricsObject.getMetrics_Vec(OptimisedSpectra);

Previous_Contrast_Value = round(abs(max(OptimisedMetrics.MelanopicEDI) - min(OptimisedMetrics.MelanopicEDI)), 1);

fprintf('1. Optimisation: The metameric melanopic DER change is %.3f \n', Previous_Contrast_Value/qp(1))
fprintf('1. Optimisation: Maximum melanopic DER is %.3f \n', max(OptimisedMetrics.MelanopicEDI)/qp(1))
fprintf('1. Optimisation: Minimum melanopic DER is %.3f \n', min(OptimisedMetrics.MelanopicEDI)/qp(1))
fprintf('1. Optimisation: Number of optimised spectra %d \n', size(RowNumber_1,1))

% =======================================================================================================


% 2) Run the second optimisation trial (maximise melanopic EDI) =========================================
OptimState = 'Maximise'; % or 'Minimise'
[Logging_PopulationArchiv_2, Logging_OptimSummary_2, x_2, fval_2, exitflag_2, output_2, last_population_2, scores_2] = runOptim_GA_Max_Delta_mDER(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter_OPTIM_MAX_MIN, max_time, last_population_1, [], Logging, OptimState, Rf);

OptimisedSpectra_2 = LumObject.get_CH11Spec_Vec(last_population_2);
OptimisedMetrics_2 = MetricsObject.getMetrics_Vec(OptimisedSpectra_2);

tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);
if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
    CostValuesCIE = sqrt((OptimisedMetrics_2.CIEx_1931_2- qp(2)).^2 + (OptimisedMetrics_2.CIEy_1931_2 - qp(3)).^2);
elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
    CostValuesCIE = sqrt((OptimisedMetrics_2.CIEu_1976_2- qp(2)).^2 + (OptimisedMetrics_2.CIEv_1976_2 - qp(3)).^2);
end

if ~isempty(Rf)
    MetricsObject_LuxPy = MetricsClass_LuxPy();
    MetricsLuxpy = MetricsObject_LuxPy.getMetrics_Vec(OptimisedSpectra_2);
    OptimisedMetrics_2.Rf_TM30 = MetricsLuxpy.Rf_TM30;

    RowNumber_2 = find((abs(OptimisedMetrics_2.Luminance-qp(1)) < tolerance(1)) &...
        (CostValuesCIE < tolerance_Euclidian) & ...
        (OptimisedMetrics_2.Rf_TM30 > Rf_Actual));
else
    RowNumber_2 = find((abs(OptimisedMetrics_2.Luminance-qp(1)) < tolerance(1)) &...
        (CostValuesCIE < tolerance_Euclidian));
end

OptimisedMetrics_2 = OptimisedMetrics_2(RowNumber_2,:);

After_Max_Value = round(max(OptimisedMetrics_2.MelanopicEDI));

fprintf('-- WARNING -- Rf condition is set to %d \n', Rf_Actual)

fprintf('2. Optimisation: Number of solutions %d \n', size(OptimisedMetrics_2,1))
fprintf('2. Optimisation: The maximum melanopic DER is %.3f \n', After_Max_Value/qp(1))
% =======================================================================================================


% 3) Run the second optimisation trial (minmise melanopic EDI) =========================================
OptimState = 'Minimise'; % 'Maximise'
[Logging_PopulationArchiv_3, Logging_OptimSummary_3, x_3, fval_3, exitflag_3, output_3, last_population_3, scores_3] = runOptim_GA_Max_Delta_mDER(Lum, ObjectiveClass, qp, tolerance, NumberSpectra,...
    num_channels, population_size, max_iter_OPTIM_MAX_MIN, max_time, last_population_1, [], Logging, OptimState, Rf);

OptimisedSpectra_3 = LumObject.get_CH11Spec_Vec(last_population_3);
OptimisedMetrics_3 = MetricsObject.getMetrics_Vec(OptimisedSpectra_3);

tolerance_Euclidian = sqrt((tolerance(2))^2 + (tolerance(3))^2);
if strcmp(ObjectiveClass, 'Luminance_CIExy_1931_2')
    CostValuesCIE = sqrt((OptimisedMetrics_3.CIEx_1931_2- qp(2)).^2 + (OptimisedMetrics_3.CIEy_1931_2 - qp(3)).^2);
elseif strcmp(ObjectiveClass, 'Luminance_CIEuv_1976_2')
    CostValuesCIE = sqrt((OptimisedMetrics_3.CIEu_1976_2- qp(2)).^2 + (OptimisedMetrics_3.CIEv_1976_2 - qp(3)).^2);
end

if ~isempty(Rf)
    MetricsObject_LuxPy = MetricsClass_LuxPy();
    MetricsLuxpy = MetricsObject_LuxPy.getMetrics_Vec(OptimisedSpectra_3);
    OptimisedMetrics_3.Rf_TM30 = MetricsLuxpy.Rf_TM30;

    RowNumber_3 = find((abs(OptimisedMetrics_3.Luminance-qp(1)) < tolerance(1)) &...
        (CostValuesCIE < tolerance_Euclidian) & ...
        (OptimisedMetrics_3.Rf_TM30 > Rf_Actual));
else
    RowNumber_3 = find((abs(OptimisedMetrics_3.Luminance-qp(1)) < tolerance(1)) &...
        (CostValuesCIE < tolerance_Euclidian));
end

OptimisedMetrics_3 = OptimisedMetrics_3(RowNumber_3,:);

After_Min_Value = round(min(OptimisedMetrics_3.MelanopicEDI));

fprintf('-- WARNING -- Rf condition is set to %d \n', Rf_Actual)
fprintf('3. Optimisation: Number of solutions %d \n', size(OptimisedMetrics_3,1))
fprintf('3. Optimisation: The minimum melanopic DER is %.3f \n', After_Min_Value/qp(1))
% =======================================================================================================


% Print all results as a summary of the computation ====================================================
fprintf('========================== \n \n')

fprintf('-- WARNING -- Rf condition is set to %d \n\n', Rf_Actual)

fprintf('========================== \n \n')
fprintf('Summary\n \n')
fprintf('========================== \n')
fprintf('1. Optimisation: The metameric melanopic DER change is %.3f \n', Previous_Contrast_Value/qp(1))
fprintf('1. Optimisation: Maximum melanopic DER is %.3f \n', max(OptimisedMetrics.MelanopicEDI)/qp(1))
fprintf('1. Optimisation: Minimum melanopic DER is %.3f \n', min(OptimisedMetrics.MelanopicEDI)/qp(1))
fprintf('========================== \n')
fprintf('2. Optimisation: Number of solutions %d \n', size(OptimisedMetrics_2,1))
fprintf('2. Optimisation: The maximum melanopic EDI is %.3f \n', After_Max_Value/qp(1))
fprintf('========================== \n')
fprintf('3. Optimisation: Number of solutions %d \n', size(OptimisedMetrics_3,1))
fprintf('3. Optimisation: The minimum melanopic EDI is %.3f \n', After_Min_Value/qp(1))
fprintf('========================== \n')
fprintf('Summary Optimisation: Maximum Delta melanopic DER is %.3f \n', After_Max_Value/qp(1) - After_Min_Value/qp(1))
fprintf('Summary Optimisation: Maximum Delta melanopic EDI is %.3f \n', After_Max_Value - After_Min_Value)
fprintf('========================== \n')
% =======================================================================================================


% 4) Get the two metameric spectral pairs that yield the maximum melanopic contrast =====================
% Information: Only the last population is considered for this calculation
% It might be possible that withtin the iterations a higher contrast could be achieved, which is not
% considered here. For this, an extended analysis need to be conducted.
CodeValues_Min_Optimisation_Filtered = last_population_3(RowNumber_3,:);
Spectra_Min_Optimisation_Filtered = LumObject.get_CH11Spec_Vec(last_population_3(RowNumber_3,:));
Metrics_Min_Optimisation_Filtered = MetricsObject.getMetrics_Vec(Spectra_Min_Optimisation_Filtered);

CodeValues_MinSpectrum = CodeValues_Min_Optimisation_Filtered(find(Metrics_Min_Optimisation_Filtered.MelanopicEDI == min(Metrics_Min_Optimisation_Filtered.MelanopicEDI)),:);
Spectrum_MinSpectrum = LumObject.get_CH11Spec_Vec(CodeValues_MinSpectrum);
Metrics_MinSpectrum = MetricsObject.getMetrics_Vec(Spectrum_MinSpectrum);

CodeValues_MAX_Optimisation_Filtered = last_population_2(RowNumber_2,:);
Spectra_MAX_Optimisation_Filtered = LumObject.get_CH11Spec_Vec(last_population_2(RowNumber_2,:));
Metrics_MAX_Optimisation_Filtered = MetricsObject.getMetrics_Vec(Spectra_MAX_Optimisation_Filtered);

CodeValues_MAXSpectrum = CodeValues_MAX_Optimisation_Filtered(find(Metrics_MAX_Optimisation_Filtered.MelanopicEDI == max(Metrics_MAX_Optimisation_Filtered.MelanopicEDI)),:);
Spectrum_MAXSpectrum = LumObject.get_CH11Spec_Vec(CodeValues_MAXSpectrum);
Metrics_MAXSpectrum = MetricsObject.getMetrics_Vec(Spectrum_MAXSpectrum);

plot((380:780)', Spectrum_MAXSpectrum{:,2},...
    'Color', 'b', 'DisplayName', 'Maximum mDER'); hold on;
plot((380:780)', Spectrum_MinSpectrum{:,2},...
    'Color', 'r', 'DisplayName', 'Minimum mDER');
legend('FontSize', 12);

if ~isempty(Rf)
    MetricsObject_LuxPy = MetricsClass_LuxPy();
    MetricsLuxpy = MetricsObject_LuxPy.getMetrics_Vec(OptimisedSpectra_3);

    Metrics_MAXSpectrumEXT = MetricsObject_LuxPy.getMetrics_Vec(Spectrum_MAXSpectrum);
    Metrics_MINSpectrumEXT =  MetricsObject_LuxPy.getMetrics_Vec(Spectrum_MinSpectrum);

    title('Optimised metameric spectra', 'FontSize', 12)
    subtitle({
        ['Max Spectrum - mDER: ' num2str(round(Metrics_MAXSpectrum(1,:).MelanopicEDI/qp(1),3)) ', Rf: ' num2str(round(Metrics_MAXSpectrumEXT(1,:).Rf_TM30,3))]...
        ['Min Spectrum - mDER: ' num2str(round(Metrics_MinSpectrum(1,:).MelanopicEDI/qp(1),3)) ', Rf: ' num2str(round(Metrics_MINSpectrumEXT(1,:).Rf_TM30,3))]...
        }, 'FontSize', 12)
else
    title('Optimised metameric spectra', 'FontSize', 12)
    subtitle({
        ['Max Spectrum - mDER: ' num2str(round(Metrics_MAXSpectrum(1,:).MelanopicEDI/qp(1),3))]...
        ['Min Spectrum - mDER: ' num2str(round(Metrics_MinSpectrum(1,:).MelanopicEDI/qp(1),3))]...
        }, 'FontSize', 12)
end
% =======================================================================================================



%% Test section




