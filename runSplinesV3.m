% runSplinesV2 but starting from the soma & moving out 
% runSplines but with
% specific node spacing as per Kalkman et al 2014, Briaire & Frijns 2006.


% close all
clear


doPlotSegs = 1;

doCompare = 0;
doSave = 0;
doPlotGreenwoodCurve = 0;
% numFibres = 3500;5
% numNodesRanvier = 10;
numFibres = 100;
numNodesRanvier1stPass = 10;

tstart = tic;
%% 1. Manually pick out 3D coordinates as "primary" nodes for splining.
%> Load from excel
fname = 'splining.xlsx';

scMediaOuter    = xlsread(fname,5);
scMediaInner    = xlsread(fname,6);
% spiralGangUpper = xlsread(fname,7);
% spiralGangLower = xlsread(fname,8);
% nTrunkRef       = xlsread(fname,9);
% nTrunkSpiral    = xlsread(fname,10);
nTrunkRef2      = xlsread(fname,11);

%> Reordering to go from basal to apical (for consistency with literature).
scMediaOuter = scMediaOuter(end:-1:1,:);
scMediaInner = scMediaInner(end:-1:1,:);
nTrunkRef2 = nTrunkRef2(end:-1:1,:);

%> Manipulating reference guides
% Make it a complete loop.
% nTrunkRef2 = closeTheLoop(nTrunkRef2,5);

% Between the outer and inner splines of scala media.
numCoords = min(size(scMediaOuter,1),size(scMediaInner,1));
scMediaMiddle = (scMediaOuter(1:numCoords,:) + scMediaInner(1:numCoords,:))./2;

% Spiral generation.
direction = 1; % Direction of spiral.
turns = 2.6; % 2.6 turns in the cochlea
nTrunkRef2 = spiralPlanar(nTrunkRef2,turns,direction);

% Shift manually plotted guides around for more guides. 
% R = resize, S = shift.
% nTrunkRefShift1 = nTrunkRef + ones(size(nTrunkRef,1),1)*[13,-4,0];
% nTrunkRefShift2 = nTrunkRef + ones(size(nTrunkRef,1),1)*[14,-5,0];
nTrunkRef2S1 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[-5,3,0];
% nTrunkRef2S1 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[-4.6,2.6,0];
% nTrunkRef2S1 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[-4.45,2.4,0];
% nTrunkRef2S1 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[-4.85,2.8,0];
nTrunkRef2S2 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[0,-0.5,0.3];
nTrunkRef2S3 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[1.2,-0.7,0.6];

% Shrink guide loops for a tighter fit, using interval division.
nTrunkRef2S1R1 = resizeLoop(nTrunkRef2S1,7/16);
nTrunkRef2R1  = resizeLoop(nTrunkRef2,2/3);
nTrunkRef2S2R1 = resizeLoop(nTrunkRef2S2,3/4);
nTrunkRef2S3R1  = resizeLoop(nTrunkRef2S3,9/8);
nTrunkRef2S1R1R1 = resizeLoop(nTrunkRef2S1R1,7/8);

% More shifting.
nTrunkRef2S1R1S1 = nTrunkRef2S1R1   + ones(size(nTrunkRef2,1),1)*[-0.8,0.8,0];
nTrunkRef2S1R1R1S1 = nTrunkRef2S1R1R1   + ones(size(nTrunkRef2,1),1)*[-0.5,0.5,0];
nTrunkRef2S1R1R1S1 = nTrunkRef2S1R1R1   + ones(size(nTrunkRef2,1),1)*[-0.07,-0.01,0];
nTrunkRef2S1R1S1S1R1 = resizeLoop(nTrunkRef2S1R1S1 + ones(size(nTrunkRef2,1),1)*[1,-1,0.1],2);
nTrunkRef2S2R1S1 = nTrunkRef2S2R1   + ones(size(nTrunkRef2,1),1)*[0,1,0.3];

cp3dSets = {...,
    %     scMediaOuter        ,'Scala media outer';
    %     scMediaMiddle       ,'Scala media middle';
    scMediaInner        ,'Scala media inner'; % Config 1, Cf2
    %     spiralGangUpper     ,'Spiral ganglion upper';
    %     spiralGangLower     ,'Spiral ganglion lower';
%     nTrunkRef           ,'Nerve trunk ref'; % Config 1, Cf2
    %     nTrunkRef2Shift1    ,'Nerve trunk ref 2 shift 1';
%     nTrunkRef2S1R1R1S1       ,'Resized nerve trunk ref 2 shift 1 shift 2';
    nTrunkRef2S1R1         ,'Resized nerve trunk ref 2 shift 1 resize 1'; % Config 1, Cf2
%     nTrunkRef2S1R1S1       ,'Resized nerve trunk ref 2 shift 1 resize 1 shift 1';
%     resizedR2S1S1       ,'Resized nerve trunk ref 2 shift 1 shift 1';
    %     nTrunkRef2          ,'Nerve trunk ref 2';
    %     resizedR2          ,'Resized nerve trunk ref 2';
    nTrunkRef2S2R1         ,'Resized nerve trunk ref 2 shift 2'; % Config 1, Cf2
%     resizedR2S2S1       ,'Resized nerve trunk ref 2 shift 2 shift 1'; % 
%     resizedR2S1S2R1       ,'Resized nerve trunk ref 2 shift 2 shift 2'; % 
    %     nTrunkRef2Shift2    ,'Nerve trunk ref 2 shift 2';
    nTrunkRef2S3R1         ,'Resized nerve trunk ref 2 shift 3'; % Config 1
    %     nTrunkRefShift1          ,'Nerve trunk shift 1';
    %     nTrunkRefShift2          ,'Nerve trunk shift 2';
    %     nTrunkSpiral        ,'Nerve trunk spiral';
    };

numSets = size(cp3dSets,1);

legendStr = cell(2*numSets,1);
for sCat = 1 : numSets
    legendStr{2*sCat-1} = [cp3dSets{sCat,2} ' cut points'];
    legendStr{2*sCat}   = [cp3dSets{sCat,2} ' spline'];
end


%% 2. Spline the primary nodes, creating "wavefronts" of nerve fibres and secondary nodes.
% Each second order node represents where its nerve fibre intersects with
% the wavefront, and serves as a node for the next spline.

%> Set up constants
% Number of fibres desired
% for fibre_count = round(linspace(10,100,5))

%> Spline them.
% Notify start of script
% fprintf('Extrapolating coordinates of auditory nerve fibres.\n');
% fprintf('Number of fibres = %d\n',numFibres);
primDesc = sprintf('%d primary splines (along structures)',numSets);
fprintf(['\nInterpolating ' primDesc '...\n']);


% Logarithmically distribute nerves to represent logarithmic distribution
% of tonotopy.
% 3500 IHCs
% Considerations:
% - minimum distance between IHCs
% - minimum distance between electrodes (Cochlear's 22-electrode array
% as example): 0.30 mm would put electrodes side-by-side

% sqrt(sum((eCoords(1:4,:) - eCoords(2:5,:)).^2,2)) gives 0.30 mm(?) width
% (along cochlear length), 0.55 mm(?) height (apical-basal). eCoords is a 5
% x 3 array of the loop used to plot the 4 vertices of each electrode.

tic
fibreSpacing = logspace(0,log(2)/log(10),numFibres)-1;

for sCat = 1 : numSets
    %     primarySplines{s} = splining(cp3dSets{s,1},numFibres);
    coords = splining(cp3dSets{sCat,1},fibreSpacing);
    primarySplines{sCat} = coords;
end
toc

%


%% Refining splining guides (comment out when done)
% 
% f = figure('units','normalized','position',[0.5,0,0.5,1]); 
% % uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/ScMedia.fig',1)
% % uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/SpGang.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/NTrunk.fig',1)
% 
% rotate3d
% colormap(flipud(jet))
% %
% view(2)
% % axis([53 57 96 97.5 132 134])
% axis([53 58 94.7 97.5 132.5 133.5])
% %
% hold on;
% for sCat = 1:numSets
%     coords  =  primarySplines{sCat} ;
%     
%     x = coords(:,1);y = coords(:,2); z = coords(:,3);
% %     plot3(x,y,z)
%     plotSplines(cp3dSets{sCat,1},coords)
% end
% axis auto
% 
% % plotSplines(nTrunkRef2,nan(size(nTrunkRef2,1),size(nTrunkRef2,2)))
% 
% error('terminate')
% % % % %> Compare with the originals
% % % plotxyz(cSpGang)
% % plotxyz(scMediaInner)
% % plotxyz(cNTrunk)
% % plotxyz(cCNVIII)error('stop')



%% 2b. Frequency mapping
% REF: Greenwood 1990

% Since fibreSpacing is logarithmically spaced along 0 to 1, conveniently
% use Greenwood function f = A*(10^(a*x) - k) for x as a proportion of total
% basilar membrane length (from 0 to 1), to get frequency f.
A = 165.4;
k = 0.88;
a = 2.1;
% Array f of frequencies corresponding to relative locations in fibreSpacing
fMap = A*(10.^(a*fibreSpacing) - k);

% DEPRECATED. USE plotGreenwood.m which loads the fMap etc saved in this
% script.

% if doPlotGreenwoodCurve
%     figure;
%     % plot(fibreSpacing,fMap)
%     semilogy(fibreSpacing,fMap)
%     
%     xlabel('Relative distance from apex to base of cochlea, x')
%     ylabel('Frequency (Hz)')
%     title('Greenwood function for the human cochlea')
%     textStr = ['f' ' = A\times(10^{ax} - k) \newline',...
%         'A = 165.4, a = 2.1, k = 0.88'];
%     
%     % textStr = 'A*10^{a \ast x} - k blah';
%     text('units','normalized','position',[0.05,0.85],'String',textStr,...
%         'fontsize',15,'Interpreter','tex')
% end


%% 3. Spline between "wavefronts", creating the nerve fibres and tertiary nodes (nodes of Ranvier).
% Create individual lengths of nerve fibres.
% 
% Array containing all sets of secondary nodes, meshed by the nth
% primary node. (numSets * 3) by (numFibres) matrix.
secondaryNodesArray = [];%zeros(numSets*3,numFibres);
for sCat = 1:numSets
    primaryNodes = primarySplines{sCat}';
    secondaryNodesArray = [secondaryNodesArray;primaryNodes];
end

secondarySplines = cell(numFibres,1);
secondaryNodesSets = cell(numFibres,1);

secDesc = sprintf('%d secondary splines (nerve fibres)',...
    numFibres);
fprintf(['\nInterpolating ' secDesc '...\n']);
tstart = tic;
for f = 1:numFibres
    % Create an array containing the points needed to spline along the nth
    % primary node across the datasets. Bit of matrix shape manipulation.
    secondaryNodes = zeros(3,numSets);
    secondaryNodes(:) = secondaryNodesArray(:,f);
    secondaryNodes = secondaryNodes';
    secondaryNodesSets{f} = secondaryNodes;
    
    % TODO make array for relative node locations according to GSEF. Need
    % to find lengths along spline and clarify how far along the nerve
    % trunk GSEF covers.
    secondarySplines{f} = splining(secondaryNodes,numNodesRanvier1stPass);
end
toc(tstart);
tstop = toc(tstart);
% fprintf('Seconds/numNodesRanvier between with %d nodes = %.4f\n',...
%     numNodesRanvier,tstop/(numNodesRanvier*numFibres));


%% 3b take two
secDesc = sprintf('secondary splines (nerve fibres)');
fprintf(['\nAdjusting ' secDesc '...\n']);
tstart = tic;

for f = 1:numFibres
    nodes = secondarySplines{f};  
    
    [nodeSpacingNorm,nodeSpacing] = segmentBSP(nodes);
    
    numSegs = length(nodeSpacing);
    nodeSpacings(f,1:numSegs) = nodeSpacing;
    nerveFibre = splining(nodes,nodeSpacingNorm);
    soma(f,:) = nerveFibre(10,:);

    secondarySplines{f} = [nerveFibre;nan(1,3)];

    % Reordered to go from basal to apical. Original direction is apical to
    % basal because that's how splining.xlsx was ordered.
%     secondarySplines{100-f+1} = [nerveFibre;nan(1,3)];
end
toc(tstart)
%% 


%% 4. Use the nodes of Ranvier as 3D cut points to evaluate in COMSOL.
% Use the output for the neural activating function.
allNodes = vertcat(secondaryNodesSets{:});
% For plotting: can't do a simple vertcat if using line plots, because each
% spline will link to the next spline, creating an unintended visual
% appearance. Padding it out with nans in section 3, and saving an array of
% the starting index of each nerve fibre spline. 
% Putting everything in one matrix in the first place to avoid 100
% for-loop iterations for plotting.
allNerveFibres = vertcat(secondarySplines{:});
splineStartIndices = [1;find(isnan(allNerveFibres(:,1)))+1];

%% Plotting

%>>> Visualise 3b
if doPlotSegs
    % barh([1;2],[nodeSpacing;nan(1,length(nodeSpacing))],'stacked'); % stacks values in each row together
    % set(gca,'yticklabel',{'Segments',''})
    % hbar = figure('units','normalized','position',[0.5,0,0.5,1]);
    hbar = figure('units','normalized','position',[0,0,1,1]);
    bar(1:numFibres,nodeSpacings,'stacked'); % stacks values in each row together
%     ylabel('Cumulative segment length starting from periphery (\mum)')
ylabel('Central \leftarrow Cumulative segment length (\mum) \rightarrow peripheral')
    xlabel('Fibre No. (from base)')
    set(gca,'YDir','reverse')
    title('Visualisation of nerve segment lengths')
    % legend({'Colours';'serve';'purely';'to';'visually';'differentiate';'between';'segments'},'location','southeast');
    % axis([0 max(sum(nodeSpacings,2)) 0 numFibres])
    axis([0.5 numFibres+0.5 0 max(sum(nodeSpacings,2))])
    % colormap(flipud(autumn))
    colormap(flipud(prism))
end

% Don't need primary splines because covered by Greenwood curve.
% >> Primary splines
% fprintf(['\nPlotting ' primDesc '...\n']);
% tic
% for s = 1 : numSets
%     plotSplines(cp3dSets{s,1},primarySplines{s})
%     %     pause(0.4)
% end
% toc

%>>> Frequency labels
% htxt = findall(gcf,'Type','text'); delete(htxt(1:end-3))
scMediaSpline = primarySplines{1};
numFreqLabels = 30;
freqIndices = round(linspace(1,numFibres,numFreqLabels)); 
% freqIndices(1) = 1;

% % In future runs only need this for loop to plot, with scMediaSpline, fMap,
% % and freqIndices saved in a .mat
% for freqIndex = freqIndices
%     coords = scMediaSpline(freqIndex,:);
%     x = coords(1);y = coords(2); z = coords(3);
%     freq = round(fMap(freqIndex));
%     text(x,y,z,[' ' num2str(freq) ' Hz'],'fontsize',12)
% end

%>>> Splining outcome
% Primary & secondary splines
hsplines = figure('units','normalized','position',[0.5,0,0.5,1]);
fprintf(['\nPlotting ' secDesc '...\n']);
tic
plotSplines(allNodes,allNerveFibres)
toc
legendStr = {'Primary splines (structures/guides)';
    'Secondary splines (nerve fibres)'};
legend(legendStr,'Location','SouthEast')

% Soma
sCat = scatter3(soma(:,1),soma(:,2),soma(:,3),50,'k','filled');

% Greenwood
% s = load('3500Fibres10Nodes.mat');
% s = load('greenwood100fibres.mat');
% s = load(filename);
plotGreenwood

% Array
plotArrayLabels

% axis([49 65 90.5 99.5 131 136])
set(findall(gcf,'-property','FontSize'),'FontName','Cambria')
set(findall(gcf,'-property','FontSize'),'FontSize',30)

%% Check proximity of electrodes to nodes of Ranvier
% Shouldn't be closer than say 0.4 mm from the centre of the electrode
% (0.55 mm is the longest dimension of the prism completely enclosing an
% electrode).
proxLim_mm = 0.55; 

% Don't need to check for every point in the spline because the nodes are
% sufficiently close together.

% Cell array electrodeLoops obtained from plotArrayLabels.
% eCoords = cell2mat(electrodeLoops)
% sqrt(sum((eCoords(1:end-1,:)-eCoords(2:end,:)).^2,2)

% Matrix of distances between each node and each electrode.
numNodes = length(allNerveFibres);
dists_mm = zeros(numNodes,22);
% eCentres obtained from plotArrayLabels.
for c = 1:length(eCentres)
    % Measure distance from the centre of the electrode.
    eCentre = eCentres(c,:);
    % Order of allNerveFibres (and splineStartIndices) is basal to apical,
    % peripheral to central.
    diffs_mm = allNerveFibres - ones(numNodes,1)*eCentre;
    dists_mm(1:numNodes,c) = sqrt(sum(diffs_mm.^2,2));    
end

tooClose = dists_mm(dists_mm < proxLim_mm);
% [nr,nc] = size(dists_mm);
for k = 1:length(tooClose)
    badDist = tooClose(k);
    [nodeInd,electrode] = find(dists_mm == badDist);
    nodeNumber = nodeInd + 1 - splineStartIndices;
    fibreNumber = find(nodeNumber == min(nodeNumber(nodeNumber>0)));
    nodeNumber = nodeNumber(fibreNumber);
%     fibreStartInd = cumsum(cellfun(@(x) length(x),secondarySplines))
%     fprintf('Node %d in fibre %d is less than %.2g mm from the centre of electrode %d.\n',...
%         nodeNumber,fibreNumber,proxLim_mm,electrode);
    warning('The centre of electrode %d is only %.2g mm from fibre %d node %d.',...
        electrode,badDist,fibreNumber,nodeNumber);
end



%%

% doCompare = 0;
if doCompare
    % Compare to original model.
    domSelection = 2 : 5;% numDoms;
    domSelection = [4 9];
    domSelection = [6 7 8 9]; % tympani, media, spiral ganglion, nerve trunk
    domSelection = [7 9]; % media, nerve trunk
    
    legendStr = vertcat(legendStr,domains{domSelection,2});
    for d = domSelection
        domain  = domains{d,1};
        plotxyz(domain)
        pause(0.5)
    end
    
    legend(legendStr,'Location','SouthEast')
end


if doSave
    %% Saving
    timeStamp = ['V' datestr(now,'ddmmHHMM')];
    
    filename = ['Spline' timeStamp];
%     filename = sprintf('splines%dFibres',numFibres);
%     filename = sprintf('%dFibres%dNodes',numFibres,numNodesRanvier);
    % Save unordered cut points for COMSOL evaluation.
    fileID = fopen([filename '.txt'],'w');
    fprintf(fileID,'%.3f,%.3f,%.3f\n',allNerveFibres');
    
    save(filename,'cp3dSets','allNerveFibres','soma','splineStartIndices','nodeSpacings','numFibres')
    savefig(filename)
    
    % Save frequencies, key points for plotting frequencies and coordinates
    % along structure.
    filename = sprintf('greenwoodF%d%s',numFibres,timeStamp);
    save([filename '.mat'],'fMap','freqIndices','scMediaSpline')

end

fprintf('\nTotal ')
toc(tstart)