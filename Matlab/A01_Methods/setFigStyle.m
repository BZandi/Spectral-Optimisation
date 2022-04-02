% Before plotting call this code:
% set(groot, 'DefaultLineLineWidth', 2);
% set(groot, 'DefaultAxesLineWidth', 1);
% set(groot, 'DefaultAxesFontName', 'Charter');
% set(groot, 'DefaultAxesFontSize', 7);
% set(groot, 'DefaultAxesFontWeight', 'normal');
% set(groot, 'DefaultAxesXMinorTick', 'on');
% set(groot, 'DefaultAxesXGrid', 'on');
% set(groot, 'DefaultAxesYGrid', 'on');
% set(groot, 'DefaultAxesGridLineStyle', ':');
% set(groot, 'DefaultAxesUnits', 'normalized');
% set(groot, 'DefaultAxesOuterPosition',[0, 0, 1, 1]);
% set(groot, 'DefaultFigureUnits', 'inches');
% set(groot, 'DefaultFigurePaperPositionMode', 'manual');
% set(groot, 'DefaultFigurePosition', [0.1, 11, 8.5, 4.5]);
% set(groot, 'DefaultFigurePaperUnits', 'inches');
% set(groot, 'DefaultFigurePaperPosition', [0.1, 11, 8.5, 4.5]);

% Example how to use this function:
% close all;
% figure; t = tiledlayout(1,2, 'Padding', "compact", "TileSpacing", "compact");
% set(gcf, 'Position', [0.1, 11, 10, 3]);
% 
% GridLabel = 'off';
% LineCol_1 = 'r';
% LineCol_2 = 'b';
% 
% ax(1) = nexttile(1); hold on;
% x = linspace(0,30);
% y1 = sin(x/2);
% y2 = cos(x/3);
% plot(x, y1, 'DisplayName', 'Sinus');
% plot(x, y2, 'DisplayName', 'Cosinus');
% xlabel("Wavelength (nm)"); ylabel("Relative Radiance (a.u.)")
% title("Plot Number 1")
% subtitle({['Subtitle 1: ' num2str(3)],...
%     ['Subtitle 2: ' num2str(4)]});
% ax(1).TitleHorizontalAlignment = 'left';
% legend(ax(1), 'Location', 'northeast', 'Box','off');
% 
% ax(2) = nexttile(2); hold on;
% x = linspace(0,30);
% y1 = sin(x/2);
% y2 = cos(x/3);
% plot(x, y1, 'DisplayName', 'Sinus');
% plot(x, y2, 'DisplayName', 'Cosinus');
% xlabel("Wavelength (nm)"); ylabel("Relative Radiance (a.u.)")
% title("Plot Number 2")
% subtitle({['Subtitle 1: ' num2str(3)],...
%     ['Subtitle 2: ' num2str(4)]});
% ax(2).TitleHorizontalAlignment = 'left';
% 
% YLim = [-1, 1]; YLimTick = [-1:0.5:1];
% XLim = [0, 30]; XLimTick = [0:5:30];
% set(ax(1), 'YLim', YLim, 'XLim', XLim, 'XMinorTick','off', 'XTick', XLimTick, 'YTick', YLimTick); grid(ax(1), GridLabel);
% set(ax(2), 'YLim', YLim, 'XLim', XLim, 'XMinorTick','off', 'XTick', XLimTick, 'YTick', YLimTick); grid(ax(2), GridLabel);
% 
% FontName = 'Charter'; % ot Lato
% FontSizeExport = 8;
% LineWidthExport = 0.5;
% BoxStatus = 'off';
% LatexStatus = false; % \mathbf{} or \textbf{} for bold fonts
% HeightCM = 5;
% WidthCM = 15.8;
% 
% setFigStyle(FontName, FontSizeExport, LineWidthExport,...
%     BoxStatus, LatexStatus, HeightCM, WidthCM);
% exportgraphics(gcf, '/Users/papillon/Desktop/Testbild2.pdf','ContentType','vector');

function setFigStyle(FontName, FontSizeExport, LineWidthExport,...
    BoxStatus, LatexStatus, HeightCM, WidthCM)

fig = gcf;
fig.Units = 'centimeters';
fig.Renderer = 'painters';

fig.PaperPositionMode = 'manual';
set(findall(gcf,'-property','FontSize'),'FontSize',FontSizeExport);
set(findall(gcf,'-property','Box'),'Box',BoxStatus);
set(findall(gcf,'-property','FontName'),'FontName', FontName);
if LatexStatus == true
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex')
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
end
set(findall(gcf,'-property','Linewidth'),'Linewidth',LineWidthExport);
set(gcf, 'Units','centimeters', 'Position', [0.1, 11, WidthCM, HeightCM]); % [PositionDesk, PositionDesk, Width, Height]

%set(findobj(gcf, 'FontSize', 12), 'FontSize', 8)
%set(findobj(gcf, 'Linewidth', 1), 'Linewidth', 0.5)

end
