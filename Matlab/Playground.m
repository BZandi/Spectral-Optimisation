%% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Spectral-Optimisation


    CIEx_1931_2_Tolerance_Buffer = tolerance(2);
    CIEy_1931_2_Tolerance_Buffer = tolerance(3);
    Luminance_Tolerance_Buffer = tolerance(1);
    
        CIEu_1976_2_Tolerance_Buffer = tolerance(2);
    CIEv_1976_2_Tolerance_Buffer = tolerance(3);
    Luminance_Tolerance_Buffer = tolerance(1);
    
    
        LCone10_Tolerance_Buffer = tolerance(1);
    MCone_10_Tolerance_Buffer = tolerance(2);
    SCone_10_Tolerance_Buffer = tolerance(3);
    Rod_Tolerance_Buffer = tolerance(4);
    Melanopic_Tolerance_Buffer = tolerance(5);
    
    
        LCone10_Target_Buffer = qp(1);
    MCone_10_Target_Buffer = qp(2);
    SCone_10_Target_Buffer = qp(3);
    Rod_Target_Buffer = qp(4);
    Melanopic_Target_Buffer = qp(5);