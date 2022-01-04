% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation

% Wrapper to the LuxPy lib:
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

classdef LuxpyWrapper<handle
    properties
        lx
    end
    
    methods
        function self = LuxpyWrapper()            
            % This is the python equivalent to import luxpy as lx
            lx = py.importlib.import_module('luxpy');
            
            self.lx = lx;
        end
        
        function [py_CIE_ILLUMINANTS, CIE_ILLUMINANTS] = get_CIE_ILLUMINANTS(self)
            
            % Note: You can retrieve a field in Matlab using py.getattr(py_CIE_ILLUMINANTS, 'D65')
            py_CIE_ILLUMINANTS = py.getattr(self.lx, '_CIE_ILLUMINANTS');
            
            CIE_ILLUMINANTS = struct();
            for raw_key = py.list(keys(py_CIE_ILLUMINANTS))
                key = raw_key{1};
                if (~strcmp(string(key), "series") && ~strcmp(string(key), "all") && ~strcmp(string(key),"types"))
                    value = py_CIE_ILLUMINANTS{key};
                    ValidFieldName = matlab.lang.makeValidName(string(key));
                    CIE_ILLUMINANTS(1).(ValidFieldName) = double(value);
                end
            end
            
        end
    end
end