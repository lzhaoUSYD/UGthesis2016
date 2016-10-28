% main.m but with fitting

% TODO v and V overlap in currently parallel, redundant implementation.
% TODO check for unusually large gaps between spikes (e.g. just below
% threshold) exist, and disregard instantaneous frequencies
% calculated/skewed by them.
% TODO store the computed values properly.

% TODO plot intercepts

%% Set up

clear
close all
clc
% set(0,'defaultTextInterpreter','latex');

doOverlay = 0; % 1 to superimpose plots of traces.
doPlotTraces = 0;    % 1 to plot.
doPlotMeanFreq = 1; % 1 to plot mean AP frequency as function of noise & current.
doPlotMaxFreq = 1; % 1 to plot mean AP frequency as function of noise & current.
doTrimFrames = 0; %

if doOverlay
    doPlotTraces = 1;
    % One figure only for all the plots.
    f = figure('Units','normalized','position',[0.5 0 0.5 1]);
    hold on
else
    % Do nothing.
end

files = ls('./160823/*.mat');
files = strsplit(files);
files = files(1:end-1); % Remove rogue entry (a folder I think)

% files = {'160823_004_inhibitorygain';
%     '160823_005_noise_coarsesteps';
%     '160823_006_FRAgain';
%     '160823_008_noise_fine_steps';
%     '160823_010_CClamp_FRAgain';
%     '160823_013_CClamp_FRA_small'};

% N.B. modify this line as appropriate.
% load('/Users/lukezhao/Dropbox/UNI/S2-2016/AdvNEURLab/Analysis/160823/160823_008_noise_fine_steps.mat')
for f = 1:length(files)
    % Remove the data from the last run
    clearvars -regexp ^c\d{3}
    
    fname = files{f}
    % Filter the file name to decipher the protocol
    tag = fname(regexp(fname,'[^./_]')); % Remove symbols
    tag = tag(regexp(tag,'\D')); % Remove numbers
    tag = tag(1:end-3) % Remove 'mat'
    load(fname)
    
    titleStr = strrep(fname(10:end-4),'_','\_');
    
    % Get a struct containing all the variable names imported from the
    % .axtx file., which begin with 'c' followed by 3 digits.
    S=whos('-regexp', 'c\d{3}.*');
    
    % Select which traces to iterate through.
    cSelection = 1:length(S)-1;
    
    %% Stimulation currents (pA) [protocol name][noise]pA
    % All waveforms are a*rectangularPulse(0.5,1.5,x), where a is the
    % current level (pA), except for ramp.
    % By inspection from noise_fine_steps. Noiseless (1 to 12) is the
    % exception: it doesn't do 40 pA for some reason.
    fineSteps0pA    = [0 linspace(50,150,11)]; %  1 to 12
    fineSteps15pA   = [0 linspace(40,150,12)]; % 13 to 25
    % fineSteps15pA is representative of the rest.
    fineSteps30pA   = [0 linspace(40,150,12)]; % 26 to 38
    fineSteps60pA   = [0 linspace(40,150,12)]; % 39 to 51
    fineSteps120pA  = [0 linspace(40,150,12)]; % 52 to 64
    
    inhibgain       = 0:10:200;
    
    cclampFRAsmall  = 0:10:190;
    
    cclampFRAgain   = 0:20:400;
    
    FRAgain         = 0:20:400;
    
    coarseSteps0pA    = [0,-100,-50,50:50:200];
    coarseSteps10pA   = [0,-100,-50,50:50:200];
    coarseSteps40pA   = [0,-50,-100,50,150,200];
    coarseSteps100pA  = [0,-100,-50,50:50:200];
    
    % Group traces by the stimulating current levels.
    switch tag
        case 'inhibitorygain'
            series = {1:length(inhibgain)};
            currents = inhibgain;
        case 'noisecoarsesteps'
            series = {1:7,8:14,15:20,21:27};
        case 'FRAgain'
            series = {1:length(FRAgain)};
            currents = FRAgain;
        case 'noisefinesteps'
            series = {1:12,13:25,26:38,39:51,52:64};
            currents = fineSteps15pA;
        case 'CClampFRAgain'
            series = {1:length(cclampFRAgain)};
            currents = cclampFRAgain;
        case 'CClampFRAsmall'
            series = {1:length(cclampFRAsmall)};
            currents = cclampFRAsmall;
        case 'CClampRampRate'
            series = {1:4};
        otherwise
            error('Protocol not implemented in main.m')
    end
    
    ylimsV = [-0.1 0.04];
    %                         ylimsV = [-0.06 0.04];
    ylimsHz  = [0 100];
    xlimspA = [0 400];
    
    V = {};
    % Each 'series' is a set of trials at one current(+noise) level.
    for s = 1:length(series)
        % Recordings may not have all the episodes for whatever reason, so
        % only use what's available.
        seriesFull = series{s};
        try
            traceNames{s} = {S(seriesFull+1).name};
        catch
            % Minus c001 which is the time axis.
            numRecordings = length(S)-1;
            traceNames{s} = {S(seriesFull(1:numRecordings)+1).name};
            currents = currents(1:numRecordings);
        end
        for n = 1:length(traceNames{s})
            traceName = traceNames{s}{n};
            V{s,n} = eval(traceName);
        end
    end
    
    % Shift the no noise condition across to match the rest.
    V(1,:) = {[],V{1,1:end-1}};
    
    %% Data processing
    [numNoiseConds,numCurrentLevels] = size(V);
    meanFreqs = nan([numNoiseConds,numCurrentLevels]);
    maxFreqs = meanFreqs;
    
    % Time values
    t = eval(S(1).name);
    Fs = 1e4;
    tStart = 0.5;
    tEnd = 1.5;
    indexStart = find(abs(t - tStart)<1e-10);
    indexEnd   = find(abs(t - tEnd)<1e-10);
    
    tData = t(indexStart:indexEnd);
    
    % Voltage values
    % cSelection = [44,45,55:60,63];
    % cSelection = [44,45,55:60];
    for c = cSelection%(1:5)
        %     pause(0.1)
        if ~doOverlay && doPlotTraces
            % New figure for each plot.
            hfig(c) = figure('Units','normalized','position',[0.5 0 0.5 1]);
        end
        
        % Use the number c to get the variable name & data.
        trace = S(c+1);
        traceName = trace.name;
        v = eval(traceName);
        vData= v(indexStart:indexEnd);
        
        
        %% Analysis
        % Set by visual inspection for detecting APs.
        vThres = 0;
        minDist = 0.005 * Fs; % At least 50 ms (?) between APs.
        minProm = 0.01;
        [spikes,locs] = findpeaks(vData,'MinPeakHeight',vThres,'MinPeakDistance',minDist);
        %     [spikes,locs] = findpeaks(vData,'MinPeakHeight',vThres,'MinPeakProminence',minProm);
        spikeTimes = locs/Fs;
        
        if isempty(spikeTimes)
            meanFreqs(c) = nan;
            maxFreqs(c) = nan;
            continue
        end
        
        % To address "skipped beats" with subthreshold spikes, the first
        % few spikes analysed are generally consecutive so let's just use
        % those.
        aFew = 5;
        firstFew = 1:aFew;
        try
            spikes     = spikes(firstFew);
            spikeTimes = spikeTimes(firstFew);
        catch
            % Error if < 5 spikes. Do nothing.
        end
        fInstant = 1./(spikeTimes(2:end)-spikeTimes(1:end-1));
        
        
        if doPlotTraces
            %% Plotting
            subplot(2,1,1)
            plot(tData,vData)
            text(spikeTimes+0.497,spikes+0.001,'.')
            % Uncomment to automatically plot peaks, but also reformats
            % (inaccurately, would need to set again).
            %         findpeaks(vData,'MinPeakHeight',vThres)
            
            xlabel('Time (s)')
            ylabel('Voltage (V)')
            %         title(strrep(traceName,'_',' '))
            title(strrep(traceName(6:end-2),'_',' '))
            ylim(ylimsV)
            
            if ~doOverlay
                legend(traceName(1:4))
            end
            
            subplot(2,1,2)
            plot(fInstant)
            xlabel('Spike #')
            ylabel('Frequency (Hz)')
            title('Instantaneous frequency (Hz)')
            
            ylim(ylimsHz)
            
            suptitle(titleStr)
            
            set(findall(gcf,'-property','FontSize'),'FontSize',16)
        end
        
        meanFreqs(c) = mean(fInstant);
        maxFreqs(c) = max(fInstant);
    end
    
    if doOverlay
        allNames = {S.name};
        allNamesTrunc = cellfun(@(x) x(1:4),allNames,'uniformoutput',0);
        legend(allNamesTrunc(2:c))
    end
    %% TODO restructure script rather than quick fix for silly matrix storing mistake
    if strcmp(tag,'noisefinesteps')
        % Compensate for inconsistent protocol set-up
        tmp = meanFreqs(:);
        tmp = circshift(tmp,1);
        meanFreqs = reshape(tmp,13,5)';
        tmp = maxFreqs(:);
        tmp = circshift(tmp,1);
        maxFreqs = reshape(tmp,13,5)';
%         meanFreqs = reshape(meanFreqs(:),13,5)';
%         maxFreqs = reshape(maxFreqs(:),13,5)';
    end
    
    if doPlotMaxFreq
        %% Max frequency
        %         f = figure('Units','normalized','position',[0.5 0 0.5 1]);
        %         surf(fineSteps15pA,1:5,maxFreqs)
        %         xlabel('Stimulating current (pA)')
        %         ylabel('Noise level')
        %         zlabel('Frequency (Hz)')
        %         title({'Max instantaneous AP frequency of MVN cells mesh';
        %             titleStr})
        %         set(findall(gcf,'-property','FontSize'),'FontSize',16)
        %
        %         rotate3d
        %
        hfigMax = figure('Units','normalized','position',[0.5 0 0.5 1]);
        hold on;
        if strcmp(tag,'noisefinesteps')
            % Compensating for inconsistent protocol set-up.
            x = currents(2:end);
        else
            x = currents;
        end
        y = maxFreqs(1,2:end);
        
        % Adjust for missing values at the end.
        dataLen = min(length(x),length(y));
        plot(x(1:dataLen),y(1:dataLen));
%         
%         if strcmp(tag,'noisefinesteps')
%             % Compensating for inconsistent protocol set-up.
%             plot(currents(2:end),averageFreqs(1,2:end))
%         else
%             plot(currents,averageFreqs(1,2:end))
%             [figure1,fitResults1,yplot1] = linfit(currents(2:end),averageFreqs(1,2:end))
%         end
        for n = 2:numNoiseConds
            %         pause(0.5)
            x = currents;
            y = maxFreqs(n,:);
            % Adjust for missing values at the end.
            dataLen = min(length(x),length(y));
            plot(x(1:dataLen),y(1:dataLen));
%             plot(currents,maxFreqs(n,:))
        end
        xlabel('Stimulating current (pA)')
        ylabel('Frequency (Hz)')
        ylim(ylimsHz)
        xlim(xlimspA)
        title({'Max instantaneous AP frequency of MVN cells';
            titleStr})
        legend({'No noise','Noise level 1','Noise level 2','Noise level 3','Noise level 4'},...
            'location','southwest')        
        %% Fit
        fitTxt = {''};
        ax = gca;
        for n = 1:numNoiseConds
            [p,rsq,txt] = linearFit(currents,maxFreqs(n,:),ax);
            txt = sprintf([txt '; r^2 = %.3f'],rsq);
            fitTxt{n+1,:} = txt;
        end
        
        text(.25,.01,fitTxt,'parent',ax, ...
            'verticalalignment','bottom','units','normalized');
        
        set(findall(gcf,'-property','FontSize'),'FontSize',14)
    end
    
    if doPlotMeanFreq
        %% Mean frequency
        %         f = figure('Units','normalized','position',[0.5 0 0.5 1]);
        %         surf(fineSteps15pA,1:5,averageFreqs)
        %         xlabel('Stimulating current (pA)')
        %         ylabel('Noise level')
        %         zlabel('Frequency (Hz)')
        %         title({'Mean instantaneous AP frequency of MVN cells mesh';
        %             titleStr})
        %
        %         set(findall(gcf,'-property','FontSize'),'FontSize',16)
        %
        %         rotate3d
        %
        
        hfigMean = figure('Units','normalized','position',[0.5 0 0.5 1]);
        hold on;
        % n = 1
         if strcmp(tag,'noisefinesteps')
            % Compensating for inconsistent protocol set-up.
            x = currents(2:end);
        else
            x = currents;
        end
        y = meanFreqs(1,2:end);
        
        % Adjust for missing values at the end.
        dataLen = min(length(x),length(y));
        plot(x(1:dataLen),y(1:dataLen));
%         if strcmp(tag,'noisefinesteps')
%             % Compensating for inconsistent protocol set-up.
%             x = currents(2:end);
%         else
%             x = currents;
%         end
%         y = meanFreqs(1,2:end);
%         plot(x(1:end-1),y);
        
        for n = 2:numNoiseConds
            %         pause(0.5)
            x = currents;
            y = meanFreqs(n,:);
            % Adjust for missing values at the end.
            dataLen = min(length(x),length(y));
            plot(x(1:dataLen),y(1:dataLen));
            
%             plot(currents,meanFreqs(n,:))
        end
        xlabel('Stimulating current (pA)')
        ylabel('Frequency (Hz)')
        ylim(ylimsHz)
        xlim(xlimspA)
        title({'Mean instantaneous AP frequency of MVN cells';
            titleStr})
        legend({'No noise','Noise level 1','Noise level 2','Noise level 3','Noise level 4'},...
            'location','southwest')
        
        %% Fit
        fitTxt = {''};
        ax = gca;
        for n = 1:numNoiseConds
            [p,rsq,txt] = linearFit(currents,meanFreqs(n,:),ax);
            txt = sprintf([txt '; r^2 = %.3f'],rsq);
            fitTxt{n+1,:} = txt;
        end
        
        text(.25,.01,fitTxt,'parent',ax, ...
            'verticalalignment','bottom','units','normalized');
        
        set(findall(gcf,'-property','FontSize'),'FontSize',14)
    end
    %%

    %%
    % Delete blank .png files.
    if doTrimFrames
        %%
        % Bad idea to run this inside a script.
        %     publish('main.m','html')
        %%
        
        cd('./html')
        delete('main.png')
        files = ls('*.png');
        C = strsplit(files);
        for f = C
            fname = f{:};
            if strcmp(fname,'')
                continue
            end
            %         imSeqNumIndex = regexpi(fname,'\d*.png');
            
            % Delete odd-numbered images.
            if mod(str2num(fname(end-4)),2)
%             % Delete even-numbered images.
%             if ~mod(str2num(fname(end-4)),2)
                delete(fname);
                fprintf([fname ' deleted\n']);
            end
        end
        cd('..')
    end
    
    
    
    %% Ramp
%     syms x
%     for t0 = 1:5
%         x1 = 0.5;
%         x2 = 0.5+t0;
%         tri = triangularPulse(x1,x2,x);
%         r = rectangularPulse(x1,mean([x1,x2]),x);
%         ramp = (tri*r)*500;
%         ezplot(ramp,[0 5])
%         axis auto
%         pause(0.05)
%     end

end
%%
