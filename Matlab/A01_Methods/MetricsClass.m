% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

%{
Additional information:

The formula for the "Fotios brightness" and "Bermann brightness" is from the paper:

Fotios SA, Levermore GJ.
Chromatic effect on apparent brightness in interior spaces II: sws Lumens model.
International Journal of Lighting Research and Technology.
1998;30(3):103-106. doi:10.1177/096032719803000302

The 2-degree s-cone sensitivity is from the paper:
Vivianne C. Smith, Joel Pokorny.
Spectral sensitivity of the foveal cone photopigments between 400 and 500 nm. Vision Research,
Volume 15, Issue 2. 1975. Pages 161-171. ISSN 0042-6989,

The other sensitivity functions are taken from the CIE S 026/E:2018

%}
classdef MetricsClass<handle
    properties
        Metriken;
        standardObserver_31;
        standardObserver_64;
        standardObserver_CIE201510
    end
    
    methods
        function self = MetricsClass()
            addpath('A00_Data')
            addpath('A01_Methods')
            
            load('A00_Data/Standard_Metriken.mat');
            load('A00_Data/Standard_Observer.mat');
            
            self.Metriken = Metriken;
            self.standardObserver_31 = standard_31;
            self.standardObserver_64 = standard_64;
            self.standardObserver_CIE201510 = CIE201510;
        end
        
        function [melanopic_EDI] = get_MelanopicEDI(self, SPD)
            
            melanopic_EDI = sum(self.Metriken.Melanopsin.* SPD)/(1.3262/1000);
            
        end
        
        % Computes the "melanopic stimulus" according to Gimenez et al. (2022)
        % Link to the Paper: https://onlinelibrary.wiley.com/doi/full/10.1111/jpi.12786
        % DeltaT_MIN: Light exposure in minutes
        % PupilState: Natural pupil = 1, dilated pupil = 0
        function [MelanopicStimulus] = ComputeMelanopicStimulus(self, SPD, DeltaT_MIN, PupilState)
            
            melanopic_EDI = self.get_MelanopicEDI(SPD);
            
            % Note:
            % The values from the provided excel sheet were used, which were not rounded.
            Constant_b = 9.00247695624451;
            Constant_d = 7.49640085099029;
            Constant_BetaE = -0.00760557655439016;
            Constant_BetaP = -0.462139891125291;
            
            MS_Part_A = log10(melanopic_EDI.*10.^6);
            
            MS_Part_B = Constant_b + Constant_BetaE*DeltaT_MIN + Constant_BetaP*PupilState;
            
            MS_Part_C = (MS_Part_A./MS_Part_B).^Constant_d + 1;
            
            MelanopicStimulus = (0-100./MS_Part_C)+100;
            
        end
        
        % Input:
        %    Wavelength    Gesamtspektrum
        %    __________    ______________
        %
        %       380          2.6781e-06
        %       381          2.1927e-06
        %       382          2.4942e-06
        %
        function [returnMetrics] = getMetrics(self, Mischspektrum)
            
            X_2 = sum(self.Metriken.Tristimulus_X_2_Grad.* Mischspektrum.Gesamtspektrum);
            Y_2 = sum(self.Metriken.Tristimulus_Y_2_Grad.* Mischspektrum.Gesamtspektrum);
            Z_2 = sum(self.Metriken.Tristimulus_Z_2_Grad.* Mischspektrum.Gesamtspektrum);
            
            X_10 = sum(self.Metriken.Tristimulus_X_10_Grad_1964.* Mischspektrum.Gesamtspektrum);
            Y_10 = sum(self.Metriken.Tristimulus_Y_10_Grad_1964.* Mischspektrum.Gesamtspektrum);
            Z_10 = sum(self.Metriken.Tristimulus_Z_10_Grad_1964.* Mischspektrum.Gesamtspektrum);
            
            x_2 = X_2/(X_2+Y_2+Z_2);
            y_2 = Y_2/(X_2+Y_2+Z_2);
            z_2 = Z_2/(X_2+Y_2+Z_2);
            
            x_10 = X_10/(X_10+Y_10+Z_10);
            y_10 = Y_10/(X_10+Y_10+Z_10);
            z_10 = Z_10/(X_10+Y_10+Z_10);
            
            L10_Signal = sum(self.Metriken.L10.* Mischspektrum.Gesamtspektrum);
            M10_Signal = sum(self.Metriken.M10.* Mischspektrum.Gesamtspektrum);
            S10_Signal = sum(self.Metriken.S10.* Mischspektrum.Gesamtspektrum);
            
            Leuchtdichte = Y_2 *683;
            Rod_Signal = sum(self.Metriken.V_lambda_2_skotopic.* Mischspektrum.Gesamtspektrum);
            V_Signal = sum(Mischspektrum.Gesamtspektrum.* self.Metriken.V_lambda_2_Grad);
            
            % Berechnung der Helligkeit nach SAGAWA
            a = (Leuchtdichte / (Leuchtdichte + 0.05)); % OK
            a_c = (1.3 * Leuchtdichte^(0.5)) / (Leuchtdichte^(0.5) + 2.24); % OK
            h = -0.0054 - 0.21 * x_2 + 0.77 * y_2 + 1.44 * x_2^(2) - 2.97 * x_2 * y_2 + 1.59 * y_2^(2) - 2.11 * (1-x_2 - y_2)* y_2^(2); % OK
            f_x_y = 0.5 * log10(h) - log10(y_2); % OK
            c = a_c * (f_x_y - 0.078); % Diese Konstante ist in der CIE noch mitenthalten
            L_strich = 1699 * Rod_Signal; % OK
            Helligkeit_Sagawa = L_strich^(1-a) * Leuchtdichte^(a) * 10^(c); % OK
            
            returnMetrics = table(...
                sum(Mischspektrum.Gesamtspektrum),... % Strahldichte
                S10_Signal,... % S10_Signal
                M10_Signal,... % M10_Signal
                L10_Signal,... % L10_Signal
                Rod_Signal,... % Rod_Signal
                sum(self.Metriken.Melanopsin.* Mischspektrum.Gesamtspektrum),... % Melanopsin_Signal
                sum(self.Metriken.Melanopsin.* Mischspektrum.Gesamtspektrum)/(1.3262/1000),... Melanopic-EDI
                Leuchtdichte,... % Leuchtdichte
                ((sum(Mischspektrum.Gesamtspektrum.* self.Metriken.S2)/V_Signal)^0.24)*Leuchtdichte,...% Helligkeit_Fotios
                (Rod_Signal / V_Signal)^(0.5) * Leuchtdichte,... % Helligkeit Bermann
                Helligkeit_Sagawa,... % Helligkeit nach Sagawa
                (4*X_2)/(X_2 + 15*Y_2 + 3*Z_2),... % u_strich_2°
                (9*Y_2)/(X_2 + 15*Y_2 + 3*Z_2),... % v_strich_2°
                (4*X_10)/(X_10 + 15*Y_10 + 3*Z_10),... % u_strich_10°
                (9*Y_10)/(X_10 + 15*Y_10 + 3*Z_10),... % v_strich_10°
                x_2,... % Farbort_x_2°
                y_2,... % Farbort_y_2°
                x_10,... % Farbort_x_2°
                y_10,... % Farbort_y_2°
                X_2,... % X_Tri
                Y_2,... % Y_Tri
                Z_2,... % Z_Tri
                X_10,... % X_Tri
                Y_10,... % Y_Tri
                Z_10... % Z_Tri
                );
            
            returnMetrics.Properties.VariableNames = {...
                'Radiance', 'SCone_10', 'MCone_10', 'LCone10', 'Rod', 'Melanopic', 'MelanopicEDI'...
                'Luminance', 'Brightness_Fotios','Brightness_Bermann', 'Brightness_Sagawa',...
                'CIEu_1976_2', 'CIEv_1976_2', 'CIEu_1976_10', 'CIEv_1976_10',...
                'CIEx_1931_2', 'CIEy_1931_2', 'CIEx_1931_10', 'CIEy_1931_10',...
                'XTri_2', 'YTri_2', 'ZTri_2', 'XTri_10', 'YTri_10', 'ZTri_10'};
        end
        
        function [returnMetrics] = getMetrics_Vec(self, Mischspektrum)
            
            X_2 = sum(self.Metriken.Tristimulus_X_2_Grad.* Mischspektrum{:,2:end})';
            Y_2 = sum(self.Metriken.Tristimulus_Y_2_Grad.* Mischspektrum{:,2:end})';
            Z_2 = sum(self.Metriken.Tristimulus_Z_2_Grad.* Mischspektrum{:,2:end})';
            
            X_10 = sum(self.Metriken.Tristimulus_X_10_Grad_1964.* Mischspektrum{:,2:end})';
            Y_10 = sum(self.Metriken.Tristimulus_Y_10_Grad_1964.* Mischspektrum{:,2:end})';
            Z_10 = sum(self.Metriken.Tristimulus_Z_10_Grad_1964.* Mischspektrum{:,2:end})';
            
            x_2 = (X_2./(X_2+Y_2+Z_2));
            y_2 = (Y_2./(X_2+Y_2+Z_2));
            z_2 = (Z_2./(X_2+Y_2+Z_2));
            
            x_10 = (X_10./(X_10+Y_10+Z_10));
            y_10 = (Y_10./(X_10+Y_10+Z_10));
            z_10 = (Z_10./(X_10+Y_10+Z_10));
            
            L10_Signal = sum(self.Metriken.L10.* Mischspektrum{:,2:end})';
            M10_Signal = sum(self.Metriken.M10.* Mischspektrum{:,2:end})';
            S10_Signal = sum(self.Metriken.S10.* Mischspektrum{:,2:end})';
            
            Leuchtdichte = (Y_2 .*683);
            Rod_Signal = sum(self.Metriken.V_lambda_2_skotopic.* Mischspektrum{:,2:end})';
            V_Signal = sum(self.Metriken.V_lambda_2_Grad.*Mischspektrum{:,2:end})';
            
            % Berechnung der Helligkeit nach SAGAWA
            a = (Leuchtdichte ./ (Leuchtdichte + 0.05)); % OK
            a_c = (1.3 .* Leuchtdichte.^(0.5)) ./ (Leuchtdichte.^(0.5) + 2.24); % OK
            h = -0.0054 - 0.21 .* x_2 + 0.77 .* y_2 + 1.44 .* x_2.^(2) - 2.97 .* x_2 .* y_2 + 1.59 .* y_2.^(2) - 2.11 .* (1 - x_2 - y_2) .* y_2.^(2); % OK
            f_x_y = 0.5 .* log10(h) - log10(y_2); % OK
            c = a_c .* (f_x_y - 0.078); % Diese Konstante ist in der CIE noch mitenthalten
            L_strich = 1699 .* Rod_Signal; % OK
            Helligkeit_Sagawa = L_strich.^(1-a) .* Leuchtdichte.^(a) .* 10.^(c); % OK
            
            returnMetrics = table(...
                sum(Mischspektrum{:,2:end})',...
                S10_Signal,... % S10_Signal
                M10_Signal,... % M10_Signal
                L10_Signal,... % L10_Signal
                Rod_Signal,... % Rod_Signal
                sum(self.Metriken.Melanopsin.* Mischspektrum{:,2:end})',... % Melanopsin_Signal
                sum(self.Metriken.Melanopsin.* Mischspektrum{:,2:end})'/(1.3262/1000),... Melanopic-EDI
                Leuchtdichte,... % Leuchtdichte
                ((sum(Mischspektrum{:,2:end}.* self.Metriken.S2)'./V_Signal).^0.24).*Leuchtdichte,...% Helligkeit_Fotios
                (Rod_Signal ./ V_Signal).^(0.5) .* Leuchtdichte,... % Helligkeit Bermann
                Helligkeit_Sagawa,... % Helligkeit nach Sagawa
                (4.*X_2)./(X_2 + 15.*Y_2 + 3.*Z_2),... % u_strich-2°
                (9.*Y_2)./(X_2 + 15.*Y_2 + 3.*Z_2),... % v_strich-2°
                (4.*X_10)./(X_10 + 15.*Y_10 + 3.*Z_10),... % u_strich-10°
                (9.*Y_10)./(X_10 + 15.*Y_10+ 3.*Z_10),... % v_strich-10°
                x_2,... % Farbort_x-2
                y_2,... % Farbort_y-2
                x_10,... % Farbort_x-2
                y_10,... % Farbort_y-2
                X_2,... % X_Tri
                Y_2,... % Y_Tri
                Z_2,... % Z_Tri
                X_10,... % X_Tri
                Y_10,... % Y_Tri
                Z_10... % Z_Tri
                );
            
            returnMetrics.Properties.VariableNames = {...
                'Radiance', 'SCone_10', 'MCone_10', 'LCone10', 'Rod', 'Melanopic', 'MelanopicEDI'...
                'Luminance', 'Brightness_Fotios','Brightness_Bermann', 'Brightness_Sagawa',...
                'CIEu_1976_2', 'CIEv_1976_2', 'CIEu_1976_10', 'CIEv_1976_10',...
                'CIEx_1931_2', 'CIEy_1931_2', 'CIEx_1931_10', 'CIEy_1931_10',...
                'XTri_2', 'YTri_2', 'ZTri_2', 'XTri_10', 'YTri_10', 'ZTri_10'};
        end
        
    end
    
    
end
