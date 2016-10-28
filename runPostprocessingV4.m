% runPostprocessing but accounting for variable spline lengths (and hence
% variable xyzV lengths).



close all
clear global
clc

doBP1x5 = 0;
doPlot = 0;
doComputeAF = 0;
doCountFibres = 1;
doVisualise = 1;
doVidRotate = 0;
doSavePNG = 0;
doPlotSpecificity = 0;

set(0,'defaultTextInterpreter','latex');
set(0,'defaulttextfontsize',18);


% fnames = {...
%     'Monopolar 12-Aug-2016 09-45-02.mat';
%     'Bipolar 12-Aug-2016 09-45-02.mat';
%     'Bipolar+1 12-Aug-2016 09-45-02.mat';
%     'Bipolar+2 15-Aug-2016 15-36-33.mat';
%     'Tripolar 15-Aug-2016 15-36-33.mat'};

% timeStamp = '19-Sep-2016 18-15-25';
% timeStamp1 = '21-Sep-2016 13-28-49';
%
% fnames = {...
%     ['Monopolar ' timeStamp1 '.mat'];
%     ['Bipolar '   timeStamp1 '.mat'];
% %     ['BP+1 '      timeStamp '.mat'];
% %     ['BP+2 '      timeStamp '.mat'];
% %     ['Tripolar '  timeStamp '.mat'];
%     };
%
% timeStamp2 = '23-Sep-2016 13-21-53';
% fnames = {...
%     ['Monopolar ' timeStamp1 '.mat'];
%     ['Bipolar '   timeStamp1 '.mat'];
%     ['BP+1 '      timeStamp2 '.mat'];
%     ['BP+2 '      timeStamp2 '.mat'];
%     ['Tripolar '  timeStamp2 '.mat'];
%     };
%
% timeStamp = timeStamp2;

% fnames = {...
%     'MP';
%     'BP';
%     'BP1';
%     'BP2';
%     'TP';
%     'pTPsig2';
%     'pTPsig033';
%     };
if doBP1x5
    fnames = {...
        'MP';
        'BP';
        'BP1';
        'BP1x5';
        'BP2';
        'TP';
        'pTPsig067';
        'pTPsig033';
        };
else
    fnames = {...
        'MP';
        'BP';
        'BP1';
        'BP2';
        'TP';
        'pTPsig067';
        'pTPsig033';
        };
end


% ONE-OFF for the BP+1 case with 5x I0.
% fnames = {'BP1x5'};

timeStamp = '';

AFdir = fullfile(pwd,'Outputs','AF');
potDir = fullfile(pwd,'Outputs','Potentials');
pubDir = fullfile(pwd,'html');
vidDir = fullfile(pwd,'Outputs','vid');

for f = 1:length(fnames)
    fname = fnames{f};
    simStr = fname(1:min(strfind(fname,' '))-1);
    modeNames{f} = simStr;
    fullAdd = fullfile(potDir,fname);
    load(fullAdd);
end

% Cell array of results, each of which is a 22x3 cell array of
% [xyzV,activeElectrodes,inputCurrents]
if doBP1x5
    dataStimModes = {...,
        MPresult;
        BPresult;
        BP1result;
        BP1x5result;
        BP2result;
        TPresult;
        pTPsig067result;
        pTPsig033result;
        };
else
    dataStimModes = {...,
        MPresult;
        BPresult;
        BP1result;
        BP2result;
        TPresult;
        pTPsig067result;
        pTPsig033result;
        };
end


% ONE-OFF for the BP+1 case with 5x I0.
% dataStimModes = {BP1x5result};

numModes = length(dataStimModes);
mArray = 1:numModes;
if doBP1x5
    configSets = {...
        1:22;
        2:22;
        3:22;
        3:22;
        4:22;
        2:21;
        2:21;
        2:21;
        };
else
    configSets = {...
        1:22;
        2:22;
        3:22;
        4:22;
        2:21;
        2:21;
        2:21;
        };
end

% ONE-OFF for the BP+1 case with 5x I0.
% configSets = {3:22};

maxNumConfigs = max(cellfun(@(x) length(x),configSets));
numConfigs = sum(cellfun(@(x) length(x),configSets));
AFresult = cell(numModes,maxNumConfigs);

% Initialise variables to be loaded inside functions to be called.
electrodes = [];
%%

% n x 4 matrix. [x,y,z,V].
% allMP = cell2mat(MPresult(:,1));
% s = surf(allMP)
% s.EdgeAlpha = 0.1;


%% n x 22 matrix for V of every simulation within one mode.
% simV = cell2mat(cellfun(@(x) x(:,4),MPresult(:,1),'uniformoutput',0)');
% s(1) = surf(simV);
% xlabel('Electrode');
% xlim([1 22])
% ylabel('Coordinate')
% zlabel('Voltage (V)')
% 
% s(1).EdgeAlpha = 0.1;
% alpha(s(1),0.5);
% grid off

%% Run everything through plotV again for consistency
% Then runMakeVideo, maybe in batches with close all after every 10 figs.

% To figure out how the coordinate data is ordered. Ordered along nerve
% fibres, from apical to basal. Current implementation has 20 equally
% spaced nodal points along each fibre. 800 coordinate points so 40 fibres.
% for i = 1:19
% x = xyzV(i,1);
% y = xyzV(i,2);
% z = xyzV(i,3);
% text(x,y,z,'x')
% pause(0.1)
% end

%% Check that mphsave works together with results
% simDir = fullfile(pwd,'Outputs','simulations');
% modelNames = {'Monopolar_2';
%     'Monopolar_3'};
% for m = 1:length(modelNames)
%     mName = modelNames{m};
%     modelAddress = fullfile(simDir, mName);
%     [simC_mA,simV] = loadSimFn(modelAddress);
%     stimC(:,m) = simC_mA;
%     stimV(:,m) = simV;
% end

%% Calculate activating function

if doComputeAF
    %% Physiological parameters
    
    % [Rattay 2001, Table 1] Cochlear neuron resistivity (same as for cat).
    Rintra = 0.05e3; % kOhm.cm
    Rextra = 0.3e3;  % kOhm.cm
    Cm_F_on_cm2 = 1e-6;  % 'C_m', capacitance of cell membrane (one layer).
    
    % [Rattay 1999, Table 2] Membrane capacitance, should be specified for
    % each node n.
    %     Cm = 3e-12;  % Small soma, far or near field.
    %     Cm = 28e-12; % Large soma, far or near field.
    %     Cm = 0.37;   % Initial segment.
    
    % [Rattay 1999, Table 2] Axoplasmic resistance, should be specified for
    % each node n.
    RaHalf_ohm = 146e3;  % Small soma, far or near field. Soma to initial segment.
    RaHalf_ohm = 72e3;   % Large soma, far or near field. Soma to initial segment.
    %     RaHalf_ohm = 955e3;   % Initial segment.
    
    % [Rattay 1999, Table 1] Model data.
    % Dendrite
    dDend_cm = mean([4,4,1]) * 1e-4; % 3 neurons measured by Rattay 1999. 'd', cm
    dAxon_cm = 2e-4; % 'd', cm
    % TODO implement this for each segment?
    lenAxonSeg_cm = 500e-6 * 100; % '\delx', cm
    d = dAxon_cm;
    
    % TODO stop double accounting for R/2
    rhoi_ohmcm = RaHalf_ohm/2/lenAxonSeg_cm*dAxon_cm^2*pi; % 'rho_i', ohm.m
    cm_F_on_cm2 = Cm_F_on_cm2/dAxon_cm/lenAxonSeg_cm/pi; % 'c_m', specific cell capacitance
    
    % Term in front of what Paul used.
    fn_constant = d/(4*rhoi_ohmcm*cm_F_on_cm2);
    
    for m = mArray%1%:numModes
        m;
        % Individual stimulation mode (BP TP, pTP etc)
        dataStimMode = dataStimModes{m};
        fname = fnames{m};
        simStr = fname(1:min(strfind(fname,' ')));
        simStr = fname;
        
        elecConfigs = configSets{m};
        for c = elecConfigs%(1)
            %% Set up data
            % Individual electrode configuration (+1/-2, -3/+4/-5, etc)
            dataElecConfig = dataStimMode(c,:);
            
            allxyzV = cell2mat(dataStimMode(:,1));
            %             allV = allxyzV(:,4);
            %             minV = min(allV);
            %             maxV = max(allV);
            % f1 = plotV(dataElecConfig)
            xyzV = dataElecConfig{1}; % 2 for electrode numbers, 3 for currents.
            
            
            % Get allNerveFibres (spline coordinates), soma (coordinates)
            % and splineStartIndices (because allNerveFibres is one massive
            % matrix).
            
            %             load('Spline attempt 20-Sep-2016 13-22-43');
            %             load('Spline attempt 30-Sep-2016 16-22-06')
            load('spiralSplineNew')
            %             load('spiralSpline');
            AFmapLength = size(nodeSpacings,2);
            %             load('spiralSpline.mat')
            %             maxSplineLen = max(abs(splineStartIndices(2:end)-splineStartIndices(1:end-1)));
            
            % TODO REMEMBER TO REMOVE THIS
            % Dummy V values, sans actual Comsol simulation.
            %             xyzV = [allNerveFibres,rand(length(allNerveFibres),1)];
            
            V = xyzV(:,4);
            numCoords = length(V);
            %             numNodes = 20;
            %             numFibres = numCoords/numNodes; %40;
            numFibres = 100; % As per abstract.
            
            for f = 1:numFibres
                splineStart = splineStartIndices(f);
                splineEnd   = splineStartIndices(f+1)-1;
                splineLen   = splineEnd - splineStart + 1;
                Vmap(1:splineLen,f) = V(splineStart:splineEnd);
            end
            Vmap(Vmap == 0) = NaN;
            %             Vfibres = reshape(V,maxSplineLen,numFibres);
            %             Vfibres = Vfibres';
            
            AFmap = nan*Vmap; % V/s
            %% AF using Rattay 1999, Eqn 3
            % for loop and predefined "reach" i.e. # of neighbours
            %             % TODO more elegant implementation. syms, but slower?
            %             fnReach = 5; % How far down the road from compartment n (two-sided).
            %             for f = 1:numFibres
            %                 for n = fnReach+1:numNodes-fnReach
            %                     Vn = Vfibres(n,f);
            %                     Rn = RaHalf*2; % TODO R(n);
            %                     AFtemp = 0;
            %                     % Rattay 1999, Eqn 3
            %                     for k = 1:fnReach % TODO Extend to as far as node count goes.
            %                         Vleft  = Vfibres(n-k,f); % Vn-1, Vn-2, etc.
            %                         Vright = Vfibres(n+k,f); % Vn+1, Vn+2, etc.
            %                         Rleft  = Rn; % TODO R(n-k,f); % Rn-1, Rn-2, etc.
            %                         Rright = Rn; % TODO R(n+k,f); % Rn+1, Rn+2, etc.
            %                         AFtemp = AFtemp + (Vleft-Vn)/(Rleft+Rn)/2 + (Vright-Vn)/(Rright+Rn)/2;
            %                     end
            %                     AF(n,f) = AFtemp/Cm;
            %                 end
            %             end
            
            for f = 1:numFibres
                %                 for n = 2:numNodes-1
                for n = 2:AFmapLength-1
                    
                    
                    %% AF using Rattay 1999, Eqn 4
                    
                    Vn = Vmap(n,f);
                    Vleft  = Vmap(n-1,f); % Vn-1, Vn-2, etc.
                    Vright = Vmap(n+1,f); % Vn+1, Vn+2, etc.
                    fn_V_on_s = fn_constant * (Vleft + Vright - 2*Vn)/(lenAxonSeg_cm^2);
                    % FOR CHECKING CONSISTENCY with Wong 2015. Got an AF
                    % range of [-16.0246,15.4474] V/cm2.
                    fn_V_on_cm2 = (Vleft + Vright - 2*Vn)/(lenAxonSeg_cm^2);
                    AFmap(n,f) = fn_V_on_s;
                end
            end
            
            % Cell array of AF maps for each mode x electrode
            % configuration.
            AFresult{m,c} = AFmap;
            Vresult{m,c}  = Vmap;
        end
    end
    % %     AFAdd = fullfile(AFdir,['AFresults ' timeStamp]);
    AFAdd = fullfile(AFdir,['postprocessing ' timeStamp]);
    save(AFAdd,'AFresult','Vresult');
    
    % %         save([AFdir 'AFresults'],'AFresult')
end
%%
% set(findall(gcf,'-property','interpreter'),'interpreter','latex')
% latexFont = get(Y,'FontName');
% set(findall(gcf,'-property','FontName'),'FontName',latexFont)

if doCountFibres
    %% Visualise AF
%     close all
    tic
    % Load if visualising results in a separate run to computing AF.
        AFAdd = fullfile(AFdir,'postprocessing');
        load(AFAdd)
    
    allAFwithinMode = cell2mat(AFresult(1,:));
    AFmax = max(max(allAFwithinMode))
    AFmin = min(min(allAFwithinMode))
    AFlims = [AFmin,AFmax];
    
    allVwithinMode = cell2mat(Vresult(1,:));
    Vmax = max(max(allVwithinMode))
    Vmin = min(min(allVwithinMode))
    VLims = [Vmin,Vmax];
    
    numActiveFibres = nan(numModes,max(cellfun(@(x) length(x),configSets)));
    
    % Everything
    mArray = 1:numModes;
    % Monopolar has the largest AF map, TP the smallest. Use this to see
    % the extremities.
    %     mArray = [1 6];
    %     mArray = 1;
%     mArray = [5:7];
    for m = mArray%1%:numModes%[1 2 5 7]%
        fname = fnames{m};
        simStr = fname(1:min(strfind(fname,' '))-1);
        simStr = fname;
        
        % Everything
        elecConfigs = configSets{m};
        % 10-12 should be nice and clean, 17-22 messier (apical).
        %         elecConfigs = [10:12,17:2:21];
%         elecConfigs = [11];
%         elecConfigs = [4:10,12:21];
        for c = elecConfigs
            AFmap = AFresult{m,c};
            Vmap  = Vresult{m,c};
            
            name = [simStr '_' num2str(c)]
            
            % Advanced AF plot
            %>>> Suprathreshold values anywhere
            % Identify active fibres as whether they have a fibre with suprathreshold
            % AF value(s). RUDIMENTARY! Find more accurate determination.
            
            % Arbitrary threshold from visual inspection
            % Vthres = max(clims)/50; % V
            AFthres = 0.005; % V, determined by comparison between stimulation configs.
            
            % REF 2014 Crozier, 2014 Szabo, 2015 Davis for Type I spiral ganglion
            % neuron (responsible for IHCs, cf. Type II for OHCs).
            % 2014 Crozier: V_holding = -80 mV, depolarisation V_thres -55 to -50 mV.
            % 2014 Szabo: V_resting = -62 ± 9 mV, V_holding = -60 mV, hyperpolarisation
            % V_thres = -90 mV.
            % 2015 Davis: Current clamp - V_holding N/A, but call it -60mV (typical)?
            % depolarisation V_thres = -43.6 ± 0.8 mV.
            vThres_V = 30e-3;
            tPulse_s = 240e-3;
            % AFthres = vThres_V/tPulse_s;
            
            % Simple threshold of either depolarisation or hyperpolarisation.
            AFbinary = abs(AFmap)>AFthres;
            % Array of fibre numbers for which any node of the fibre has an AF value
            % above threshold.
            activeFibres = find(any(AFbinary));
            
            %>>> Soma
            % Take AF at the soma as the arithmetic mean of the nodes around it. Soma
            % lies between nodes 7 and 8.
            AFsoma = mean(abs(AFmap(7:8,:)));
            % max(AFsoma)
            % AFthres = 1e-3;
            % Array of fibre numbers for which the soma of the fibre has an AF value
            % above threshold.
            activeFibres = find(AFsoma>AFthres);
            
            % Number of active fibres.
            AFcount = length(activeFibres);
            
            numActiveFibres(m,c) = AFcount;
            
            if doVisualise
                plotAF(AFmap,activeFibres,AFthres,AFlims,name);
            end
            %             %%
            %             % V plot & AF plot
            %             figWidth = 2/3;
            %             hfig = figure('units','normalized');
            %             set(hfig, 'MenuBar', 'none');
            %             set(hfig, 'ToolBar', 'none');
            %             set(hfig,'position',[0,0,figWidth,1]);
            %
            %             combLims = [VLims AFlims];
            %             zlims = [min(combLims),max(combLims)];
            %             clims = [-max(combLims)/2,max(combLims)];
            %
            %             xFibreStr = 'Basal $\leftarrow$ Fibre No. $\rightarrow$ Apical';
            %             yNodeStr = 'Axon $\leftarrow$ Node No. $\rightarrow$ Process';
            %             fnStr = '$f_{n}$ (V/s)';
            %             VStr = 'Potential (V)';
            %
            %             subplot(1,2,1)
            %             hold on
            %             sV  = surf(Vmap);
            %             sAF = surf(AFmap);
            %             sV.EdgeAlpha = 0;
            %             alpha(sV,0.7);
            %             sAF.EdgeAlpha = 0;
            %             alpha(sAF,0.7);
            % %             view([-7,10])
            % %             view([-8,20])
            %             view([-49.5,36])
            %             caxis(clims)
            %             zlim(zlims)
            %             colormap(flipud(hot))
            %             grid on
            %             xlabel(xFibreStr)
            %             ylabel(yNodeStr)
            %             zlabel([Vstr '/' fnStr])
            %             title('Voltage map above AF map')
            %             legend({'V map (V)','AF map (V/s)'},'location','northwest')
            %             rotate3d
            %
            %             subplot(1,2,2)
            %             hold on
            %             sV  = surf(Vmap);
            %             sAF = surf(AFmap);
            %             sV.EdgeAlpha = 0;
            %             alpha(sV,0.8);
            %             sAF.EdgeAlpha = 0;
            %             alpha(sAF,0.8);
            % %             view([-7,10])
            % %             view([-8,20])
            % %             view([-49.5,36])
            %             view([0.5,-18])
            %             view([0.5,-22])
            %
            %
            %             caxis(clims)
            %             zlim(zlims)
            %             colormap(flipud(hot))
            %             grid on
            %             xlabel(xFibreStr)
            %             ylabel(yNodeStr)
            %             zlabel(fnStr)
            %             title('Voltage map above AF map')
            %             legend({'V map (V)','AF map (V/s)'},'location','northwest')
            %             rotate3d
            %%
            %
            %             view([-37.5,18])
            %             view([179.5,24])
            %             view([-0.5,24])
            %             view([-6.5,4])
            %
            %
            %             alpha(sV,0.3)
            %             view([-29,36])
            %
            %             view([160.5,22])
            
            
            
            if doSavePNG
                image_name = fullfile(AFdir, strcat('Unrolled',name,'.png'));
                print(gcf, '-dpng', image_name);
            end
            %             close
        end
    end
    toc
end

if doPlotSpecificity
    %% Specificity
    
    figWidth = 1/2;%/2;
    hfig = figure('units','normalized');
% % %     set(hfig, 'MenuBar', 'none');
%     set(hfig, 'ToolBar', 'none');
    set(hfig,'position',[1-figWidth,0,figWidth,1]);
    
    if doBP1x5
        legStrs = {
            'Monopolar';
            'Bipolar';
            'Bipolar1';
            'Bipolar1x5';
            'Bipolar2';
            'Tripolar';
            'Partial Tripolar ($\sigma = 0.67$)';
            'Partial Tripolar ($\sigma = 0.33$)';
            };
        markerSpecs = 'ossss^^^><.p*dvs+hx';
        
    else
        legStrs = {
            'Monopolar';
            'Bipolar';
            'Bipolar1';
            'Bipolar2';
            'Tripolar';
            'Partial Tripolar ($\sigma = 0.67$)';
            'Partial Tripolar ($\sigma = 0.33$)';
            };
        markerSpecs = 'osss^^^><.p*dvs+hx';
        
    end
    
    h2 = 0;
    MPs = [1 h2 h2]; % Reds
    BPs = [h2 1 h2]; % Greens
    TPs = [h2 h2 1]; % Blues
    triplet = ones(1,3);
    fraction = 6;
    if doBP1x5
        plotHues = [MPs.*triplet;
            BPs.*triplet;
            BPs.*triplet*(fraction-1)/fraction;
            BPs.*triplet*(fraction-2)/fraction;
            BPs.*triplet*(fraction-3)/fraction;
            TPs.*triplet;
            TPs.*triplet*(fraction-1)/fraction;
            TPs.*triplet*(fraction-2)/fraction];
    else
        plotHues = [MPs.*triplet;
            BPs.*triplet;
            BPs.*triplet*(fraction-1)/fraction;
            BPs.*triplet*(fraction-2)/fraction;
            TPs.*triplet;
            TPs.*triplet*(fraction-1)/fraction;
            TPs.*triplet*(fraction-2)/fraction];
    end
    
    % Plot by stimulation mode.
    for l = 1:size(numActiveFibres,1)
        %     plot(numActiveFibres(l,:))
        %     semilogy(1:22,1./numActiveFibres(l,:))
        %     semilogy(1:22,numActiveFibres(l,:))
        plotType = ['-',markerSpecs(l)];
        
        plot(1:22,numActiveFibres(l,:),plotType,'color',plotHues(l,:),...
            'linewidth',2,'markersize',10)
        
        %         legend(legStrs{1:l},'location','northwest')
        legend(legStrs{1:l},'location','northwest')
        
        %     pause(0.5)
        hold on;
        
    end
    
    % Desired percentage, with reference to spline
    
    
    xlim([0 23])
    ylim([-0.5 max(max(numActiveFibres))+3])
    xlabel('Stimulating electrode')
    ylabel('Percentage of modelled fibres excited')
    % ylabel('log(1/Percentage of modelled fibres excited)')
%     st = title({'Specificity of neural activation','from electrode stimulation','in a FEM human cochlea'});
    set(findall(gcf,'-property','FontSize'),'FontSize',18)
    
%     set(st,'FontSize',20)
    
end
%% Rotate and make frames for ALL open figures
% filename = ax.Title.String;
% filename = 'test';
% title('test');
% figs2frames(2)

if doVidRotate
    %% Make videos compiled from ALL .pngs starting with filename
    modeNamesAbbr = {'MP','BP','BP+1','BP+2','TP'};
    prefix = 'Rattay1999Eqn4subplots3by1';
    secsPerFrame = 0.1;
    %     for n = modeNames
    for n = modeNamesAbbr
        % vidTitle = 'test';
        vidTitle = [prefix n{:}]
        frames2video(vidTitle,secsPerFrame)
    end
    
    %     frames2video(prefix,secsPerFrame)
end

moveFiles = 0;
if moveFiles
    %% Rename the files after publishing and move them to the next folder/stage.
    pubFiles = dir(fullfile(pubDir,'runPostprocessingV2*.png'));
    fnamesInPub = sort_nat({pubFiles.name})';
    
    % Set file names.
    %     outNames = cell(numConfigs,1);
    outNames = {''};
    for n = 1:length(fnames)
        %         outNames{n} = strsplit(sprintf([fnames{n} '_%03d '],1:22))'
        outNames = [outNames;strsplit(sprintf([fnames{n} '_%03d '],configSets{n}))']
    end
    %     outNames = [
    %         strsplit(sprintf(['AFMonopolar_%03d '],1:22))';
    %         strsplit(sprintf(['AFBipolar_%03d '],2:22))';
    %         strsplit(sprintf(['AFBipolar1_%03d '],3:22))';
    %         strsplit(sprintf(['AFBipolar2_%03d '],4:22))';
    %         strsplit(sprintf(['AFTripolar_%03d '],2:21))';
    %         strsplit(sprintf(['AFpTripolarSig033_%03d '],2:21))';
    %         strsplit(sprintf(['AFpTripolarSig2_%03d '],2:21))';
    %         ];
    % Kill empty strings (artifacts from above).
    outNames(strcmp(outNames,'')) = [];
    
    % Last one is the specificity graph.
    numAFplots = length(fnamesInPub)-1;
    
    % Rename while moving to vidDir.
    for fIndex = 1:length(fnamesInPub)-1
        oldName = fullfile(pubDir,fnamesInPub{fIndex});
        newName = fullfile(vidDir,[outNames{fIndex},'.png']);
        %     disp(oldName)
        %     disp(newName)
        %     disp('')
        movefile(oldName,newName)
    end
    
    %% Make videos from ALL frames
    % fnames = {...
    %     'MP';
    %     'BP';
    %     'BP1';
    %     'BP2';
    %     'TP';
    %     'pTPsig067';
    %     'pTPsig033';
    %     };
    
    for f = 1:length(fnames)
        tic
        frames2video(fnames{f},0.3)
        toc
    end
    %%
    
    % Make .avi on individual stimulation modes.
    
    
    % NOT SURE IF THIS WORKS HAVENT TESTED
    
    %     incompatible = {
    %         'Bipolar_002.png';
    %         'Bipolar_003.png';
    %         'Bipolar_022.png';
    %         'Bipolar1_003.png';
    %         'Bipolar1_022.png';
    %         'Bipolar2_022.png';
    %         'Monopolar_001.png';
    %         'Monopolar_002.png';
    %         'Monopolar_003.png';
    %         'Monopolar_022.png';
    %         'pTripolarSig2_002.png';
    %         'pTripolarSig2_003.png';
    %         'pTripolarSig033_002.png';
    %         'pTripolarSig033_003.png';
    %         'Tripolar_002.png';
    %         'Tripolar_003.png'};
    
    %     cellfun(@(x) x == 22,configSets,'uniformoutput',0) % Programmatically
    %     if I can be bothered
    % Make .avi on matched electrodes between stimulation modes.
    incompatible = {''};
    % Matching on electrodes 4:21 so the following are not compatible
    unmatchedIndices = {
        [1:3,22];
        [2:3,22];
        [3,22];
        22;
        [2:3];
        [2:3];
        [2:3];
        };
    for n = 1:length(fnames)
        %         outNames{n} = strsplit(sprintf([fnames{n} '_%03d '],1:22))'
        incompatible = [incompatible;strsplit(sprintf([fnames{n} '_%03d.png '],unmatchedIndices{n}))']
    end
    incompatible(strcmp(incompatible,'')) = [];
    sideDir = fullfile(pwd,'Outputs','vid','unmatched');
    for in = 1:length(incompatible)
        movefile(fullfile(vidDir,incompatible{in}),fullfile(sideDir,incompatible{in}));
    end
    
    %% Make videos from only MATCHED frames
    % fnames = {...
    %     'MP';
    %     'BP';
    %     'BP1';
    %     'BP2';
    %     'TP';
    %     'pTPsig067';
    %     'pTPsig033';
    %     };
    
    for f = 1:length(fnames)
        tic
        frames2video(fnames{f},0.3)
        toc
    end
    
end

%%
% runPostVideo & ffmpeg

%% EXPLORATORY Find max & min potentials for setting colour bar
% % Results: maxV = 0.1644; minV = -0.0653. min(abs(xyzV(:,4))) = 2.06898e-7.
% % Use log(V)? If so, how to handle -ve V?
% maxV = xyzV(1,4);
% minV = xyzV(1,4);
%
% for d = 1:length(datasets)
%     % Class of electrode configuration (MP, BP, etc.).
%     dataset = datasets{d};
%     % Select data in col 1 (col 2 = active electrodes, col 3 = currents).
%     xyzV = dataset(:,1);
%     xyzV = cell2mat(xyzV);
%     % Electrode configuration, r for primary electrode (e.g. middle for
%     % TP).
% %     for r = 1:length(xyzV)
% %         try
%             maxV1 = max(xyzV(:,4));
%             minV1 = min(xyzV(:,4));
%             if maxV1 > maxV
%                 maxV = maxV1
%             end
%             if minV1 < minV
%                 minV = minV1
%             end
% %         catch
% %             % Entry doesn't exist but to demarcate the position of the
% %             % other entries.
% %         end
% %     end
% end

%% EXPLORATORY BP1 vs BP1x5
%
% close all
%
% indBP1 = find(cellfun(@(x) ~isempty(x),cellfun(@(x) strmatch(x,'BP1','exact'),fnames,'uniformoutput',0)));
%
% indBP1x5 = find(cellfun(@(x) ~isempty(x),cellfun(@(x) strmatch(x,'BP1x5','exact'),fnames,'uniformoutput',0)));
%
% % Pick a configuration to compare.
% for e = 3:22
% % e = 11;
%
% BP1V = Vresult{indBP1,e};
% BP1x5V = Vresult{indBP1x5,e};
%
% VLims = [-0.2 0.2];
% VRatioLims = [0 6];
% %
% % result = BP1result;
% % allV = cell2mat(cellfun(@(x) x(:,4),result(cellfun(@(x) ~isempty(x),result(:,1))),'uniformoutput',0)');
% % allV(isnan(allV)) == [];
% % BP1V = allV;
% %
% % result = BP1x5result;
% % allV = cell2mat(cellfun(@(x) x(:,4),result(cellfun(@(x) ~isempty(x),result(:,1))),'uniformoutput',0)');
% % BP1x5V = allV;
%
% figure('units','normalized','position',[0.5 0 0.5 1]);
%
% subplot(2,1,1)
% s1 = surf(BP1V);
% hold on
% % subplot(3,1,2)
% s2 = surf(BP1x5V);
%
% sEdgeAlpha = 0.2;
% sAlpha = 1;
%
% % alpha(s1,sAlpha)
% alpha(s2,0.3)
% % set(s1,'EdgeAlpha',sEdgeAlpha+0.3)
% set(s2,'EdgeAlpha',0)
%
% % legend({'BP1','BP1x5'},'location','southeast')
%
% zlim(VLims)
%
% xlabel(xFibreStr)
% ylabel(yNodeStr)
% zlabel(VStr)
%
% azel = [-10.5,14];
% azel = [0,0];
% view(azel)
% rotate3d
%
% Vratio = BP1x5V./BP1V;
% subplot(2,1,2)
% surf(Vratio)
% zlim(VRatioLims)
%
% xlabel(xFibreStr)
% ylabel(yNodeStr)
% zlabel('$V_{BP1}/V_{5BP1}$')
%
% titleStr = ['BP1 vs BP1x5 at E' num2str(e)];
% suptitle(titleStr)
% set(findall(gcf,'-property','FontSize'),'FontSize',25)
%
% % zlabel('$\frac{V_{BP1}}{V_{5BP1}}$','fontsize',40)
%
% view(azel)
% savefig(titleStr)
% end
