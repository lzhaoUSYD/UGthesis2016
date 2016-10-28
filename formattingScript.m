% close all

% Refer to mitthesis.cls
textWidth = 6;  % in
textHeight = 9; % in
%% Assumes settings have been set, this just to execute the settings.

[status,cmdout] = system(['find ' folder ' -type f -name "*.fig"']);
files = strsplit(cmdout,'\n')';
% Kill random empty string.
files(cellfun(@(x) isempty(x),files)) = []
% celldisp(files)

numFiles = length(files);
% fileArray = 1:numFiles;

%% ONLY WORKS FOR ONE MODE AT A TIME
for f = 1:numFiles
    % filesOrdered
    fname = files{f};
    eIndex = regexpi(fname,'\d*.fig');
    e = str2num(fname(eIndex:end-4));
    filesOrdered{e} = fname;
end
filesOrdered = filesOrdered(cellfun(@(x) ~isempty(x),filesOrdered));

% celldisp(filesOrdered)
% for f = filesOrdered
%     f{:}
% end
%%
% return
% % % TODO COMMENT OUT
% if numFiles > 5
%     % Takes too long for testing, reconfiguring
%     fileArray = 1%:3;
% end

if exist('justTesting','var')
    if justTesting
        fileArray = 1;
    end
end
% fileArray = 1:3;
for f = 1:numFiles
    % Open file
    file = filesOrdered{f}
    uiopen(file,1)
    
    % Set settings
    hfig = gcf;
    ax = gca;
    % \begin Weird hack, don't know why Position screws up if already set
    % to maximise. So just set any other position. Also needs a delay apparently.
    set(hfig,'Position',[0.5 0.5 0.5 0.5],'PaperPositionMode', 'auto')
%     set(1);
    paperDim = [10,12];
    set(gcf,'papersize',paperDim)
    set(gcf,'paperposition',[0 0 paperDim])
    
    pause(0.05)
    % \end weird hack
    set(hfig,'Units','Normalized','Position',figPos)
    if ~exist('font','var')
        font = 'Arial';
    end
    set(findall(hfig,'-property','FontSize'),...
        'FontSize',fsize,'FontName',font,'FontWeight','normal')
%     set(hfig, 'ToolBar', 'none','menubar','none');
    ax.XLabel.Interpreter = 'latex';
    ax.YLabel.Interpreter = 'latex';
    
    if exist('killCBar','var')
        if killCBar
            c = colorbar;
            delete(c)
        end
    end
    
    
    
    % Need title for fixTableScript.m
    if exist('fixTable','var')
        if fixTable
            % This script is doing more and more than just fixing the
            % table.
            fixTableScript
        end
    end
    
    if exist('cAxis','var')
        caxis(cAxis)
%         caxis([-30 130])
    end
    
    if exist('killTitle','var')
        if killTitle
%             ax = gca;
            delete(ax.Title)
        end
    end
    
    if exist('grayscale','var')
        if grayscale
            scat = findobj(gca, 'type', 'scatter');
            scat.CData = scat.CData*0 + 0.5;
        end
    end
    
    
    if exist('xLabel','var')
        xlabel(xLabel)
    end
    if exist('yLabel','var')
        ylabel(yLabel)
    end
    if exist('zLabel','var')
        zlabel(zLabel)
    end
    
    scale = 0.3;
    pos = get(gca, 'Position');
    pos(2) = pos(2)+scale*pos(4);
    pos(4) = (1-scale)*pos(4);
    set(gca, 'Position', pos)
    axis equal

    if exist('axEq','var')
        if axEq
            axis equal
        end
    end
    
    
    % Change axis limits after making the scale equal.
    if exist('axLims','var')
        axis(axLims)
    end
    
    
    
    % Change view after changing axes.
    if exist('changeView','var')
        if view2
            view(2)
        else
            view([az,el])
        end
    end
    
    % Make the scatter plot more readable
    %%
%     ax.Children(end).SizeData = abs(log(ax.Children(end).CData-min(ax.Children(end).CData))).^2;
%     colorData = ax.Children(end).CData;
%     minC = min(colorData);
%     maxC = max(colorData);
%     
%     % Normalise scatter size from 1 to 25 for the scatter size.
%     temp = (colorData - minC).^2;
%     scaling = max(temp)/25;
%     
%     ax.Children(end).SizeData = temp/scaling + 0.01;
%     ax.Children(end).LineWidth = 0.5;
    %%
    %     axis auto
    % Scope out z-range
    %     view([90,0])
    
    % ONLY IF CERTAIN
    if exist('doSave','var')        
        if doSave
            [~,figName,~] = fileparts(file);
            savefig(gcf,figName)
        end
    end
    
%     close
end


