% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% License GNU GPLv3
% https://github.com/BZandi/Spectral-Optimisation
classdef Luminaire_CH11  
    properties
        CH_11_calc;
        CH_10_calc;
        CH_9_calc;
        CH_8_calc;
        CH_7_calc;
        CH_6_calc;
        CH_5_calc;
        CH_4_calc;
        CH_3_calc;
        CH_2_calc;
        CH_1_calc;
    end
      
    methods
        function self = Luminaire_CH11()
            addpath('A00_Data')            
            load('A00_Data/Base_Worspace_CH11.mat');
            
            self.CH_11_calc = CH_11_calc;
            self.CH_10_calc = CH_10_calc;
            self.CH_9_calc = CH_9_calc;
            self.CH_8_calc = CH_8_calc;
            self.CH_7_calc = CH_7_calc;
            self.CH_6_calc = CH_6_calc;
            self.CH_5_calc = CH_5_calc;
            self.CH_4_calc = CH_4_calc;
            self.CH_3_calc = CH_3_calc;
            self.CH_2_calc = CH_2_calc;
            self.CH_1_calc = CH_1_calc;
        end
                
        function [Spektrum] = get_CH6Spec_Vec(self, Array_PWM)
            % R, G, B, KW, WW, Cyan
            % Spektrum = self.get_Spec_CH_11_vec(ch_4, 0, ch_5, ch_6, ch_1, 0, ch_2, ch_3, 0, 0, 0);
            PlaceholderPWM = zeros(size(Array_PWM, 1), 11);
            idx = [5, 7, 8, 1, 3, 4];
            PlaceholderPWM(:,idx) = Array_PWM;
            Spektrum = self.get_CH11Spec_Vec(PlaceholderPWM);
        end
        
        function [Spektrum] = get_CH8Spec_Vec(self, Array_PWM)
            % R, G, B, KW, WW, Cyan, Mintgruen, Magenta
            % Spektrum = self.get_Spec_CH_11_vec(ch_4, 0, ch_5, ch_6, ch_1, ch_7, ch_2, ch_3, 0, ch_8, 0);
            PlaceholderPWM = zeros(size(Array_PWM, 1), 11);
            idx = [5, 7, 8, 1, 3, 4, 6, 10];
            PlaceholderPWM(:,idx) = Array_PWM;
            Spektrum = self.get_CH11Spec_Vec(PlaceholderPWM);
        end
        
        function [Spektrum] = get_CH11Spec(self, Array_PWM)
            Wavelength = (380:780)';
            
           CH1 = self.CH_1_calc(:, int16((fix(Array_PWM(:,1)*1000)/1000)*1000)+2);
           CH2 = self.CH_2_calc(:, int16((fix(Array_PWM(:,2)*1000)/1000)*1000)+2);
           CH3 = self.CH_3_calc(:, int16((fix(Array_PWM(:,3)*1000)/1000)*1000)+2);
           CH4 = self.CH_4_calc(:, int16((fix(Array_PWM(:,4)*1000)/1000)*1000)+2);
           CH5 = self.CH_5_calc(:, int16((fix(Array_PWM(:,5)*1000)/1000)*1000)+2);
           CH6 = self.CH_6_calc(:, int16((fix(Array_PWM(:,6)*1000)/1000)*1000)+2);
           CH7 = self.CH_7_calc(:, int16((fix(Array_PWM(:,7)*1000)/1000)*1000)+2);
           CH8 = self.CH_8_calc(:, int16((fix(Array_PWM(:,8)*1000)/1000)*1000)+2);
           CH9 = self.CH_9_calc(:, int16((fix(Array_PWM(:,9)*1000)/1000)*1000)+2);
           CH10 = self.CH_10_calc(:, int16((fix(Array_PWM(:,10)*1000)/1000)*1000)+2);
           CH11 = self.CH_11_calc(:, int16((fix(Array_PWM(:,11)*1000)/1000)*1000)+2);
            
            Spektrum = table(Wavelength,CH1,CH2,CH3,CH4,CH5,CH6,CH7,CH8,CH9,CH10,CH11);
            Spektrum.Gesamtspektrum = CH1 + CH2+ CH3 + CH4 + CH5 + CH6 + CH7 + CH8 + CH9 + CH10 + CH11;
        end
        
        % Input: Each channel can have a number between 0, 0.001,...,1.023
         function [Spektrum] = get_CH11Spec_Vec(self, Array_PWM)
            Wavelength = (380:780)';
                      
           CH1 = self.CH_1_calc{:, int16((fix(Array_PWM(:,1)*1000)/1000)*1000)+2}';
           CH2 = self.CH_2_calc{:, int16((fix(Array_PWM(:,2)*1000)/1000)*1000)+2}';
           CH3 = self.CH_3_calc{:, int16((fix(Array_PWM(:,3)*1000)/1000)*1000)+2}';
           CH4 = self.CH_4_calc{:, int16((fix(Array_PWM(:,4)*1000)/1000)*1000)+2}';
           CH5 = self.CH_5_calc{:, int16((fix(Array_PWM(:,5)*1000)/1000)*1000)+2}';
           CH6 = self.CH_6_calc{:, int16((fix(Array_PWM(:,6)*1000)/1000)*1000)+2}';
           CH7 = self.CH_7_calc{:, int16((fix(Array_PWM(:,7)*1000)/1000)*1000)+2}';
           CH8 = self.CH_8_calc{:, int16((fix(Array_PWM(:,8)*1000)/1000)*1000)+2}';
           CH9 = self.CH_9_calc{:, int16((fix(Array_PWM(:,9)*1000)/1000)*1000)+2}';
           CH10 = self.CH_10_calc{:, int16((fix(Array_PWM(:,10)*1000)/1000)*1000)+2}';
           CH11 = self.CH_11_calc{:, int16((fix(Array_PWM(:,11)*1000)/1000)*1000)+2}';
            
           Spektrum = table(Wavelength);
           Spektrum.Gesamtspektrum = (CH1 + CH2+ CH3 + CH4 + CH5 + CH6 + CH7 + CH8 + CH9 + CH10 + CH11)';
           Spektrum = splitvars(Spektrum);
        end
        
        
    end
    
    
end
