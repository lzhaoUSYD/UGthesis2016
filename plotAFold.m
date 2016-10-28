function plotAFold(AF,clims,name)
figWidth = 1/3;
f = figure('units','normalized');
set(f, 'MenuBar', 'none');
set(f, 'ToolBar', 'none');
set(f,'position',[1-figWidth,0,figWidth,1]);

set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% Configure subplot layout
n=3;
for k = 1:n
    hsp(k) = subplot(n,1,k);
end



%% Flat view
subplot(3,1,1)

ax1 = surf(hsp(1),AF);
% ax1.XAxisLocation = 'top'
colormap(hot)
caxis(clims)
ylim([0 50])

xStr = 'Apical $\leftarrow$ Fibre No. $\rightarrow$ Basal';
yStr = 'Axon $\leftarrow$ Node No. $\rightarrow$ Process';
title('Flat view')
X1 = xlabel(xStr);
Y1 = ylabel(yStr);
C1 = colorbar;
% ylabel(C1,'f_n (V/s)')

% set(C,'ylim',[minV,maxV])
%         caxis([minV,maxV])

view([0,-90])
grid off

%% 3D view
subplot(3,1,2)

ax2 = surf(AF);
colormap(hot)
caxis(clims)
zlim(clims)

title('3D view')
X2 = xlabel('Fibre No.');
Y2 = ylabel('Node No.');
Z2 = zlabel('$f_{n}$ (V/s)'); % TODO latex for subscript

C2 = colorbar;
ylabel(C2,'f_n (V/s)')

% % Node orientation preserved, fibres orientation inverted.
% view([135.5,62])
% Node orientation inverted, fibres orientation preserved.
view([46.5,38])  
grid off

%% Depolarisation view
subplot(3,1,3)

% Make the binary scale visible. Set binary to double, shift down by 0.9 to
% get a nice shade of yellow and set to the appropriate order of magnitude
% based on colorbar limits.
AForder = abs(log(clims(2))/log(10));
Vthres = 0; % V
Vthres = max(clims)/2; % V
depol = 2 * 10^-(AForder)*(double(AF>Vthres)-0.9);
% depol([1:5,16:20],:) = 0.12;

surf(depol)
caxis(clims)
ylim([0 50])

titleStr = sprintf('Depolarisation ($f_{n}>%.2g V$)',Vthres);
title(titleStr)
X3 = xlabel(xStr);
Y3 = ylabel(yStr);
view([0,-90])

grid off

%% General configuring

xLeft = 0.12;
xWidth = 1-xLeft*1.5;
yHeight = 0.2;
% topPadding = 0.06;
yBot3 = 0.07;
yBot1 = 1 - yHeight - 0.05;
% yBot2 = yBot1 - yHeight - padding;
yBot2 = yBot3 + yHeight + 0.11;

set(hsp(1),'units','normalized','Position',[xLeft yBot1 xWidth yHeight]);
set(hsp(2),'units','normalized','Position',[xLeft yBot2 xWidth yHeight]);
set(hsp(3),'units','normalized','Position',[xLeft yBot3 xWidth yHeight]);

set(C2,'Location','northoutside')
% set(C1,'Location','southoutside')

%%

lname = strrep(name,'_',' ');
% suptitleStr1 = '{Unrolled cochlea ($\grave{a}$ la Wong et al 2014)}';
suptitleStr1 = ['{Unrolled cochlea ($\grave{a}$ la Wong et al 2014): ' lname '}'];
% suptitleStr2 = strrep([name ' (3 views of the same thing)'],'_',' ');
% suptitleStr2 = strrep(name,'_',' ');
suptitleStr2 = '';
suptitle({suptitleStr1,suptitleStr2})

rotate3d
set(findall(gcf,'-property','FontSize'),'FontSize',17)
set(C2,'FontSize',13)

end