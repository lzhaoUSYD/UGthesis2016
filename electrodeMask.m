%% DEPRECATED. CALLED INSIDE plotAF.m

function electrodeMask(electrodes,signs)
% EXTENSION: gradient, using more values from jet. Probably cut one color
% triplet from hot (leaving 76 triplets) and pad with 12 blueish, 12
% reddish triplets.

% clear

%% Electrode locations
% Get electrode locations in 3D space.
% load('arrayCoords.mat')
load('electrodesOrdered.mat')
% eCentres = cell2mat(eCentres);

% Get nerve fibre splines.
load('spiralSplineNew');
% potDir = fullfile(pwd,'Outputs','Potentials');
% fullAdd = fullfile(potDir,'MP'); % Any set will do.
% load(fullAdd);

% xyz = xyzV(:,1:3);
% numCoords = length(xyz);
%             numNodes = 20;
%             numFibres = numCoords/numNodes; %40;
numFibres = 100; % As per abstract.

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
% Want usual hot colormap below
hotMap = hot;
% caxis([-0.8614 0.5244])
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

%%
% close all
% For each electrode, iterate over each fibre to find distances below
% threshold.
% dThres = ;
hold on;
for e = 2%:22
    for f = 1:numFibres
        eCentre = eCentres(e,:);
        diffs_mm = fibres(f).coords - ones(fibres(f).numNodes,1)*eCentre;
        dists_mm(1:fibres(f).numNodes,f) = sqrt(sum(diffs_mm.^2,2));
    end
    dists_mm(dists_mm == 0) = NaN; % Don't want these plotted.
%     f = figure('units','normalized','position',[0,0,0.5,1]);
    ax = gca;
    
    % Semi-arbitrary z value to get red from customMap.
    zValuePos = max(ax.ZLim)*scaleRed; 
    % Semi-arbitrary z value to get blue from customMap.
    zValueNeg = max(ax.ZLim)*scaleBlue;
    
    thresMaskPos = double(dists_mm < 2)*zValuePos;
    thresMaskPos(thresMaskPos==0) = NaN;
    hMaskPos = surf(thresMaskPos);
    hMaskPos.EdgeAlpha = 0;
    
    thresMaskNeg = double(dists_mm < 2)*zValueNeg;
    thresMaskNeg(thresMaskNeg==0) = NaN;
    hMaskNeg = surf(thresMaskNeg);
    hMaskNeg.EdgeAlpha = 0;
    
    colormap(customMap)
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
    titleStr = sprintf('Euclidean distance from nerve fibres to Electrode %d',e);
    title(titleStr)
    rotate3d
end



%%

% Closest node x fibre(s) near electrodes (might be damaged/gone in
% reality). Soma is always 9th (as visual reference point).

% Create a map for each electrode
% elecProxMaps = cell(22,1);
% numNodes = 50;
% numFibres = 100;
% 
% 
% elecProx = nan(numNodes,numFibres);
% % splineSpiralWithELabelsView1.fig
% % 1:16 neatly outside periphery
% elecProx(0,1:16) = 1;
% % splineSpiralWithELabelsView2.fig
% % E17: F = 8:13; N = [14 14 13 13 12 12];
% % E18: F = 18:21; N = [10 9 9 9];
% E19: F = 24:27; N = [7:8,7:8,7:8,6:8];
% E20: F =
% elecProx(
% splineSpiralWithELabelsView3.fig
