close all
% clear all
clc

doPlot = 0;
computeAF = 0;
doVisualise = 1;
doVidRotate = 0;
doSavePNG = 0;

set(0,'defaultTextInterpreter','latex');
set(0,'defaulttextfontsize',18);

fnames = {...
    'Monopolar 12-Aug-2016 09-45-02.mat';
    'Bipolar 12-Aug-2016 09-45-02.mat';
    'Bipolar+1 12-Aug-2016 09-45-02.mat';
    'Bipolar+2 15-Aug-2016 15-36-33.mat';
    'Tripolar 15-Aug-2016 15-36-33.mat'};

AFdir = [pwd '/Outputs/AF/'];
vidDir = [pwd '/Outputs/Potentials/'];

for f = 1:length(fnames)
    fname = fnames{f};
    simStr = fname(1:min(strfind(fname,' '))-1);
    modeNames{f} = simStr;
    fullAdd = [vidDir fname];
    load(fullAdd);
end

dataStimModes = {...,
    MPresult;
    BPresult;
    BP1result;
    BP2result;
    TPresult};

configSets = {...
    1:22;
    2:22;
    3:22;
    4:22;
    2:21};

numModes = length(dataStimModes);
maxNumConfigs = max(cellfun(@(x) length(x),configSets));
AFresult = cell(numModes,maxNumConfigs);

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
%% Calculate activating function

if computeAF
    %% Physiological parameters
    
    
    
    % [Rattay 1999, Table 2] Membrane capacitance, should be specified for
    % each node n.
    Cm = 3e-12;  % Small soma, far or near field.
    Cm = 28e-12; % Large soma, far or near field.
    Cm = 0.37;   % Initial segment.
    
    % [Rattay 1999, Table 2] Axoplasmic resistance, should be specified for
    % each node n.
    RaHalf = 146e3;  % Small soma, far or near field. Soma to initial segment.
    RaHalf = 72e3;   % Large soma, far or near field. Soma to initial segment.
    RaHalf = 955e3;   % Initial segment.
    
    % Rattay 1999, Table 1] Model data.
    % Dendrite
    dDend = mean([4,4,1]) * 1e-4; % 3 neurons measured by Rattay 1999. 'd'
    dAxon = 2e-4; % 'd'
    lenAxon = 500e-6; % '\delx'
    d = dAxon;
    
    rhoi = RaHalf/2/2/lenAxon*dAxon^2*pi; % 'rho_i'
    cm = Cm/dAxon/lenAxon/pi;
    
    % [Rattay 2001, Table 1] Cochlear neuron resistivity (same as for cat).
    Rintra = 0.05e3; % kOhm.cm
    Rextra = 0.3e3;  % kOhm.cm
    Cm = 1e-6;       % Capacitance of cell membrane (one layer).
    
    
    for m = 1%:numModes
        % Individual stimulation mode (BP TP, pTP etc)
        dataStimMode = dataStimModes{m};
        fname = fnames{m};
        simStr = fname(1:min(strfind(fname,' ')));
        
        elecConfigs = configSets{m};
        for c = elecConfigs(1)
            %% Set up data
            % Individual electrode configuration (+1/-2, -3/+4/-5, etc)
            dataElecConfig = dataStimMode(c,:);
            
            allxyzV = cell2mat(dataStimMode(:,1));
%             allV = allxyzV(:,4);
%             minV = min(allV);
%             maxV = max(allV);
            % f1 = plotV(dataElecConfig)
            xyzV = dataElecConfig{1}; % 2 for electrode numbers, 3 for currents.
                        
            V = xyzV(:,4);
            numCoords = length(V);
            numNodes = 20;
            numFibres = numCoords/numNodes; %40;
            Vfibres = reshape(V,numNodes,numFibres);
            
            AF = nan*Vfibres; % V/s

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
            
            %% AF using Rattay 1999, Eqn 4
            for f = 1:numFibres
                for n = 2:numNodes-1
                    Vn = Vfibres(n,f);
                    Vleft  = Vfibres(n-1,f); % Vn-1, Vn-2, etc.
                    Vright = Vfibres(n+1,f); % Vn+1, Vn+2, etc.
                    fn = d/(4*rhoi*cm) * (Vleft + Vright - 2*Vn)/(lenAxon^2);
                    AF(n,f) = fn;
                end
            end
            
            AFresult{m,c} = AF;

        end
    end
%     save([AFdir 'AFresults'],'AFresult')
end
%%
% set(findall(gcf,'-property','interpreter'),'interpreter','latex')
% latexFont = get(Y,'FontName');
% set(findall(gcf,'-property','FontName'),'FontName',latexFont)

if doVisualise
%% Visualise AF
    
    
    load([AFdir 'AFresults.mat'])
    
    for m = 1:numModes
        allAFwithinMode = cell2mat(AFresult(1,:));
        AFmax = max(max(allAFwithinMode))
        AFmin = min(min(allAFwithinMode))
        
        fname = fnames{m};
        simStr = fname(1:min(strfind(fname,' '))-1);
        
        elecConfigs = configSets{m};
        for c = elecConfigs%(1:2)
            AF = AFresult{m,c};
            
            name = [simStr '_' num2str(c)]
            
            plotAF(AF,[AFmin,AFmax],name);
            %% DEPRECATED NOW IN plotAF. A few ways to look at it 
%             f = figure('units','normalized','position',[0.5,0,0.5,1]);
%             
%             AFvalid = AF;
%             AFvalid([1:5,16:20],:) = -10;
%             subplot(3,1,1)
%             plotAF(AFvalid);
%             caxis([AFmin,AFmax])
%             titleStrObj = get(gca,'title');
%             titleStr = titleStrObj.String;
%             titleStr = [titleStr ': ' name];
%             title('Flat view')
%             
%             subplot(3,1,2)
%             plotAF(AFvalid);
%             caxis([AFmin,AFmax])
%             zlim([AFmin,AFmax])
%             titleStrObj = get(gca,'title');
%             titleStr = titleStrObj.String;
%             titleStr = [titleStr ': ' name];
%             title('3D view')
%             view([135.5,62])
%             
%             subplot(3,1,3)
%             depol = double(AF>0);
%             depol([1:5,16:20],:) = 0.12;
%             surf(depol)
%             X = xlabel('Basal $\leftarrow$ Fibre No. $\rightarrow$ Apical');
%             Y = ylabel('Axon $\leftarrow$ Node No. $\rightarrow$ Process');
%             title('Depolarisation (white)')
%             view([0,-90])
%             
%             suptitleStr = strrep([titleStr ' (3 views of the same thing)'],'_',' ');
%             suptitle(suptitleStr)
%             
%             
%             set(findall(gcf,'-property','FontSize'),'FontSize',18)
%             rotate3d
%%
            if doSavePNG
                image_name = fullfile(AFdir, strcat('Unrolled',name,'.png'));
                print(gcf, '-dpng', image_name);
            end
            close
        end
    end
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

