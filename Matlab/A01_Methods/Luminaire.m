% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% License GNU GPLv3
% https://github.com/BZandi/Spectral-Optimisation
classdef Luminaire<handle
    % Kanal 1: Ultraviolet - 420 nm
    % Kanal 2: Royal Blue - 450 nm
    % Kanal 3: Blue - 470 nm
    % Kanal 4: Cyan - 505 nm
    % Kanal 5: Green - 530 nm
    % Kanal 6: Lime - 545 nm
    % Kanal 7: PC Amber - 590 nm
    % Kanal 8: Red-Orange - 610 nm
    % Kanal 9: Red - 630 nm
    % Kanal 10: Deep Red - 660 nm
    % Kanal 11: Far Red - 720 nm
    % Kanal 12: Warmweiß 2700 K
    % Kanal 13: Warmweiß 4000 K
    % Kanal 14: Kaltweiß 5000 K
    % Kanal 15: Kaltweiß 6500 K
    properties
        Gesamtdaten_struct;
        Current_Channel_1;
        Current_Channel_2;
        Current_Channel_3;
        Current_Channel_4;
        Current_Channel_5;
        Current_Channel_6;
        Current_Channel_7;
        Current_Channel_8;
        Current_Channel_9;
        Current_Channel_10;
        Current_Channel_11;
        Current_Channel_12;
        Current_Channel_13;
        Current_Channel_14;
        Current_Channel_15;
    end
    
    
    methods
        function self = Luminaire()
            addpath('A00_Data')            
            load('A00_Data/Daten_calc.mat');
            
            self.Gesamtdaten_struct = Gesamtdaten_struct_calc;
            
            % Der Strom wird auf Stufe 1 gelassen im Normalfall
            % wurde bis maximal 12 simuliert
            self.Current_Channel_1 = 1;
            self.Current_Channel_2 = 1;
            self.Current_Channel_3 = 1;
            self.Current_Channel_4 = 1;
            self.Current_Channel_5 = 1;
            self.Current_Channel_6 = 1;
            self.Current_Channel_7 = 1;
            self.Current_Channel_8 = 1;
            self.Current_Channel_9 = 1;
            self.Current_Channel_10 = 1;
            self.Current_Channel_11 = 1;
            self.Current_Channel_12 = 1;
            self.Current_Channel_13 = 1;
            self.Current_Channel_14 = 1;
            self.Current_Channel_15 = 1;
        end
        
        % Achtung der Strom darf nicht höher als 12 gesetzt werden
        function [self] = set_Current(self,Array_Current)
            
            self.Current_Channel_1 = Array_Current(1);
            self.Current_Channel_2 = Array_Current(2);
            self.Current_Channel_3 = Array_Current(3);
            self.Current_Channel_4 = Array_Current(4);
            self.Current_Channel_5 = Array_Current(5);
            self.Current_Channel_6 = Array_Current(6);
            self.Current_Channel_7 = Array_Current(7);
            self.Current_Channel_8 = Array_Current(8);
            self.Current_Channel_9 = Array_Current(9);
            self.Current_Channel_10 = Array_Current(10);
            self.Current_Channel_11 = Array_Current(11);
            self.Current_Channel_12 = Array_Current(12);
            self.Current_Channel_13 = Array_Current(13);
            self.Current_Channel_14 = Array_Current(14);
            self.Current_Channel_15 = Array_Current(15);
            
        end
        
        
        % Kanal 1: Ultraviolet - 420 nm
        % Kanal 2: Royal Blue - 450 nm
        % Kanal 3: Blue - 470 nm
        % Kanal 4: Cyan - 505 nm
        % Kanal 5: Green - 530 nm
        % Kanal 6: Lime - 545 nm
        % Kanal 7: PC Amber - 590 nm
        % Kanal 8: Red-Orange - 610 nm
        % Kanal 9: Red - 630 nm
        % Kanal 10: Deep Red - 660 nm
        % Kanal 11: Far Red - 720 nm
        % Kanal 12: Warmweiß 2700 K
        % Kanal 13: Warmweiß 4000 K
        % Kanal 14: Kaltweiß 5000 K
        % Kanal 15: Kaltweiß 6500 K
        function [Spektrum] = get_CH15Spec(self, Array_PWM)
            
            Wavelength = (380:780)';
            
            CH1 = self.Gesamtdaten_struct.Channel_1.(['Strom_', num2str(self.Current_Channel_1)]).(['PWM_', num2str(int16((fix(Array_PWM(1)*1000)/1000)*1000))]);
            CH2 = self.Gesamtdaten_struct.Channel_2.(['Strom_', num2str(self.Current_Channel_2)]).(['PWM_', num2str(int16((fix(Array_PWM(2)*1000)/1000)*1000))]);
            CH3 = self.Gesamtdaten_struct.Channel_3.(['Strom_', num2str(self.Current_Channel_3)]).(['PWM_', num2str(int16((fix(Array_PWM(3)*1000)/1000)*1000))]);
            CH4 = self.Gesamtdaten_struct.Channel_4.(['Strom_', num2str(self.Current_Channel_4)]).(['PWM_', num2str(int16((fix(Array_PWM(4)*1000)/1000)*1000))]);
            CH5 = self.Gesamtdaten_struct.Channel_5.(['Strom_', num2str(self.Current_Channel_5)]).(['PWM_', num2str(int16((fix(Array_PWM(5)*1000)/1000)*1000))]);
            CH6 = self.Gesamtdaten_struct.Channel_6.(['Strom_', num2str(self.Current_Channel_6)]).(['PWM_', num2str(int16((fix(Array_PWM(6)*1000)/1000)*1000))]);
            CH7 = self.Gesamtdaten_struct.Channel_7.(['Strom_', num2str(self.Current_Channel_7)]).(['PWM_', num2str(int16((fix(Array_PWM(7)*1000)/1000)*1000))]);
            CH8 = self.Gesamtdaten_struct.Channel_8.(['Strom_', num2str(self.Current_Channel_8)]).(['PWM_', num2str(int16((fix(Array_PWM(8)*1000)/1000)*1000))]);
            CH9 = self.Gesamtdaten_struct.Channel_9.(['Strom_', num2str(self.Current_Channel_9)]).(['PWM_', num2str(int16((fix(Array_PWM(9)*1000)/1000)*1000))]);
            CH10 = self.Gesamtdaten_struct.Channel_10.(['Strom_', num2str(self.Current_Channel_10)]).(['PWM_', num2str(int16((fix(Array_PWM(10)*1000)/1000)*1000))]);
            CH11 = self.Gesamtdaten_struct.Channel_11.(['Strom_', num2str(self.Current_Channel_11)]).(['PWM_', num2str(int16((fix(Array_PWM(11)*1000)/1000)*1000))]);
            CH12 = self.Gesamtdaten_struct.Channel_12.(['Strom_', num2str(self.Current_Channel_12)]).(['PWM_', num2str(int16((fix(Array_PWM(12)*1000)/1000)*1000))]);
            CH13 = self.Gesamtdaten_struct.Channel_13.(['Strom_', num2str(self.Current_Channel_13)]).(['PWM_', num2str(int16((fix(Array_PWM(13)*1000)/1000)*1000))]);
            CH14 = self.Gesamtdaten_struct.Channel_14.(['Strom_', num2str(self.Current_Channel_14)]).(['PWM_', num2str(int16((fix(Array_PWM(14)*1000)/1000)*1000))]);
            CH15 = self.Gesamtdaten_struct.Channel_15.(['Strom_', num2str(self.Current_Channel_15)]).(['PWM_', num2str(int16((fix(Array_PWM(15)*1000)/1000)*1000))]);
            
            Spektrum = table(Wavelength,CH1,CH2,CH3,CH4,CH5,CH6,CH7,CH8,CH9,CH10,CH11,CH12,CH13,CH14,CH15);
            Spektrum.Gesamtspektrum = CH1 + CH2+ CH3 + CH4 + CH5 + CH6 + CH7 + CH8 + CH9 + CH10 + CH11 + CH12 + CH13 + CH14 + CH15;
        end
        
        function [Spektrum] = get_CH15Spec_Vec(self, Array_PWM)
            % Hier wird plus 2 gemacht, weil die erste Spalte Wavelength ist
            Wavelength = (380:780)';
            CH1 = self.Gesamtdaten_struct.Channel_1.(['Strom_', num2str(self.Current_Channel_1)]){:,int16((fix(Array_PWM(:,1)*1000)/1000)*1000)+2}';
            CH2 = self.Gesamtdaten_struct.Channel_2.(['Strom_', num2str(self.Current_Channel_2)]){:,int16((fix(Array_PWM(:,2)*1000)/1000)*1000)+2}';
            CH3 = self.Gesamtdaten_struct.Channel_3.(['Strom_', num2str(self.Current_Channel_3)]){:,int16((fix(Array_PWM(:,3)*1000)/1000)*1000)+2}';
            CH4 = self.Gesamtdaten_struct.Channel_4.(['Strom_', num2str(self.Current_Channel_4)]){:,int16((fix(Array_PWM(:,4)*1000)/1000)*1000)+2}';
            CH5 = self.Gesamtdaten_struct.Channel_5.(['Strom_', num2str(self.Current_Channel_5)]){:,int16((fix(Array_PWM(:,5)*1000)/1000)*1000)+2}';
            CH6 = self.Gesamtdaten_struct.Channel_6.(['Strom_', num2str(self.Current_Channel_6)]){:,int16((fix(Array_PWM(:,6)*1000)/1000)*1000)+2}';
            CH7 = self.Gesamtdaten_struct.Channel_7.(['Strom_', num2str(self.Current_Channel_7)]){:,int16((fix(Array_PWM(:,7)*1000)/1000)*1000)+2}';
            CH8 = self.Gesamtdaten_struct.Channel_8.(['Strom_', num2str(self.Current_Channel_8)]){:,int16((fix(Array_PWM(:,8)*1000)/1000)*1000)+2}';
            CH9 = self.Gesamtdaten_struct.Channel_9.(['Strom_', num2str(self.Current_Channel_9)]){:,int16((fix(Array_PWM(:,9)*1000)/1000)*1000)+2}';
            CH10 = self.Gesamtdaten_struct.Channel_10.(['Strom_', num2str(self.Current_Channel_10)]){:,int16((fix(Array_PWM(:,10)*1000)/1000)*1000)+2}';
            CH11 = self.Gesamtdaten_struct.Channel_11.(['Strom_', num2str(self.Current_Channel_11)]){:,int16((fix(Array_PWM(:,11)*1000)/1000)*1000)+2}';
            CH12 = self.Gesamtdaten_struct.Channel_12.(['Strom_', num2str(self.Current_Channel_12)]){:,int16((fix(Array_PWM(:,12)*1000)/1000)*1000)+2}';
            CH13 = self.Gesamtdaten_struct.Channel_13.(['Strom_', num2str(self.Current_Channel_13)]){:,int16((fix(Array_PWM(:,13)*1000)/1000)*1000)+2}';
            CH14 = self.Gesamtdaten_struct.Channel_14.(['Strom_', num2str(self.Current_Channel_14)]){:,int16((fix(Array_PWM(:,14)*1000)/1000)*1000)+2}';
            CH15 = self.Gesamtdaten_struct.Channel_15.(['Strom_', num2str(self.Current_Channel_15)]){:,int16((fix(Array_PWM(:,15)*1000)/1000)*1000)+2}';
            
            Spektrum = table(Wavelength);
            Spektrum.Gesamtspektrum = (CH1 + CH2+ CH3 + CH4 + CH5 + CH6 + CH7 + CH8 + CH9 + CH10 + CH11 + CH12 + CH13 + CH14 + CH15)';
            Spektrum = splitvars(Spektrum);
        end
        
        % Leuchtenkonfiguration 1: (KW, CW)
        % Kanal 12 (2700 K), Kanal 15 (5700 K)
        function [Spektrum] = get_CH2Spec(self, Array_PWM, Vec)
            % Konstruieren eines 15 Werte Vektors
            PlaceholderPWM = zeros(size(Array_PWM, 1), 15);
            idx = [12, 15];
            PlaceholderPWM(:,idx) = Array_PWM;
            if Vec == 1 % Dann soll eine Vektoroperation verwendet werden
                Spektrum = self.get_CH15Spec_Vec(PlaceholderPWM);
            else
                Spektrum = self.get_CH15Spec(PlaceholderPWM);
            end
        end
        
        % Leuchtenkonfiguration 2:(RGB, KW, CW)
        % Kanal 3 (470 nm), Kanal 5 (530 nm), Kanal 10 (660 nm), Kanal 12 (2700 K), Kanal 15 (5700 K)
        function [Spektrum] = get_CH3Spec(self, Array_PWM, Vec)
            % Konstruieren eines 15 Werte Vektors
            PlaceholderPWM = zeros(size(Array_PWM, 1), 15);
            idx = [3, 5, 10, 12, 15];
            PlaceholderPWM(:,idx) = Array_PWM;
            if Vec == 1 % Dann soll eine Vektoroperation verwendet werden
                Spektrum = self.get_CH15Spec_Vec(PlaceholderPWM);
            else
                Spektrum = self.get_CH15Spec(PlaceholderPWM);
            end
        end
        
        % Leuchtenkonfiguration 3:
        % Kanal 2 (450 nm), Kanal 3 (470 nm), Kanal 5 (530 nm), Kanal 6 (545 nm),
        % Kanal 9 (630 nm), Kanal 10 (660 nm)
        function [Spektrum] = get_CH6Spec(self, Array_PWM, Vec)
            % Konstruieren eines 15 Werte Vektors
            PlaceholderPWM = zeros(size(Array_PWM, 1), 15);
            idx = [2, 3, 5, 6, 9, 10];
            PlaceholderPWM(:,idx) = Array_PWM;
            if Vec == 1 % Dann soll eine Vektoroperation verwendet werden
                Spektrum = self.get_CH15Spec_Vec(PlaceholderPWM);
            else
                Spektrum = self.get_CH15Spec(PlaceholderPWM);
            end
        end
        
        % Leuchtenkonfiguration 4 (alles ausser Kanal 11 - IR):
        function [Spektrum] = get_CH14Spec(self, Array_PWM, Vec)
            % Konstruieren eines 15 Werte Vektors
            PlaceholderPWM = zeros(size(Array_PWM, 1), 15);
            idx = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15];
            PlaceholderPWM(:,idx) = Array_PWM;
            if Vec == 1 % Dann soll eine Vektoroperation verwendet werden
                Spektrum = self.get_CH15Spec_Vec(PlaceholderPWM);
            else
                Spektrum = self.get_CH15Spec(PlaceholderPWM);
            end
        end
        
    end
    
end
