close all

doCompare = 0;
doSave = 1;
doPlotGreenwood = 0;

% numFibres = 3500;
% numNodesRanvier = 10;
numFibres = 100;
% numNodesRanvier = 20;


%% 1. Manually pick out 3D coordinates as "primary" nodes for splining.
%> Load from excel
fname = 'splining.xlsx';

scMediaOuter    = xlsread(fname,5);
scMediaInner    = xlsread(fname,6);
spiralGangUpper = xlsread(fname,7);
spiralGangLower = xlsread(fname,8);
nTrunkRef       = xlsread(fname,9);
nTrunkSpiral    = xlsread(fname,10);
nTrunkRef2      = xlsread(fname,11);

%> Manipulating reference guides
% Make it a complete loop.
nTrunkRef2 = closeTheLoop(nTrunkRef2,5);

% Between the outer and inner splines of scala media.
numCoords = min(size(scMediaOuter,1),size(scMediaInner,1));
scMediaMiddle = (scMediaOuter(1:numCoords,:) + scMediaInner(1:numCoords,:))./2;

% Shift manually plotted guides around for more guides. These shifts aren't
% quite accurate.
% nTrunkRefShift1 = nTrunkRef + ones(size(nTrunkRef,1),1)*[13,-4,0];
% nTrunkRefShift2 = nTrunkRef + ones(size(nTrunkRef,1),1)*[14,-5,0];
nTrunkRef2Shift1 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[-5,3,0];
nTrunkRef2Shift2 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[0,-0.5,0.3];
nTrunkRef2Shift3 = nTrunkRef2 + ones(size(nTrunkRef2,1),1)*[1,-0.5,0.6];

% Shrink guide loops for a tighter fit, using interval division.
resizedR2S1 = resizeLoop(nTrunkRef2Shift1,1/4);
resizedR2  = resizeLoop(nTrunkRef2,2/3);
resizedR2S2 = resizeLoop(nTrunkRef2Shift2,7/8);
resizedR2S3  = resizeLoop(nTrunkRef2Shift3,9/8);


cp3dSets = {...,
%     scMediaOuter        ,'Scala media outer';
    %     scMediaMiddle       ,'Scala media middle';
    scMediaInner        ,'Scala media inner';
    %     spiralGangUpper     ,'Spiral ganglion upper';
    %     spiralGangLower     ,'Spiral ganglion lower';
    nTrunkRef           ,'Nerve trunk ref';
    %     nTrunkRef2Shift1    ,'Nerve trunk ref 2 shift 1';
    resizedR2S1         ,'Resized nerve trunk ref 2 shift 1';
    %     nTrunkRef2          ,'Nerve trunk ref 2';
%     resizedR2          ,'Resized nerve trunk ref 2';
    resizedR2S2        ,'Resized nerve trunk ref 2 shift 2';
%     nTrunkRef2Shift2    ,'Nerve trunk ref 2 shift 2';
    resizedR2S3        ,'Resized nerve trunk ref 2 shift 3';
    %     nTrunkRefShift1          ,'Nerve trunk shift 1';
    %     nTrunkRefShift2          ,'Nerve trunk shift 2';
    %     nTrunkSpiral        ,'Nerve trunk spiral';
    };

numSets = size(cp3dSets,1);

legendStr = cell(2*numSets,1);
for s = 1 : numSets
    legendStr{2*s-1} = [cp3dSets{s,2} ' cut points'];
    legendStr{2*s}   = [cp3dSets{s,2} ' spline'];
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
primDesc = sprintf('%d primary splines (along structures)',numFibres);
fprintf(['\nInterpolating ' primDesc '...\n']);
tic

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

fibreSpacing = logspace(0,log(2)/log(10),numFibres)-1;

for s = 1 : numSets
%     primarySplines{s} = splining(cp3dSets{s,1},numFibres);
    primarySplines{s} = splining(cp3dSets{s,1},fibreSpacing);
end
toc

% % % %> Compare with the originals
% plotxyz(cSpGang)
% plotxyz(cScMedia)
% plotxyz(cNTrunk)
% plotxyz(cCNVIII)


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

if doPlotGreenwood
    figure;
    % plot(fibreSpacing,fMap)
    semilogy(fibreSpacing,fMap)
    
    xlabel('Relative distance from apex to base of cochlea, x')
    ylabel('Frequency (Hz)')
    title('Greenwood function for the human cochlea')
    textStr = ['f' ' = A\times(10^{ax} - k) \newline',...
        'A = 165.4, a = 2.1, k = 0.88'];
    
    % textStr = 'A*10^{a \ast x} - k blah';
    text('units','normalized','position',[0.05,0.85],'String',textStr,...
        'fontsize',15,'Interpreter','tex')
end
%% 3. Spline between "wavefronts", creating the nerve fibres and tertiary nodes (nodes of Ranvier).
% Create individual lengths of nerve fibres. 
% REF: Kalkman et al 2014, Briaire & Frijns 2006.
% nodeSpacing = [


% Array containing all sets of secondary nodes, meshed by the nth
% primary node. (numSets * 3) by (numFibres) matrix.
secondaryNodesArray = [];%zeros(numSets*3,numFibres);
for s = 1:numSets
    primaryNodes = primarySplines{s}';
    secondaryNodesArray = [secondaryNodesArray;primaryNodes];
end

secondarySplines = cell(numFibres,1);
secondaryNodesSets = cell(numFibres,1);

secDesc = sprintf('%d secondary splines (nerve fibres)',...
    numFibres*numNodesRanvier);
fprintf(['\nInterpolating ' secDesc '...\n']);
tstart = tic;
for f = 1:numFibres
    % Create an array containing the points needed to spline along the nth
    % primary node across the datasets.
    secondaryNodes = zeros(3,numSets);
    secondaryNodes(:) = secondaryNodesArray(:,f);
    secondaryNodes = secondaryNodes';
    secondaryNodesSets{f} = secondaryNodes;
    
    % TODO make array for relative node locations according to GSEF. Need
    % to find lengths along spline and clarify how far along the nerve
    % trunk GSEF covers.
    secondarySplines{f} = splining(secondaryNodes,numNodesRanvier);
end
toc(tstart);
tstop = toc(tstart);
fprintf('Seconds/numNodesRanvier between with %d nodes = %.4f\n',...
    numNodesRanvier,tstop/(numNodesRanvier*numFibres));

%% 4. Use the nodes of Ranvier as 3D cut points to evaluate in COMSOL.
% Use the output for the neural activating function.
import2comsol = vertcat(secondarySplines{:});

%% Plotting
figure('units','normalized','position',[0.5,0,0.5,1]);

%>> Primary splines
fprintf(['\nPlotting ' primDesc '...\n']);
tic
for s = 1 : numSets
    plotSplines(cp3dSets{s,1},primarySplines{s})
    %     pause(0.4)
end
toc

%>> Frequency labels
% htxt = findall(gcf,'Type','text'); delete(htxt(1:end-3))
scMediaSpline = primarySplines{1};
numFreqLabels = 12;
freqIndices = round(linspace(0,numFibres,numFreqLabels));
freqIndices(1) = 1;

% In future runs only need this for loop to plot, with scMediaSpline, fMap,
% and freqIndices saved in a .mat
for freqIndex = freqIndices
    coords = scMediaSpline(freqIndex,:);
    x = coords(1);y = coords(2); z = coords(3);
    freq = round(fMap(freqIndex));
    text(x,y,z,[' ' num2str(freq) ' Hz'],'fontsize',12)
end
    
%>> Secondary splines
fprintf(['\nPlotting ' secDesc '...\n']);
tic
for f = 1:numFibres
    plotSplines(secondaryNodesSets{f},secondarySplines{f})
    %     pause(0.001)
end
toc

legendStr = {'Primary splines';
    'Secondary splines'};
legend(legendStr,'Location','SouthEast')

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

%% Saving
if doSave
    filename = ['Spline attempt ' datestr(now)];
    filename = sprintf('%dFibres%dNodes',numFibres,numNodesRanvier);
    % Save unordered cut points for COMSOL evaluation.
    fileID = fopen([filename '.txt'],'w');
    fprintf(fileID,'%.3f,%.3f,%.3f\n',import2comsol');
    
    % Save frequencies, key points for plotting frequencies and coordinates
    % along structure.
    save([filename '.mat'],'fMap','freqIndices','scMediaSpline')
end
