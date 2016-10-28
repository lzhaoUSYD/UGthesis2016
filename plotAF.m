function numActiveFibres = plotAF(AFmap,activeFibres,AFthres,clims,name)


%% Figure set up
figWidth = 1/3;
hfig = figure('units','normalized');
% set(hfig, 'MenuBar', 'none');
% set(hfig, 'ToolBar', 'none');
set(hfig,'position',[1-figWidth,0,figWidth,1]);

set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% Configure subplot layout + general set up
rows = 2;
cols = 1;
n=rows*cols;
for k = 1:n
    hsp(k) = subplot(rows,cols,k);
end

xFibreStr = 'Basal $\leftarrow$ Fibre No. $\rightarrow$ Apical';
yNodeStr = 'Axon $\leftarrow$ Node No. $\rightarrow$ Process';
fnStr = '$f_{n}$ (V/s)';

% Fibres as landmarks for turns of the cochlea. Visually identified from
% view([-166.3916,1.5762])
turn180 = 40;
turn360 = 67;
turn540 = 79;
turn720 = 89;


%% Figure out which simulation it is, and the electrode settings
% As per runStimPatternsV4.m
% REF: Tran 2015
stim = strsplit(name,'_');
eConfig = stim{1};
% Reference electrode not in the sense of ground, but relative location on
% the array.
eRef = str2double(stim{2});
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
        %         e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
    case 'BP1'
        % Bipolar + 1.
        e1 = eRef;
        % Went for latter direction in simulations (could be either side).
        %         e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
    case 'BP2'
        % Bipolar + 2.
        e1 = eRef;
        % Went for latter direction in simulations (could be either side).
        %         e2 = e1 + 3; % e1 must be within [1,19]
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
        if strfind(eConfig,'pTP')
            % Partial tripolar.
            sigmaStr = eConfig(regexp(eConfig,'\d'));
            if strcmp(sigmaStr(1),'0')
                % Decimal sigma.
                sigmaStr = ['0.' sigmaStr(2:end)];
            end
            sigma = str2double(sigmaStr);
            
            e2 = eRef;
            e1 = e2 - 1;
            e3 = e2 + 1;
            
            activeElectrodes = [e1,e2,e3];
            inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
        elseif strfind(eConfig,'BP1x5')
            % One-off run of BP1 with 5x the current.
            % Bipolar + 1.
            e1 = eRef;
            % Went for latter direction in simulations (could be either side).
            %         e2 = e1 + 2; % e1 must be within [1,20]
            e2 = e1 - 2; % e1 must be within [3,22]
            
            activeElectrodes = [e1,e2];
            inputCurrents    = 5*[I0mA,-I0mA];
        end
end

%% Default colormap
%
% Adjusted colour limits for surf plot "hack" for overlaying/underlaying
% electrodes.
%
% Want usual hot colormap.
hotMap = hot(100);
hots = 70;
% whiteFiller = ones(ceil(hots*3/7),3);
whiteFiller = ones(ceil(0/4),3);
numFillers = length(whiteFiller);

% hotMapExtract = [hotMap(hots:end,:);whiteFiller];
hotMapExtract = [hotMap(end:-1:(100-hots),:);whiteFiller];
numHotPoints = length(hotMapExtract);

% Default jet colormap is blue at 0 and red at 1.
numProxHues = 20;
halfway = numProxHues/2;
jetMap = jet(100);
numJetPoints = length(jetMap);

% Skip through the map to get greater contrast.
% Lower values = darker colour. Good for proximity because stronger
% influence at lower proximity corresponds to this.
cStep = 1;
numBlues = numProxHues;
blueMap = jetMap(1:cStep:halfway*cStep,:);
numReds = numProxHues;
redMap = jetMap(end:-cStep:(end-(halfway*cStep-1)),:);


customMap = [hotMapExtract;whiteFiller;blueMap;redMap];
numMapPoints = length(customMap);

%>>> New colour scale = 3 scales: data, blues and reds
% Colour limits from actual data.
climsData = clims;
cMinData = climsData(1);
cMaxData = climsData(2);
cRangeData = cMaxData - cMinData;

cRangeNew = cRangeData*(numReds+numBlues+numFillers+numHotPoints)/numHotPoints;
climsNew = [cMinData,cMinData + cRangeNew];
cMinNew = climsNew(1);
cMaxNew = climsNew(2);

% Get the corresponding value between [cMin,cMax] for the colour. Has to be
% above the usual map because the mask is superimposed i.e. higher
% numerical value in the same "color map".

% Colour limits for red (positive electrodes).
% cMinReds = cMaxBlues + 1/numMapPoints;
% cMaxReds = cMinReds + (numReds-1)/numMapPoints;
cMaxReds = cMaxNew;
cMinReds = cMaxReds - (numReds-1)/2/numMapPoints*cRangeNew;
cRangeReds = cMaxReds - cMinReds;

% Colour limits for blue (negative electrodes).
% cMinBlues = cMaxData + (numFillers+1)/numMapPoints;
% cMaxBlues = cMinBlues + (numBlues-1)/numMapPoints;
cMaxBlues = cMinReds - 1/numMapPoints;
cMinBlues = cMaxBlues - (numBlues-1)/2/numMapPoints*cRangeNew;
cRangeBlues = cMaxBlues - cMinBlues;

% White at the bottom
cValueWhite = cMinData + (numFillers/2)/numMapPoints*cRangeNew;

% Colour values on the colormap. Somewhat arbitrary.
% fibreScale = 0.7;
cValueFibre   = cMinData + cRangeData/6;%*fibreScale; % Yellow
cValueMaxNode = cMinData + cRangeData*0.5; % Red/orange

cb = colorbar;

%% Side view
subplot(rows,cols,1)

ax2 = surf(AFmap);
ax2.EdgeAlpha = 0.2;
colormap(hot)
caxis(clims)
zlim(climsNew)

title('AF map')
X2 = xlabel(xFibreStr);
Y2 = ylabel('Node No.');
Z2 = zlabel(fnStr);

electrodeMask(activeElectrodes,inputCurrents,clims,1)

caxis(climsNew)
colormap(customMap)

view([0 0])
grid off

%% Fibres from f_n > vThres map
subplot(rows,cols,2)

% Number of active fibres.
numActiveFibres = length(activeFibres);

% Initialise cPlot with white colour value and NaNs.
cPlot = AFmap.^0 - 1 + cValueWhite;%- cMin + cRange*fibreScale*0.8;
% Colour the fibres.
cPlot(:,activeFibres) = cPlot(:,activeFibres).*0 + cValueFibre;

% Find the highest AF value in each active fibre.
activeMax = activeFibres*0;
for fNum = 1:numActiveFibres
    activeFibre = activeFibres(fNum);
    activeMax(fNum) = max(AFmap(:,activeFibre));
    activeMaxNode = find(AFmap(:,activeFibre) == activeMax(fNum));
    activeMaxNodes(fNum) = activeMaxNode;
    cPlot(activeMaxNode,activeFibre) = AFmap(activeMaxNode,activeFibre);
end

hsurf = surf(cPlot);
hsurf.EdgeAlpha = 0.05;
alpha(hsurf,0.998)


ax2 = gca;
htext = annotation('textbox');
set(htext, 'Parent', ax2);

legStr = {sprintf('%d',numActiveFibres);'active';'fibres'};
set(htext, 'units','normalized','Position', [78 37 .1 .1])

set(htext,'string',legStr);

ylim([0 50])

titleStrThres = sprintf('Depolarisation ($f_{n}>%.2g V/s$)',AFthres);
title(titleStrThres)
X3 = xlabel(xFibreStr);
Y3 = ylabel(yNodeStr);
view([0,-90])

grid off

electrodeMask(activeElectrodes,inputCurrents,clims,0)

caxis(climsNew)
colormap(customMap)

%% Layout config
% ------------------ 2x1 config ------------------
someAx = gca;
set(someAx.YLabel,'units','normalized');
yTextExtent = someAx.YLabel.Extent(3);

xLeft = 0.15;
xWidth = 1-xLeft*1.5;
yHeight = 0.4;
yBot3 = 0.07;
yBot1 = 1 - yHeight - 0.05;
yBot2 = yBot3 + yHeight + 0.11;
set(hsp(1),'units','normalized','Position',[xLeft,yBot1,xWidth,yHeight]);
set(hsp(2),'units','normalized','Position',[xLeft,yBot3,xWidth,yHeight]);

% % ------------------ 3x1 config ------------------
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


% ------------------ 2x2 config ------------------
% % Get info about axis labels, assuming all text the same font (as it should
% % be).
% someAx = gca;
% set(someAx.YLabel,'units','normalized');
% yTextExtent = someAx.YLabel.Extent(3);
%
% padding = 1.5;
% xLeft = yTextExtent*padding;
% xWidth = 0.5-xLeft*1.3;
% yHeight = 0.35;
% % topPadding = 0.06;
% yBot2 = 0.07;
% yBot1 = 1 - yHeight - 0.05;
% % yBot2 = yBot1 - yHeight - padding;
% % yBot2 = yBot3  + 0.11;
%
% % Left column
% set(hsp(1),'units','normalized','Position',[xLeft yBot1 xWidth yHeight]);
% set(hsp(3),'units','normalized','Position',[xLeft yBot2 xWidth yHeight]);
% % set(hsp(5),'units','normalized','Position',[xLeft yBot3 xWidth yHeight]);
%
% set(C2,'Location','northoutside')
%
% % Right column
% xLeft2 = 0.5 + xLeft;
%
% set(hsp(2),'units','normalized','Position',[xLeft2 yBot1 xWidth yHeight]);
% set(hsp(4),'units','normalized','Position',[xLeft2 yBot2 xWidth yHeight]);
%

% ------------------ 3x2 config ------------------
% xLeft = 0.12;
% xWidth = 0.5-xLeft*1.5;
% yHeight = 0.2;
% % topPadding = 0.06;
% yBot3 = 0.07;
% yBot1 = 1 - yHeight - 0.05;
% % yBot2 = yBot1 - yHeight - padding;
% yBot2 = yBot3 + yHeight + 0.11;
%
% % Left column
% set(hsp(1),'units','normalized','Position',[xLeft yBot1 xWidth yHeight]);
% set(hsp(3),'units','normalized','Position',[xLeft yBot2 xWidth yHeight]);
% set(hsp(5),'units','normalized','Position',[xLeft yBot3 xWidth yHeight]);
%
% set(C2,'Location','northoutside')
%
% % Right column
% xLeft2 = 1 - xWidth - xLeft;
% set(hsp(2),'units','normalized','Position',[xLeft2 yBot1 xWidth yHeight]);
% set(hsp(4),'units','normalized','Position',[xLeft2 yBot2+0.05 xWidth yHeight]);
% set(hsp(6),'units','normalized','Position',[xLeft2 yBot3 xWidth yHeight]);
% %

%% Text config


lname = strrep(name,'_',' ');
suptitleStr1 = ['{Activating function: ' lname ,'}'];
suptitleStr2 = '\centering{Electrode influence overlayed}';
sup = suptitle({suptitleStr1,suptitleStr2});

rotate3d
set(findall(gcf,'-property','FontSize'),'FontSize',16.5)

C2 = colorbar;
caxis(climsNew)
ylabel(C2,'f_n (V/s)')
set(C2,'Location','northoutside')
set(C2,'FontSize',13)
set(C2,'Limits',clims)

set(sup,'FontSize',20)


    function electrodeMask(activeElectrodes,inputCurrents,clims,doLabelElectrode)
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
        s = load('spiralSplineNew');
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
            
            % Normalised between 0 and 1 for visualisation.
            dists_norm = dists_mm./max(max(dists_mm));
            
            %% Draw the mask
            proxThresholdF_mm = 2; % mm, set by visual inspection.
            
            % Get a mask containing only values less than 2 mm. Everything
            % else NaN.
            proxMask = dists_mm.*(dists_mm < proxThresholdF_mm);
            proxMask(proxMask==0) = NaN;
            % Normalise to between 0 and 1.
            maxProxMask = max(max(proxMask));
            minProxMask = min(min(proxMask));
            normRange = maxProxMask - minProxMask;
            normProxMask = (proxMask-minProxMask)./normRange;
            
            if c > 0
                % Positive terminal = red.
                eSign = '+';
                % Semi-arbitrary z value to get red from customMap.
                proxCloud = cMinReds + cRangeReds*normProxMask;
            elseif c < 0
                % Negative terminal = blue.
                eSign = '\textendash';
                % Semi-arbitrary z value to get blue from customMap.
                proxCloud = cMinBlues + cRangeBlues*normProxMask;
            else
                % Shouldn't be anything else!
                warning('Check electrode currents.')
            end
            
            if doLabelElectrode
                % Label the electrode.
                minProxCloud = min(min(proxCloud));
                [node,fibre] = find(proxCloud == minProxCloud);
                % Hard to fit two rows.
                eStr = {['\bf E' num2str(e) eSign]};
                
                % Position so as not to overlap labels
                switch a
                    case 1
                        text(fibre,node,minProxCloud,eStr,'horizontalalignment','right')
                    case 2
                        text(fibre,node,minProxCloud,eStr,'horizontalalignment','center')
                    case 3
                        text(fibre,node,minProxCloud,eStr,'horizontalalignment','left')
                end
            end
            
            hMask = surf(proxCloud);
            hMask.EdgeAlpha = 0;
            alpha(hMask,0.3)
            
            
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
    end
end