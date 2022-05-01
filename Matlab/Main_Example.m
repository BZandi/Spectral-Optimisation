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

%% How to adjust a spectrum on our lab's 15-channel LED luminaire
% CAUTION: This script can only be used if you connect your PC to the luminaire
% Call this code snippets line by line!

addpath('A01_Methods') % Basics
A = seriallist; % Show available connections

% 1) Create an object of the serial connection
% The first argument is the COM-PORT (on windows something like 'COM4')
% The second argiment is the baudrate of the microcontroler, which is 115200
Serial_Object = Serial_Com('/dev/tty.SLAB_USBtoUART', 115200);

% 2) Open the connection to the luminaire
Serial_Object.open_Serial_Port();

% 3a) Adjust the current or the PWM values directly on the luminaire
% PWM values need to be within 0 to 1.0 with three digits max
% The current values are integer values ranging from 1 to 13
[Ausgabe_Strom, Zeit_Strom] = Serial_Object.set_Current([1,13,1,1,1,1,1,1,1,6,1,1,1,1,1]);
[Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM([0,0,0,0,0,0,0,0,0.842,0,0,0,0,0,0]);

% 3b) You can also adjust a short flash
% First argument is the channel number
% The second argument is the exposure duration in ms
% The third argument is the PWM value within [0 1.0]
[Ausgabe_Flash, Zeit_Flash] = Serial_Object.set_flash(14,100,0.5);

% 3c) With this method you can also check the luminaire (random protocoll)
Serial_Object.check_Luminaire();

% 4) Important: Do not forget to close the connection
Serial_Object.close_Serial_Port();

clear; clc;

%% Example on how to adjust a spectrum on the 15-channel LED luminaire and measure it using a CS2000A spectrotadiometer

addpath('A01_Methods') % Basics
A = seriallist; % Show available connections

% 1) Create an object of the MetricsClass to compute the lighting values
MetricsObject = MetricsClass();

% 2) Connect to the luminaire
% The first argument is the COM-PORT (on windows something like 'COM4')
% The second argiment is the baudrate of the microcontroler, which is 115200
Serial_Object = Serial_Com('/dev/tty.SLAB_USBtoUART', 115200);
Serial_Object.open_Serial_Port();

% 3) Measure the spectrum with the CS2000A
% The first argument is the used COM-PORT
% The second argument is the count of repeated measurements
Spektrum = measure_CS2000('/dev/tty.usbmodem12345678901', 10);

% 4) Compute the lighting metrics
MetricsObject.getMetrics_Vec(Spektrum)

%%










