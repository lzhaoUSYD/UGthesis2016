clc

% V2 but with mphsave

% Configurations as discussed in:
% - 2016 Kalkman et al
% - 2015 Wong

I0default = 0.1065; % mA

% doShowFreq = 1;
makeVid = 0;
doSaveFig = 1;

modelAddress   = '../COMSOL models/Phil plus MP for COMSOL v5_0';

fprintf(['Loading ' modelAddress '\n']);
tic
model = mphload(modelAddress);
toc

%% Set up configurations.
% 1. MP
% 2. BP
% 3. BP+1
% 4. BP+2
% 5. TP
% 6. pTP
% 7. PA (not implemented yet)

doRun = [1 1 1 1 1 0 0];
% doRun = [0 1 0 0 0 0 0];
% doRun = [0 0 0 0 1 0 0];
% doRun = ones(1,6);
% doRun = [0 0 0 1 1 1 ];
% doRun =  [0 0 0 0 0 1];
%        1 2 3 4 5 6 7

doRun = doRun > 0; % Get a boolean
configs = {...
    1:22;
    2:22;
    3:22;
    13:22;
    2:21;
    2:21};

% ref = 5;
% configs = {...
%     ref+1;
%     ref;
%     ref;
%     ref;
%     ref;
%     ref+1};
% sigmas for pTP
sigmas = [0.2 2];

%% Figure out simulation time.
% Factor in additional for loop, but not to double account.
sigmaLoop = (length(configs{6}) * (length(sigmas) - 1)) * doRun(6);

% Get number of simulations. Not factoring in sigmas.
numSimulations = sum(cellfun(@length,configs(doRun))) + sigmaLoop;

timePerSim = 20; % Minutes.
estTimeMinutes = numSimulations * timePerSim;
numHours = floor(estTimeMinutes/60);
numMinutes = mod(estTimeMinutes,60);
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
simDir = fullfile(pwd,'Outputs','simulations');

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
        
        
        
        runStimVerboseHelperScript
        %         break
        
        MPresult{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        MPresult{e,2} = activeElectrodes;
        MPresult{e,3} = inputCurrents;
        
        plotV(MPresult(e,:))
        name = [simStr num2str(e)];
        title(name);
        savefig(name)
        %         toc
        fname = fullfile(simDir,strrep(name,' ','_'));
        
        tic
        mphsave(model,fname);
        toc
        
        % Now re-load the original, because we don't want all of the
        % results getting stored in a single model.
        model = mphload(modelAddress);
    end
    save([simStr timeStamp '.mat'],'MPresult');
    
end

%% Bipolar
if doRun(2)
    simStr = 'Bipolar ';
    tic
    for e = configs{2}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        % Either side
        e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        
        runStimVerboseHelperScript
        %         break
        %
        BPresult{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        BPresult{e,2} = activeElectrodes;
        BPresult{e,3} = inputCurrents;
        
        plotV(BPresult(e,:))
        
        name = [simStr num2str(e)];
        title(name);
        savefig(name)
    end
    save([simStr timeStamp '.mat'],'BPresult');
    toc
end

%% BP+1
if doRun(3)
    simStr = 'BP+1 ';
    tic
    for e = configs{3}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        
        runStimVerboseHelperScript
        %         break
        %
        BP1result{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        BP1result{e,2} = activeElectrodes;
        BP1result{e,3} = inputCurrents;
        
        plotV(BP1result(e,:))
        
        name = [simStr num2str(e)];
        title(name);
        savefig(name)
    end
    save([simStr timeStamp '.mat'],'BP1result');
    toc
end


%% BP+2
simStr = 'BP+2 ';

if doRun(4)
    tic
    for e = configs{4}
        fprintf(['\n' simStr 'configuration/electrode %d '],e);
        e1 = e;
        e2 = e1 + 3; % e1 must be within [1,19]
        e2 = e1 - 3; % e1 must be within [4,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        
        runStimVerboseHelperScript
        %         break
        %
        BP2result{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        BP2result{e,2} = activeElectrodes;
        BP2result{e,3} = inputCurrents;
        
        plotV(BP2result(e,:))
        
        name = [simStr num2str(e)];
        title(name);
        savefig(name)
    end
    save([simStr timeStamp '.mat'],'BP2result');
    %     save(fname,'BP2result','-append');
    toc
end


%% Tripolar
if doRun(5)
    simStr = 'Tripolar ';
    tic
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
        
        runStimVerboseHelperScript
        %         break
        
        TPresult{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
        TPresult{e,2} = activeElectrodes;
        TPresult{e,3} = inputCurrents;
        
        plotV(TPresult(e,:))
        
        name = [simStr num2str(e)];
        title(name);
        savefig(name)
    end
    save([simStr timeStamp '.mat'],'TPresult');
    %     save(fname,'TPresult','-append');
    
end

%% Partial Tripolar
if doRun(6)
    simStr = 'Partial Tripolar ';
    
    for e = configs{6}
        for s = 1:length(sigmas)
            sigma = sigmas(s);
            fprintf(['\n' simStr 'configuration/electrode %d sigma %.4f'],e,sigma);
            % Centered around e2: e2 must be within [2,21].
            e2 = e;
            e1 = e2 - 1;
            e3 = e2 + 1;
            
            I0mA = I0default;
            %             sigma = 0.5;
            activeElectrodes = [e1,e2,e3];
            inputCurrents    = [-I0mA/(2*sigma),I0mA,-I0mA/(2*sigma)];
            
            
            runStimVerboseHelperScript
            %         break
            
            pTPresult{e,1,s} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
            pTPresult{e,2,s} = activeElectrodes;
            pTPresult{e,3,s} = inputCurrents;
            
            plotV(pTPresult(e,:,s))
            
            name = [simStr num2str(e) '_' strrep(num2str(sigma),'.','_')];
            title(name);
            savefig(name)
        end
    end
    save([simStr timeStamp '.mat'],'pTPresult');
    %     save(fname,'pTPresult','-append');
    
end
% if doRun(7)
%     %% Phased array
%     % Lit review
%     % 2011 Frijns et al Neural excitation patterns induced by phased-array stimulation in the implanted human cochlea
%     % 2014 George et al Evaluation of focused multipolar stimulation for cochlear implants in acutely deafened cats
% end
% end
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
playHallelujah


