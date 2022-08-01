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