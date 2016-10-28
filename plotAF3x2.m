% DEPRECATED. Too visually busy, not informative enough.
% TODO visualise electrode position

function plotAF3x2(AF,clims,name)


%% Figure set up
figWidth = 1/2;
hfig = figure('units','normalized');
set(hfig, 'MenuBar', 'none');
set(hfig, 'ToolBar', 'none');
set(hfig,'position',[1-figWidth,0,figWidth,1]);

set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% Configure subplot layout + general set up
rows = 3;
cols = 2;
n=rows*cols;
for k = 1:n
    hsp(k) = subplot(rows,cols,k);
end


xFibreStr = 'Apical $\leftarrow$ Fibre No. $\rightarrow$ Basal';
yNodeStr = 'Axon $\leftarrow$ Node No. $\rightarrow$ Process';
fnStr = '$f_{n}$ (V/s)';

%% Figure out which simulation it is, and the electrode settings
% As per runStimPatternsV4.m
% REF: Tran 2015
stim = strsplit(name,'_');
eConfig = stim{1};
% Reference electrode not in the sense of ground, but relative location on
% the array.
eRef = str2num(stim{2});
I0mA = 0.1065;
switch eConfig
    case 'MP'
        % Monopolar.
        activeElectrodes = eRef;
        inputCurrents    = I0mA;
    case 'BP'
        % Bipolar.
        e1 = eRef;
        % Went for latter direction in simulations (could be either side).
        e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
    case 'BP1'
        % Bipolar + 1.
        e1 = eRef;
        % Went for latter direction in simulations (could be either side).
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
    case 'BP2'
        % Bipolar + 2.
        e1 = eRef;
        % Went for latter direction in simulations (could be either side).
        e2 = e1 + 3; % e1 must be within [1,19]
        e2 = e1 - 3; % e1 must be within [4,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
    case 'TP'
        % Tripolar.
        e2 = eRef;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2,I0mA,-I0mA/2];
    otherwise
        % Partial tripolar.
        sigmaStr = eConfig(regexp(eConfig,'\d'));
        if strcmp(sigmaStr(1),'0')
            % Decimal sigma.
            sigmaStr = ['0.' sigmaStr(2:end)];
        end
        sigma = str2num(sigmaStr);
        
        e2 = eRef;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
end


%% Flat view
subplot(rows,cols,1)

% ax1 = surf(hsp(1),AF);
ax1 = surf(AF);
ax1.EdgeAlpha = 0;
alpha(0.7)
% ax1.XAxisLocation = 'top'
colormap(hot)
caxis(clims)
zlim(clims)

ylim([0 50])

electrodeMask(activeElectrodes,inputCurrents,clims,0)

title('AF map, electrode underlayed')
X1 = xlabel(xFibreStr);
Y1 = ylabel(yNodeStr);
% C1 = colorbar;
% ylabel(C1,'f_n (V/s)')

% set(C,'ylim',[minV,maxV])
%         caxis([minV,maxV])

view([0,-90])
grid off

%% 3D view
subplot(rows,cols,3)

ax2 = surf(AF);
ax2.EdgeAlpha = 0.1;
colormap(hot)
caxis(clims)
zlim(clims)

title('AF map, electrode distance overlaid')
X2 = xlabel('Fibre No.');
Y2 = ylabel('Node No.');
Z2 = zlabel(fnStr);

electrodeMask(activeElectrodes,inputCurrents,clims,1)

C2 = colorbar;
ylabel(C2,'f_n (V/s)')

% % Node orientation preserved, fibres orientation inverted.
% view([135.5,62])
% Node orientation inverted, fibres orientation preserved.
% view([46.5,38])
view([23.5,6])
grid off

%% Depolarisation view
% How to represent depolarisation?

%% >>> Simple f_n > vThres map?
subplot(rows,cols,5)

% Make the binary scale visible. Set binary to double, shift down by 0.9 to
% get a nice shade of yellow and set to the appropriate order of magnitude
% based on colorbar limits.
AForder = abs(log(clims(2))/log(10));
% Vthres = 0; % V
Vthres = max(clims)/50; % V
Vthres = 0.01; % V, determined by comparison between stimulation configs.
% Simple threshold.
AFbinary = AF>Vthres;
% Mess around with plotting to make visual sense.
depol = 2 * 10^-(AForder)*(double(AFbinary)-Vthres) - 1;
% depol([1:5,16:20],:) = 0.12;

ax3 = surf(depol);
ax3.EdgeAlpha = 0.1;

caxis(clims)
ylim([0 50])

titleStrThres = sprintf('Depolarisation ($f_{n}>%.2g V$)',Vthres);
title(titleStrThres)
X3 = xlabel(xFibreStr);
Y3 = ylabel(yNodeStr);
view([0,-90])

%% >>> +/- threshold?
subplot(rows,cols,6)

% Make the binary scale visible. Set binary to double, shift down by 0.9 to
% get a nice shade of yellow and set to the appropriate order of magnitude
% based on colorbar limits.
AForder = abs(log(clims(2))/log(10));
Vthres0 = 0; % V
% Vthres = max(clims)/2; % V
% Simple threshold.
AFbinary0 = AF>Vthres0;
% Mess around with plotting to make visual sense.
depol = 2 * 10^-(AForder)*(double(AFbinary0)-Vthres0) - 1;
% depol([1:5,16:20],:) = 0.12;

ax6 = surf(depol);
ax6.EdgeAlpha = 0.1;

caxis(clims)
ylim([0 50])

titleStrThres0 = sprintf('Depolarisation ($f_{n}>%.2g V$)',Vthres0);
title(titleStrThres0)
X3 = xlabel(xFibreStr);
Y3 = ylabel(yNodeStr);
view([0,-90])

%% - Sum of f_n along each fibre?
subplot(rows,cols,2)
AFsum = AF;
AFsum(isnan(AFsum)) = 0;
% Sum of f_n along each column (i.e. each fibre).
sums = sum(AFsum);
plot(1:100,sums)

hold on;
absSums = sum(abs(AFsum));
plot(1:100,absSums)

% From visual inspection.
ylim([-1 3])

xlabel(xFibreStr)
ylabel(['Sum of ' fnStr])
title('Sum of AF by fibre')
legend({'$f_{n}$','$\mid f_{n} \mid$'},'location','northwest')

% AFcell = mat2cell(AF,ones(size(AF,1),1),ones(size(AF,2),1));


%% - Count of f_n > vThres along each fibre?
subplot(rows,cols,4)
hold on;

countBin  = sum(AFbinary);
countBin0 = sum(AFbinary0);

plot(1:100,countBin)
plot(1:100,countBin0)

% From visual inspection.
ylim([0 40])

xlabel(xFibreStr)
ylabel('\# of nodes above threshold')
title('Suprathreshold count by fibre')
legend({titleStrThres(17:end-1),titleStrThres0(17:end-1)},'location','southwest')


%% General configuring
% % 3x1 config
% xLeft = 0.12;
% xWidth = 1-xLeft*1.5;
% yHeight = 0.2;
% % topPadding = 0.06;
% yBot3 = 0.07;
% yBot1 = 1 - yHeight - 0.05;
% % yBot2 = yBot1 - yHeight - padding;
% yBot2 = yBot3 + yHeight + 0.11;
% %
% set(hsp(1),'units','normalized','Position',[xLeft yBot1 xWidth yHeight]);
% set(hsp(2),'units','normalized','Position',[xLeft yBot2 xWidth yHeight]);
% set(hsp(3),'units','normalized','Position',[xLeft yBot3 xWidth yHeight]);
% 
% set(C2,'Location','northoutside')
% set(C1,'Location','southoutside')

% 3x2 config
xLeft = 0.12;
xWidth = 0.5-xLeft*1.5;
yHeight = 0.2;
% topPadding = 0.06;
yBot3 = 0.07;
yBot1 = 1 - yHeight - 0.05;
% yBot2 = yBot1 - yHeight - padding;
yBot2 = yBot3 + yHeight + 0.11;

% Left column 
set(hsp(1),'units','normalized','Position',[xLeft yBot1 xWidth yHeight]);
set(hsp(3),'units','normalized','Position',[xLeft yBot2 xWidth yHeight]);
set(hsp(5),'units','normalized','Position',[xLeft yBot3 xWidth yHeight]);

set(C2,'Location','northoutside')

% Right column
xLeft2 = 1 - xWidth - xLeft;
set(hsp(2),'units','normalized','Position',[xLeft2 yBot1 xWidth yHeight]);
set(hsp(4),'units','normalized','Position',[xLeft2 yBot2+0.05 xWidth yHeight]);
set(hsp(6),'units','normalized','Position',[xLeft2 yBot3 xWidth yHeight]);
% 

%%

lname = strrep(name,'_',' ');
% suptitleStr1 = '{Unrolled cochlea ($\grave{a}$ la Wong et al 2014)}';
% suptitleStr1 = ['{Unrolled cochlea ($\grave{a}$ la Wong et al 2014): ' lname '}'];
suptitleStr1 = ['{Activating function (AF): ' lname '}'];
% suptitleStr2 = strrep([name ' (3 views of the same thing)'],'_',' ');
% suptitleStr2 = strrep(name,'_',' ');
suptitleStr2 = '';
suptitle({suptitleStr1,suptitleStr2})

rotate3d
set(findall(gcf,'-property','FontSize'),'FontSize',15)
set(C2,'FontSize',13)


    function electrodeMask(activeElectrodes,inputCurrents,clims,surfDistAsWell)
        % EXTENSION: gradient, using more values from jet. Probably cut one color
        % triplet from hot (leaving 76 triplets) and pad with 12 blueish, 12
        % reddish triplets.
        % A bit of excess bulk in this function but only 0.08s for the
        % redundant set-up part. Not heavily used enough to justify
        % potentially confusing relocation of set-up.
        %% Electrode locations (for overlaying on AF plots)
        % Get electrode locations in 3D space.
        load electrodesOrdered eCentres electrodes
        
        % Get nerve fibre splines.
        s = load('Spline attempt 20-Sep-2016 13-22-43');
        allNerveFibres = s.allNerveFibres;
        numFibres = s.numFibres;
        splineStartIndices = s.splineStartIndices;
        
        % Dummy field value to initialise the struct.
        fibres(100).numNodes = 50;
        
        for f = 1:numFibres
            splineStart = splineStartIndices(f);
            splineEnd   = splineStartIndices(f+1)-1;
            splineLen   = splineEnd - splineStart;
            fibres(f).coords = allNerveFibres(splineStart:splineEnd-1,:);
            fibres(f).numNodes = splineLen;
        end
        
        fibres.coords;
        [fibres.numNodes];
        %% Default colormap
        % Want usual hot colormap.
        hotMap = hot;
        % But also blue (cool) in the [0.53 0.54] range and red (hot) in [0.55 0.56]
        % range.
        
        % Default jet colormap is blue at 0 and red at 1.
        jetMap = jet;
        numMapPoints0 = length(jetMap);
        
        customMap = [hotMap;jetMap(1,:);jetMap(end,:)];
        numMapPoints = length(customMap);
        % Get the corresponding value between [0,1] for the colour. Has to be above
        % the usual map because the mask is superimposed i.e. higher numerical
        % value in the same "color map".
        scaleBlue = (numMapPoints0-1)/numMapPoints;
        scaleRed = 1;
        %% Find nearby nodes
        % Closest node x fibre(s) near electrodes (might be damaged/gone in
        % reality).
        % For each electrode, iterate over each fibre to find distances below
        % threshold. 
        hold on;
        for a = 1:length(activeElectrodes)
            e = activeElectrodes(a);
            c = inputCurrents(a);
            
            for f = 1:numFibres
                eCentre = eCentres(e,:);
                diffs_mm = fibres(f).coords - ones(fibres(f).numNodes,1)*eCentre;
                dists_mm(1:fibres(f).numNodes,f) = sqrt(sum(diffs_mm.^2,2));
            end
            dists_mm(dists_mm == 0) = NaN; % Don't want these plotted.
            %     f = figure('units','normalized','position',[0,0,0.5,1]);
            ax = gca;
            
            %% Draw the mask
            if c > 0
                % Positive terminal = red.
                % Semi-arbitrary z value to get red from customMap.
                zValue = max(ax.ZLim)*scaleRed;
            elseif c < 0
                % Negative terminal = blue.
                % Semi-arbitrary z value to get blue from customMap.
                zValue = max(ax.ZLim)*scaleBlue;
            else
                % Shouldn't be anything else!
                warning('Check electrode currents.')
            end
            
            proxThresholdF_mm = 2; % mm, set by visual inspection.
            
            thresMask = double(dists_mm < proxThresholdF_mm)*zValue;
            thresMask(thresMask==0) = NaN;
            hMask = surf(thresMask);
            hMask.EdgeAlpha = 0;
            
            if surfDistAsWell
                % Also plot the surface of distances
                hDist = surf(dists_mm/10);
                hDist.EdgeAlpha = 0.3;
                alpha(hDist,0.7)
            end
            
            colormap(customMap)
            
            %% Graph labels for testing out this function
            %     X = xlabel('Fibre No.');
            %     Y = ylabel('Node No.');
            %     Z = zlabel('Distance (mm)');
            
            %     C = colorbar;
            %     hcolor = colormap(ax,flipud(hot));
            %     ylabel(C,'Distance (mm)')
            %     view([46.5,38])
            %     view([0 0])
            %     alpha(hMask,1)
            %     caxis([0 12])
            %     caxis([0 2])
            %     caxis([5 10])
            %     caxis([-5 3])
            
            %     zlim([0 12])
            %     axis([0 numFibres 0 50 0 12])
%             titleStr = sprintf('Euclidean distance from nerve fibres to Electrode %d',e);
%             title(titleStr)
%             rotate3d
        end
        cRange = clims(2)-clims(1);
        cRangeNew = cRange*numMapPoints/numMapPoints0;
        caxis([clims(1),clims(1) + cRangeNew])
    end
end