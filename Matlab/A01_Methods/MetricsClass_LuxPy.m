% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% The metrics will be caluclated using the
% Luxpy library: https://github.com/ksmet1977/luxpy
% Citation of the luxpy:
% Smet, K. A. G. (2019).
% Tutorial: The LuxPy Python Toolbox for Lighting and Color Science.
% LEUKOS, 1–23. DOI: 10.1080/15502724.2018.1518717

% You need to install luxpy in your python enviroment before using this wrapper
% Follow the instructions on the luxpy page: https://ksmet1977.github.io/luxpy/build/html/installation.html
% Then, you need to adjust your python environment in Matlab.
% Type in the Matlab command window this code snippet: pyenv('Version',PATH TO YOUR PYTHON ENV)
% Additional information on how to handle python in Matlab can be found here:
% https://www.mathworks.com/help/matlab/call-python-libraries.html
% Example: pyenv('Version','/Users/papillonmac/miniconda3/envs/colSci/bin/python.app')
% or pyenv('Version','C:\Users\PupilPC2.0\Python37\Python.exe')

classdef MetricsClass_LuxPy<handle
    properties
        np;
        LuxpyObj;
        MetricsObject;
    end
    
    methods
        function self = MetricsClass_LuxPy()
            addpath('A00_Data')
            addpath('A01_Methods')
            
            np = py.importlib.import_module('numpy');
            LuxpyObj = LuxpyWrapper();
            MetricsObject = MetricsClass();

            self.LuxpyObj= LuxpyObj;
            self.np = np;
            self.MetricsObject = MetricsObject;
        end
        
        % Input:
        %    Wavelength    Gesamtspektrum ....... Gesamtspektrum_1
        %    __________    ______________ ....... ________________
        %
        %       380          2.6781e-06              ..........
        %       381          2.1927e-06                ......
        %       382          2.4942e-06                ......
        %
        function [returnMetrics] = getMetrics_Vec(self, Mischspektrum)
            
            SpectraBins = double(table2array(Mischspektrum)');
            CurrentSpectralBin_Python = py.numpy.array(SpectraBins);

            ReturnedValue_CSV1 = self.LuxpyObj.lx.toolboxes.photbiochem.spd_to_CS_CLa_lrc(...
                pyargs('El', CurrentSpectralBin_Python, 'version', 'CLa1.0'));
            ReturnedValue_CSV2 = self.LuxpyObj.lx.toolboxes.photbiochem.spd_to_CS_CLa_lrc(...
                pyargs('El', CurrentSpectralBin_Python, 'version', 'CLa2.0'));
            
            CSV1_Matlab = double(ReturnedValue_CSV1{1, 1});
            CLAV1_Matlab = double(ReturnedValue_CSV1{1, 2});
            CSV2_Matlab = double(ReturnedValue_CSV2{1, 1});
            CLAV2_Matlab = double(ReturnedValue_CSV2{1, 2});
            
            CSV1_Matlab_Table = table(CSV1_Matlab', 'VariableNames', {'CS_V1'});
            CLAV1_Matlab_Table = table(CLAV1_Matlab', 'VariableNames', {'CLa_V1'});
            
            CSV2_Matlab_Table = table(CSV2_Matlab', 'VariableNames', {'CS_V2'});
            CLAV2_Matlab_Table = table(CLAV2_Matlab', 'VariableNames', {'CLa_V2'});
            
            % Calculate the the melanopic EDI
            CalculatedMetrics = self.MetricsObject.getMetrics_Vec(array2table(double(CurrentSpectralBin_Python)'));
            MelanopicEDI_Table = table(CalculatedMetrics.MelanopicEDI, 'VariableNames', {'MelEDI'});
            
            % Calculate CRI Ra, Rf_TM30, Rg_TM30, Rcsh1_TM30, Rfh1_TM30
            pytm30_process_spd = py.getattr(self.LuxpyObj.lx.cri, '_tm30_process_spd');
            Data_dicct = pytm30_process_spd(pyargs('spd', CurrentSpectralBin_Python, 'cri_type', 'iesrf-tm30-20'));
            %disp(keys(Data_dicct));
            
            Rf = table(double(Data_dicct{'Rf'})', 'VariableNames', {'Rf_TM30'});
            Rg = table(double(Data_dicct{'Rg'})', 'VariableNames', {'Rg_TM30'});
            
            Rfhj = double(Data_dicct{'Rfhj'});
            Rcshj = double(Data_dicct{'Rcshj'});
            
            Rfh1 = table(Rfhj(1,:)', 'VariableNames', {'Rfh1_TM30'});
            Rcsh1 = table(Rcshj(1,:)', 'VariableNames', {'Rcsh1_TM30'});
            
            CCT = table(double(Data_dicct{'cct'}), 'VariableNames', {'CCT'});
            Duv = table(double(Data_dicct{'duv'}), 'VariableNames', {'Duv'});
            
            ciera = table(double(self.LuxpyObj.lx.cri.spd_to_ciera(CurrentSpectralBin_Python))',...
                'VariableNames', {'CRI_Ra'}); % CIE 13.3-1995 Ra
           
            
            CurrentMetricsTable_Bin = [CCT, Duv, CSV1_Matlab_Table, CLAV1_Matlab_Table,...
                CSV2_Matlab_Table, CLAV2_Matlab_Table,...
                MelanopicEDI_Table,...
                Rf, Rg, Rfh1, Rcsh1, ciera];
            
            CurrentMetricsTable_Bin.Illuminance(:) = round(CalculatedMetrics.Luminance);
            CurrentMetricsTable_Bin.MelDER = CurrentMetricsTable_Bin.MelEDI./CurrentMetricsTable_Bin.Illuminance;
            CurrentMetricsTable_Bin.CLa_V1_div_illuminance = CurrentMetricsTable_Bin.CLa_V1./CurrentMetricsTable_Bin.Illuminance;
            CurrentMetricsTable_Bin.CLa_V2_div_illuminance = CurrentMetricsTable_Bin.CLa_V2./CurrentMetricsTable_Bin.Illuminance;
            

            returnMetrics = CurrentMetricsTable_Bin;
        end
        
    end
    
    
end
