% Author: Babak Zandi, Laboratory of Lighting Technology, TU Darmstadt
% Licence GNU GPLv3
% Source of code: https://github.com/BZandi/Metameric-Spectra/

% Please consider to cite our work if you find this code useful for your research:
% Zandi, B., Stefani, O., Herzog, A., Schlangen, L., Trinh, Q. V., & Khanh, T. Q. (2021).
% Optimising metameric spectra for integrative lighting to modulate the circadian system without affecting visual appearance.
% Scientific reports, 11(1), 23188. https://doi.org/10.1038/s41598-021-02136-y

function [] = plot_CCTLocus(label, CCT_Line, CCT_step, DUV)
addpath('A00_Data')
load('CCT_Locus_Data.mat')
options = optimset('Display','off');

cieplot_xy_empty(CCT_Values_Table) % CIE 1931 2°

if CCT_Line == true
    
    if isempty(CCT_step)
        CCT_big = [1500:500:4000, 5000:1000:7000, 10000];
        CCT_small = [1550:50:1950, 2050:50:2450, 2550:50:2950,...
            3050:50:3450, 3550:50:3950, 4050:50:4950, 5050:50:5950];
    else
        CCT = CCT_step;
    end
    
    if isempty(DUV)
        Duv = 0.01;
    else
        Duv = DUV;
    end
    for j = 1:2
        if (j == 2)
            Duv = 0.001;
            CCT = CCT_small;
        else
            CCT = CCT_big;
        end
        for i = 1:size(CCT,2)
            
            u_1 = CCT_Values_Table(find(CCT_Values_Table.CCT == CCT(i)),:).Farbort_u;
            v_1 = CCT_Values_Table(find(CCT_Values_Table.CCT == CCT(i)),:).Farbort_v;
            
            u_2 = CCT_Values_Table(find(CCT_Values_Table.CCT == CCT(i)) + 1,:).Farbort_u;
            v_2 = CCT_Values_Table(find(CCT_Values_Table.CCT == CCT(i)) + 1,:).Farbort_v;
            
            Model = polyfit([u_1, u_2], [v_1, v_2], 1);
            f1 = polyval(Model, linspace(u_1-0.1,u_1+0.1));
            m_1 = Model(1);
            b_1 = Model(2);
            
            hold on;
            % plot(u_1, v_1, 'o')
            % plot( linspace(u_1-0.1,u_1+0.1),f1,'r-', 'LineWidth', 1)
            
            % Orthogonale Linie drauf zeichnen
            Model_2_orth = Model;
            Model_2_orth(1) = -1/m_1;
            Model_2_orth(2) = -Model_2_orth(1)*u_1+v_1;
            %Duv = linspace(0.003, 0.007, size(CCT,2));
            Distanzfunction_1 = @(x) pdist([u_1 v_1; x polyval(Model_2_orth, x);], 'euclidean')-Duv;
            
            % 1. Seite ----------------------------------------------------
            u_predict_start_1 = fsolve(Distanzfunction_1, [-u_1], options);
            v_predict_start_1 = polyval(Model_2_orth, u_predict_start_1);
            %plot(u_predict_start_1, v_predict_start_1, 'ko')
            f_1 = polyval(Model_2_orth, linspace(u_predict_start_1,u_1));
            % -------------------------------------------------------------
            
            % 2. Seite ----------------------------------------------------
            u_predict_start_2 = fsolve(Distanzfunction_1, [u_1], options);
            %plot(u_predict_start_1, v_predict_start_1, 'ko')
            f_2 = polyval(Model_2_orth, linspace(u_predict_start_2,u_1));
            % --------------------------------------------------------------
            
            % Vektoren erzeugen, die zum Plotten verwendet werden
            u_1_line = linspace(u_predict_start_1,u_1);
            v_1_line = f_1;
            
            u_2_line = linspace(u_predict_start_2,u_1);
            v_2_line = f_2;
            
            
            % uv zu xy
            % Folgende Parameter müssen eingegeben werden
            % j, CCT, u_predict_start_1, v_predict_start_1, u_1_line, v_1_line, u_2_line, v_2_line
            [x_predict_start_1, y_predict_start_1] = UV_to_xy(u_predict_start_1, v_predict_start_1);
            [x_1_line, y_1_line] = UV_to_xy(u_1_line, v_1_line);
            [x_2_line, y_2_line] = UV_to_xy(u_2_line, v_2_line);
            plot_locus(label, j, CCT(i), x_predict_start_1, y_predict_start_1, x_1_line, y_1_line, x_2_line, y_2_line);
            
            %clearvars -except CCT_Values_Table CCT Duv CCT_small CCT_big j i Farbraum
        end
    end
    axis equal;
    hold off;
end
end

function [x,y] = UV_to_xy(u, v)
% Umwandlung von uv 1960 zu xy
% Quelle: https://en.wikipedia.org/wiki/CIE_1960_color_space
x = (3.*u)./(2.*u- 8.*v + 4);
y = (2.*v)./(2.*u- 8.*v + 4);
end

function [] = plot_locus(label, j, CCT, u_predict_start_1, v_predict_start_1, u_1_line, v_1_line, u_2_line, v_2_line)
if label == true
    if j ==1
        if CCT == 1500
            text(u_predict_start_1,v_predict_start_1, [num2str(CCT) ' K'], 'FontSize', 12.5,...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        else
            text(u_predict_start_1,v_predict_start_1,[num2str(CCT) ' K'], 'FontSize', 12.5,...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
    end
end
plot(u_1_line ,v_1_line,'k-', 'LineWidth', 1)
plot(u_2_line,v_2_line,'k-', 'LineWidth', 1)
end

function [] = cieplot_xy_empty(CCT_Values_Table)

plot(CCT_Values_Table{:,2},CCT_Values_Table{:,3},'k','LineWidth',1); hold on; grid on;
axis([0.0 0.85 0.0 0.85])
ylim([0 0.9]);
xlim([0 0.8]);

end








