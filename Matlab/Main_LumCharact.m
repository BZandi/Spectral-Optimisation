%% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% This File can be used to measure the base spectra and build a  offline
% model of the luminare, which can be used in the Luminaire file.

%% 1) Measure the base spectra of the 15-channel LED luminaire

addpath("A00_Data")
addpath("A01_Methods")
addpath("A01_Methods/Driver_CS2000")

% ARGUMENTS:
% 1: com_spectro is the COM-PORT of the CS2000 spectroradiometer. Example 'COM5'
% 2: com_Leuchte is the COM-PORT of the luminaire. Example 'COM3'
% 3: Array_PWM_Steps Steps of the PWM. Example [0:0.05:1]
% 4: Array_Current_Steps Steps of the current. Example 1 or 1:1:13
% 5: Array_Channels Steps of channels. Example [1:15]
LumCharacterization('COM5', 'COM3', [0:0.05:1], 1, [1:15])

%% 2) The code in this section can be used to interpolate the measured base spectra
clc; clear;

addpath("A00_Data")
addpath("A00_Data/Luminaire_RawData")
addpath("A01_Methods")
addpath("A01_Methods/Driver_CS2000")

% Create empty data struct ================================================
% =========================================================================
% Load the saved mat-file from section 1)
load('A00_Data/Luminaire_RawData/Characterization_01-11-2021-1035UHR.mat');
Array_PWM_Steps = [0:50:1000];

for Channel_index = 1:15
    %figure(Channel_index);
    
    for Current_index = 1:1
        Legenden = {};
        
        % ax = subplot(3,4,Current_index);
        
        Empty_Table = table();
        Empty_Table.Wavelength = [380:1:780]';
        
        for PWM_index = 1:length(Array_PWM_Steps)
            
            PWM_Wert = Array_PWM_Steps(PWM_index);
            % Stromwert 1: {1,1}, Stromwert 2: {2,1}
            Empty_Table.(['PWM_', num2str(Array_PWM_Steps(PWM_index))]) = data.(['Channel_',num2str(Channel_index)]).(['PWM_',num2str(PWM_Wert)]){Current_index,1}';
            
            %plot(ax, Empty_Table.Wavelength, Empty_Table.(['PWM_', num2str(Array_PWM_Steps(PWM_index))]))
            %grid on
            %Legenden = [Legenden, ['PWM_', num2str(Array_PWM_Steps(PWM_index))]];
            %legend(Legenden);
            %drawnow;
            %hold on;
        end
        assignin('base', sprintf('Kanal_%d_Strom_%d_Measure', Channel_index, Current_index), Empty_Table)
        clear('Empty_Table')
        
    end
end
clear('PWM_index', 'Array_PWM_Steps', 'Channel_index', 'Current_index', 'ax', 'data', 'Legenden', 'PWM_Wert')
save('A00_Data/Luminaire_RawData/Characterization_01-11-2021-1035UHR_Processed.mat');
clear

% If you want to check how the data are interpolated use this code
% % x sind die PWM-Werte von 0 bis 100 in 5er Schritten
% x = [0:50:1000];
% % y sind die Intensitäten bei der jeweiligen Wellenlänge
% y = Kanal_5_Strom_11_Measure{20,2:end};
% 
% % Anfitten und Berechnung der Genauigkeit
% [Curve_fitting,gof] = fit(x',y','poly6');
% gof.adjrsquare
% 
% % Plotten der Ergebnisse
% figure
% hold on, grid on, box on;
% set(gca,'FontSize',14)
% p = polyfit(x, y, 6);
% plot(0:1000 ,polyval(p, 0:1000),'LineWidth', 2)
% plot(x ,y, 'o')
% =========================================================================
% =========================================================================


% Interpolate the values ================================================
% =========================================================================
% Information:
% Die Daten werden eingegeben zwischen 0 bis 1 mit einer Auflösung von
% 0.001. Damit sind es insgesamt 1001 Werte (1000 Werte, wenn man von 0 ausgeht).
% Damit wird die Tabelle umgerechnet mit 0.001*1000 = 1.

% In this script it is assumed that the current ranges on level one.
% The generated file can be used with the Luminaire method in A01_Methods

% Change is appropriate
filename = 'A00_Data/Luminaire_RawData/Characterization_01-11-2021-1035UHR_Processed.mat';
m = matfile(filename);

for Channel_index = 1:15
    
    for Current_index = 1:1
        tic
        Polynom = 6;
        Empty_Table = table();
        Empty_Table.Wavelength = (380:780)';
        Empty_Table.PWM_0 = zeros(401,1,1);
        
        Step_PWM_Array = [0.001:0.001:1];
            Datensatz = m.(['Kanal_',num2str(Channel_index),'_Strom_',num2str(Current_index),'_Measure']);
            Aktuelles_Table = get_spec_from_Poly(Step_PWM_Array, Datensatz, Polynom);
            fprintf('Kanal %d Strom %d \n', Channel_index, Current_index);
        assignin('base', sprintf('Kanal_%d_Strom_%d_Calc', Channel_index, Current_index), Aktuelles_Table);
        timer = toc;
        fprintf('Berechnung abgechlossen Kanal_%d_Strom_%d - Zeit: %d Sekunden\n', Channel_index, Current_index, timer);
    end
end

clear('m', 'Current_index', 'Datensatz',...
    'Empty_Table', 'End_Var', 'Polynom', 'Aktuelles_Table', 'Step_PWM_Array', 'Channel_index', 'timer')
save(filename);
% =========================================================================
% =========================================================================


% Make the data more compact ================================================
% =========================================================================
Gesamtdaten_struct_calc = struct;
filename = 'A00_Data/Luminaire_RawData/Base_Worspace_CH15_01-11-2021.mat';

for Channel_index = 1:15 
    for Current_index = 1:1   
        Gesamtdaten_struct_calc.(['Channel_',num2str(Channel_index)]).(['Strom_', num2str(Current_index)]) = ...
            evalin('base', sprintf('Kanal_%d_Strom_%d_Calc', Channel_index, Current_index));      
    end
end

clear('Channel_index', 'Current_index', 'ans',...
    'Kanal_10_Strom_1_Calc',...
    'Kanal_11_Strom_1_Calc',...
    'Kanal_12_Strom_1_Calc',...
    'Kanal_13_Strom_1_Calc',...
    'Kanal_14_Strom_1_Calc',...
    'Kanal_15_Strom_1_Calc',...
    'Kanal_1_Strom_1_Calc',...
    'Kanal_2_Strom_1_Calc',...
    'Kanal_3_Strom_1_Calc',...
    'Kanal_4_Strom_1_Calc',...
    'Kanal_5_Strom_1_Calc',...
    'Kanal_6_Strom_1_Calc',...
    'Kanal_7_Strom_1_Calc',...
    'Kanal_8_Strom_1_Calc',...
    'Kanal_9_Strom_1_Calc');

save(filename, 'Gesamtdaten_struct_calc');
% =========================================================================
% =========================================================================

% If you need to export the data as csv for python, use this code
% for Channel_index = 1:15
%     for Current_index = 1:4
%         Daten = evalin('base', sprintf('Kanal_%d_Strom_%d_Calc', Channel_index, Current_index)); 
%         writetable(Daten, sprintf('Daten/CSV/Kanal_%d_Strom_%d_Calc.csv', Channel_index, Current_index))
%     end
% end

% Comparing the simulated with the measured spectrum
%load('A00_Data/Luminaire_RawData/Characterization_01-11-2021-1035UHR.mat');
%load('A00_Data/Luminaire_RawData/Base_Worspace_CH11_01-11-2021.mat')
%plot(data.(['Channel_',num2str(2)]).(['PWM_',num2str(500)]){1,1}, 'b-'); hold on;
%plot(Kanal_2_Strom_1_Calc{:,'PWM_500'}, 'r-')
 
%% 3) Measure random polychromatic spectra to estimate the accuracy of the luminaire's offline model

% Pfad hinzufügen ------------------------
addpath("A00_Data")
addpath("A01_Methods")
addpath("A01_Methods/Driver_CS2000")
% -----------------------------------------

rng('default')
RandomChannelConfig_Lum_1 = [];
RandomChannelConfig_Lum_2 = [];
RandomChannelConfig_Lum_3 = [];
RandomChannelConfig_Lum_4 = [];

% Header for the Wavelenths
for WaveIndex = 380:780
    WavelengthCellStr{WaveIndex-379} = ['W' num2str(WaveIndex) 'nm'];
end

ZeroPWM = zeros(1,15);

% Welche Leuchtenkonfigurationen werden behandelt (100 Spektren je Konfiguration):
% Leuchtenkonfiguration 1: (KW, CW)
% Kanal 12 (2700 K), Kanal 15 (5700 K)
RandomChannelConfig_Lum_1 = rand(20, 15);
RandomChannelConfig_Lum_1(:, [1:11, 13:14]) = 0;
RandomChannelConfig_Lum_1 = round(RandomChannelConfig_Lum_1, 3);
RandomChannelConfig_Lum_1 = array2table(RandomChannelConfig_Lum_1);
RandomChannelConfig_Lum_1.Properties.VariableNames = {'CH_1', 'CH_2', 'CH_3', 'CH_4', 'CH_5', 'CH_6', 'CH_7',...
    'CH_8', 'CH_9', 'CH_10', 'CH_11', 'CH_12', 'CH_13', 'CH_14', 'CH_15'};

% Leuchtenkonfiguration 2:(RGB, KW, CW)
% Kanal 3 (470 nm), Kanal 5 (530 nm), Kanal 10 (660 nm), Kanal 12 (2700 K), Kanal 15 (5700 K)
RandomChannelConfig_Lum_2 = rand(20, 15);
RandomChannelConfig_Lum_2(:, [1, 2, 4, 6, 7, 8, 9, 11, 13, 14]) = 0;
RandomChannelConfig_Lum_2 = round(RandomChannelConfig_Lum_2, 3);
RandomChannelConfig_Lum_2 = array2table(RandomChannelConfig_Lum_2);
RandomChannelConfig_Lum_2.Properties.VariableNames = {'CH_1', 'CH_2', 'CH_3', 'CH_4', 'CH_5', 'CH_6', 'CH_7',...
    'CH_8', 'CH_9', 'CH_10', 'CH_11', 'CH_12', 'CH_13', 'CH_14', 'CH_15'};

% Leuchtenkonfiguration 3:
% Kanal 2 (450 nm), Kanal 3 (470 nm), Kanal 5 (530 nm), Kanal 6 (545 nm),
% Kanal 9 (630 nm), Kanal 10 (660 nm)
RandomChannelConfig_Lum_3 = rand(20, 15);
RandomChannelConfig_Lum_3(:, [1, 4, 7, 8, 11, 12, 13, 14, 15]) = 0;
RandomChannelConfig_Lum_3 = round(RandomChannelConfig_Lum_3, 3);
RandomChannelConfig_Lum_3 = array2table(RandomChannelConfig_Lum_3);
RandomChannelConfig_Lum_3.Properties.VariableNames = {'CH_1', 'CH_2', 'CH_3', 'CH_4', 'CH_5', 'CH_6', 'CH_7',...
    'CH_8', 'CH_9', 'CH_10', 'CH_11', 'CH_12', 'CH_13', 'CH_14', 'CH_15'};

% Leuchtenkonfiguration 4 (alles ausser Kanal 11 - IR):
RandomChannelConfig_Lum_4 = rand(20, 15);
RandomChannelConfig_Lum_4(:, 11) = 0;
RandomChannelConfig_Lum_4 = round(RandomChannelConfig_Lum_4, 3);
RandomChannelConfig_Lum_4 = array2table(RandomChannelConfig_Lum_4);
RandomChannelConfig_Lum_4.Properties.VariableNames = {'CH_1', 'CH_2', 'CH_3', 'CH_4', 'CH_5', 'CH_6', 'CH_7',...
    'CH_8', 'CH_9', 'CH_10', 'CH_11', 'CH_12', 'CH_13', 'CH_14', 'CH_15'};

%--------------------------------------------------------------------------
com_spectro='COM6'; %COM port for CS2000 Spectrometer
com_Leuchte='COM4'; %COM port for 15 Chanel
pausetime=3; %burn in time
date=[datestr(now,'dd-mm-yyyy-HHMM') 'UHR'];
%--------------------------------------------------------------------------

% Verbindung zur Leuchte herstellen
Serial_Object = Serial_Com(com_Leuchte, 115200);
Serial_Object.open_Serial_Port();

% Strom auf Stufe 1 stellen
[Ausgabe_Strom, Zeit_Strom] = Serial_Object.set_Current(ones(1,15));

% Messung Leuchtenkonfiguration 1 ------------------------------
Spectra_Luminaire_1 = [];

for i = 1:size(RandomChannelConfig_Lum_1, 1)
    [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM([RandomChannelConfig_Lum_1{i, :}]);
    pause(pausetime);
    if Ausgabe_PWM == 1
        Spektrum = measure_CS2000(com_spectro, 1);
        Spektrum = array2table(Spektrum.Gesamtspektrum');
        Spektrum.Properties.VariableNames = WavelengthCellStr;
        CurrentLine = [RandomChannelConfig_Lum_1(i, :), Spektrum];
        Spectra_Luminaire_1 = [Spectra_Luminaire_1; CurrentLine];
    else
        disp("ACHTUNG PWM KONNTE NICHT EINGESTELLT WERDEN!!!-------")
    end
end
% ------------------------------------------------------------


% Messung Leuchtenkonfiguration 2 ------------------------------
Spectra_Luminaire_2 = [];

for i = 1:size(RandomChannelConfig_Lum_2, 1)
    [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(RandomChannelConfig_Lum_2{i, :});
    pause(pausetime);
    if Ausgabe_PWM == 1
        Spektrum = measure_CS2000(com_spectro, 1);
        Spektrum = array2table(Spektrum.Gesamtspektrum');
        Spektrum.Properties.VariableNames = WavelengthCellStr;
        CurrentLine = [RandomChannelConfig_Lum_2(i, :), Spektrum];
        Spectra_Luminaire_2 = [Spectra_Luminaire_2; CurrentLine];
    else
        disp("ACHTUNG PWM KONNTE NICHT EINGESTELLT WERDEN!!!-------")
    end
end
% ------------------------------------------------------------


% Messung Leuchtenkonfiguration 3 ------------------------------
Spectra_Luminaire_3 = [];

for i = 1:size(RandomChannelConfig_Lum_3, 1)
    [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(RandomChannelConfig_Lum_3{i, :});
    pause(pausetime);
    if Ausgabe_PWM == 1
        Spektrum = measure_CS2000(com_spectro, 1);
        Spektrum = array2table(Spektrum.Gesamtspektrum');
        Spektrum.Properties.VariableNames = WavelengthCellStr;
        CurrentLine = [RandomChannelConfig_Lum_3(i, :), Spektrum];
        Spectra_Luminaire_3 = [Spectra_Luminaire_3; CurrentLine];
    else
        disp("ACHTUNG PWM KONNTE NICHT EINGESTELLT WERDEN!!!-------")
    end
end
% ------------------------------------------------------------


% Messung Leuchtenkonfiguration 4 ------------------------------
Spectra_Luminaire_4 = [];

for i = 1:size(RandomChannelConfig_Lum_4, 1)
    [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(RandomChannelConfig_Lum_4{i, :});
    pause(pausetime);
    if Ausgabe_PWM == 1
        Spektrum = measure_CS2000(com_spectro, 1);
        Spektrum = array2table(Spektrum.Gesamtspektrum');
        Spektrum.Properties.VariableNames = WavelengthCellStr;
        CurrentLine = [RandomChannelConfig_Lum_4(i, :), Spektrum];
        Spectra_Luminaire_4 = [Spectra_Luminaire_4; CurrentLine];
    else
        disp("ACHTUNG PWM KONNTE NICHT EINGESTELLT WERDEN!!!-------")
    end
end
% ------------------------------------------------------------

Serial_Object.close_Serial_Port();


%% Testing




