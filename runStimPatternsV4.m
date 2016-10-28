t0 = tic;

clc

% V3 but using runStimPatternsFcn

% Configurations as discussed in:
% - 2016 Kalkman et al
% - 2015 Wong

I0default = 0.1065; % mA

% doShowFreq = 1;
makeVid = 0;
doSaveFig = 1;

originalModel   = '../COMSOL models/Phil plus MP for COMSOL v5_0';

if ~exist('model')

    fprintf(['Loading ' originalModel '\n']);
    tic
    model = mphload(originalModel);
    toc
end

%% Set up configurations.
% 1. MP
% 2. BP
% 3. BP+1
% 4. BP+2
% 5. TP
% 6. pTP A
% 7. pTP B
% 8. PA (not implemented yet)

% doRun = [1 1 0 0 0 0 0];
doRun = [1 1 1 1 1 1 1];
% doRun = [0 0 1 1 1 0 0];
% doRun = [0 0 1 0 0 0 0];
% doRun = [0 0 0 0 1 0 0];
% doRun = ones(1,6);
% doRun = [0 0 0 1 1 1 ];
% doRun =  [0 0 0 0 0 1];
%        1 2 3 4 5 6 7
% doRun = [0 0 1 1 0 0 0];
    
doRun = doRun > 0; % Get a boolean
fullConfigs = {...
    1:22;
    2:22;
    3:22;
    4:22;
    2:21;
    2:21;
    2:21};

configs = fullConfigs;

% configs = {...
%     [];
%     [];
%     3:8;
%     4:12;
%     [];
%     [];
%     [];
%     };

% configs = {...
%     [];
%     [];
%     [];
%     [];
%     [];
%     [];
%     5:21;
%     };

% 
% ref = 5;
% configs = {...
%     ref;
%     ref;
%     ref;
%     ref;
%     ref;
%     ref};
% sigmas for pTP
sigmas = [1/3 2/3];

%% Figure out simulation time.
loadTime = 1;  % Minutes.
saveTime = 1.3;  % Minutes.
simTime  = 16; %21; % Minutes on Paul-PC (64GB RAM), Level 8 PC (32GB RAM)
% DEPRECATED after implementing pTP as separate loops.
% Factor in additional for loop, but not to double account.
% sigmaLoop = (length(configs{6}) * (length(sigmas) - 1)) * doRun(6);

% Get number of simulations. Not factoring in sigmas.
numSimulations = sum(cellfun(@length,configs(doRun)));% + sigmaLoop;

% Simulation, saving results and loading clean slate for next simulation.
timePerSim =simTime + saveTime + loadTime; % Minutes.
estTimeMinutes = numSimulations * timePerSim;
numHours = floor(estTimeMinutes/60);
numMinutes = round(mod(estTimeMinutes,60));
checkBack = datestr(now + datenum(0,0,0,numHours,numMinutes,0),'HH:MM:SS dd/mmm/yyyy');

checkTime = sprintf(['Estimated simulation time: %d hours %d minutes for %d simulations (come back around ' checkBack '). Continue?'],...
    numHours,numMinutes,numSimulations);
confirmRun = questdlg(checkTime);
switch confirmRun
    case 'Yes'
        fprintf(['Come back around ' checkBack '\n']);
    otherwise
        disp('Cancelled.')
        return
end

timeStamp =  datestr(now,'dd-mmm-yyyy HH-MM-SS');

%
% if doShowFreq
%     load('3500Fibres10Nodes.mat')
% end
close all
% Records on running time
% 1 electrode
% 204 s
%
% 3 electrodes
% c = oneShotStimPattern(model,[1 22 5],[5 9 18]);
% 177 s
%
% 5 electrodes
% c = oneShotStimPattern(model,[1 5 9 13 17],[1 5 1 5 1]);
% 235 s
% Doesn't look like the solution was updated.

fname = ['Simulations ' timeStamp '.mat'];
% Save dummy file for appending results to.
save fname fname;

% simDir = [pwd '/Outputs/simulations/'];
% simDir = fullfile(pwd,'Outputs','simulations');

%% Monopolar
if doRun(1)
    simStr = 'Monopolar ';
    
    MPresult = cell(22,3);
    for e = configs{1}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        tic
        I0mA = I0default;
        
        activeElectrodes = e;
        inputCurrents    = I0mA;
        
        MPresult = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,MPresult);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'MPresult');
    
end

%% Bipolar
if doRun(2)
    simStr = 'Bipolar ';
    
    BPresult = cell(21,3);
    for e = configs{2}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        % Went for latter direction in simulations (could be either side).
        e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];        
        
        BPresult = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,BPresult);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'BPresult');
    
end

%% BP+1
if doRun(3)
    simStr = 'BP+1 ';
    
    BP1result = cell(21,3);
    for e = configs{3}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        
%         % TODO REMEMBER TO CHANGE BACK. THIS JUST FOR COMPARISON AGAINST
%         % MP.
%         I0mA = I0default*5;
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
                
        BP1result = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,BP1result);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'BP1result');
end


%% BP+2
if doRun(4)
    simStr = 'BP+2 ';

    BP2result = cell(21,3);
    for e = configs{4}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        e2 = e1 + 3; % e1 must be within [1,19]
        e2 = e1 - 3; % e1 must be within [4,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];        
        
        BP2result = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,BP2result);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'BP2result');
end


%% Tripolar
if doRun(5)
    simStr = 'Tripolar ';
    
    TPresult = cell(20,3);
    % 1994 Busby et al Pitch perception for different modes of stimulation using the cochlear multiple-electrode prosthesis
    for e = configs{5}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        % Centered around e2: e2 must be within [2,21].
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2,I0mA,-I0mA/2];
        
        TPresult = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,TPresult);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'TPresult');
    
end


%% Partial Tripolar A
% REF: Kalkman 2015
% The pTP paradigm is a modification of TP
% stimulation, where the stimulus amplitude on the flanking contacts
% is multiplied by a factor s. This means that for s = 1, pTP is
% identical to the TP paradigm and for s = 0, it is identical to MP
% stimulation.
if doRun(6)
    sigma = sigmas(1);
    simStr = strrep(sprintf('Partial Tripolar %.2g ',sigma),'.','pt');
    pTPresultA = cell(20,3);
    for e = configs{6}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);

%         fprintf(['\n' simStr 'configuration/electrode %d sigma %.4f'],e,sigma);
        % Centered around e2: e2 must be within [2,21].
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        %             sigma = 0.5;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
        
        pTPresultA = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,pTPresultA);
        tic;model = mphload(originalModel);toc
        
        % Should normally save outside of the for loop but putting it here to
        % check on results as we go.
        save([simStr timeStamp '.mat'],'pTPresultA');

    end
    
end
%% Partial tripolar B
% Setting up different pTP configs as separate runs to retain consistency
% with the rest (MP, BP, TP) in structuring.
if doRun(7)
    sigma = sigmas(2);
    simStr = strrep(sprintf('Partial Tripolar %.2g ',sigma),'.','pt');
    
%     simStr = 'Partial Tripolar 1pt5';
    pTPresultB = cell(20,3);
    for e = configs{7}
%         sigma = 1.5;
        fprintf(['\n' simStr 'configuration/electrode %d '],e);

%         fprintf(['\n' simStr 'configuration/electrode %d sigma %.4f'],e,sigma);
        % Centered around e2: e2 must be within [2,21].
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        %             sigma = 0.5;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
        
        pTPresultB = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,pTPresultB);
        tic;model = mphload(originalModel);toc
    end
    save([simStr timeStamp '.mat'],'pTPresultB');
    %     save(fname,'pTPresult','-append');
    
end
%%
% if doRun(7)
%     %% Phased array
%     % Lit review
%     % 2011 Frijns et al Neural excitation patterns induced by phased-array stimulation in the implanted human cochlea
%     % 2014 George et al Evaluation of focused multipolar stimulation for cochlear implants in acutely deafened cats
% end
% end
%%
toc

if doSaveFig
    figHandles = findobj('Type','figure');
    for figIndex = 1:length(figHandles)
        set(0, 'currentfigure', figIndex);
        htitle = get(gca,'title'); htitle.String;
        
    end
end

if makeVid
    tic
    %% Video frames export
    %>> Make it spin
    vidTitle = inputdlg('Title of video:');
    vidTitle = vidTitle{:};
    vidDir = [pwd '/Outputs/vid/'];
    numFrames = 360;
    alpha = 360/numFrames;
    vectorY = [0 1 0];
    % Add more space on axes for rotation.
    zlims = zlim
    set(gca,'zlim',[zlims(1) - rotatePadding,zlims(2) + rotatePadding])
    
    figHandles = findobj('Type','figure');
    for f = 1 %: length(figHandles)
        % Between figures (e.g. comparing elcetrode configurations).
        image_name = fullfile(vidDir, strcat(vidTitle,'_',num2str(f),'.png'));
        print(figHandles(f), '-dpng', image_name);
        
        for i = 1:numFrames
            % Within figures (rotating result figure).
            image_name = fullfile(vidDir, strcat(vidTitle,'_',num2str(f),'_',num2str(i),'.png'));
            print(f, '-dpng', image_name);
            figHandles(f);
            hlines = findobj(gca,'type','line');
            htext = findobj(gca,'type','text');
            rotate(hlines,vectorY,alpha)
            rotate(htext,vectorY,alpha)
        end
    end
    
    %>> Compile video.
    % Select image sequence to compile.
    %     vidTitle = 'greenwood';
    %     vidDir = [pwd '/Outputs/vid/'];
    
    allFiles = dir(vidDir)
    
    % Match all files starting with vidTitle.
    imfiles = regexpi({allFiles.name},[vidTitle '.*'],'match')
    
    % Match all files starting with vidTitle and numbered
    % title_num_num.png.
    imfiles = regexpi({allFiles.name},[vidTitle '.\d+_\d+.*'],'match')
    
    imfiles = [imfiles{:}]
    
    %>> Load images.
    images    = cell(1,length(imfiles));
    for im = imfiles
        fname = im{:};
        imSeqNumIndex = regexpi(fname,'\d*.png');
        imSeqNum = str2num(fname(imSeqNumIndex:end-4));
        images{imSeqNum} = imread([vidDir fname]);
    end
    
    %>> Set up video.
    %     vidTitle = 'blah.avi';
    %     vidDir = [pwd '/Outputs/vid/'];
    
    vidObj = VideoWriter([vidDir vidTitle]);
    %     secsPerImage = 0.5;
    %     vidObj.FrameRate = 1/secsPerImage;
    vidObj.FrameRate = 36;
    secsPerImage = 1/vidObj.FrameRate;
    framesPerImage = vidObj.FrameRate * secsPerImage;
    
    % open the video writer
    open(vidObj);
    
    % write the frames to the video
    for u=1:length(images)
        % convert the image to a frame
        frame = im2frame(images{u});
        
        for v=1:framesPerImage
            writeVideo(vidObj, frame);
        end
    end
    
    % close the writer object
    close(vidObj);
    toc
end

toc(t0)
playHallelujah


