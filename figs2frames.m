% Gets all open figures and save as .png along with rotations.

% Able to rotate at worst 10 frames/sec.
% Nope, 1125 s for 720 frames = 1.5 0.64 frames/sec
% 600s for 360 frames 

% Variables
%
% varargin
% numFrames and/or alpha
% vector

% Use figs2frames(1) just to save all open figures.

function figs2frames(numFrames,varargin)
%% Figure out processing time.
timePerFrame = 1.2/10/60; % Minutes.
estTimeMinutes = numFrames * timePerFrame;
if estTimeMinutes > 1
    numHours = floor(estTimeMinutes/60);
    numMinutes = mod(estTimeMinutes,60);
    checkBack = datestr(now + datenum(0,0,0,numHours,numMinutes,0),'HH:MM:SS dd/mmm/yyyy');
    
    checkTime = sprintf(['Estimated time for fig2frames: %d hours %.2f minutes (come back around ' checkBack '). Continue?'],...
        numHours,numMinutes)
    confirmRun = questdlg(checkTime);
    switch confirmRun
        case 'Yes'
            fprintf(['Come back around ' checkBack '\n']);
        otherwise
            disp('Cancelled.')
            return
    end
    
    timeStamp =  datestr(now,'dd-mmm-yyyy HH-MM-SS');
end
%% Video frames export
%>> Make it spin
% vidTitle = inputdlg('Title of video:');
% vidTitle = vidTitle{:};
vidDir = fullfile(pwd,'Outputs','vid');
% numFrames = 360;
alpha = 360/(numFrames-1);


if nargin > 1
    direction = varargin{1};    
else
    % Y by default.
    direction = 2;
end

switch direction
    case 1
        view([1 0 0])
        vector = [1 0 0];
        rotPadding('x')
    case 2
        view(2)
        vector = [0 1 0];
        rotPadding('y')
    case 3
        view([0 -1 0])
        vector = [0 0 1];
        rotPadding('z')
    otherwise
        error('Invalid direction')
end
% Add more space on axes for rotation.
% zlims = zlim;
% rotatePadding = 5;
% set(gca,'zlim',[zlims(1) - rotatePadding,zlims(2) + rotatePadding])

% (In-built) XY view.

figHandles = findobj('Type','figure');
for f = 1 : length(figHandles)
    % Set current figure.
    hfig = figHandles(f);
    set(0, 'currentfigure', hfig);
    htitle = get(gca,'title');
    vidTitle = strrep(htitle.String,' ','_');
%     vidTitle = vidTitle{:};
    
    % Between figures (e.g. comparing elcetrode configurations).
    %     image_name = fullfile(vidDir, strcat(vidTitle,'_',num2str(f),'.png'));
    image_name = fullfile(vidDir, strcat(vidTitle,'.png'))
    print(hfig, '-dpng', image_name);
    
    for i = 1:numFrames - 1
        % Within figures (rotating result figure).
        image_name = fullfile(vidDir, strcat(vidTitle,'_',num2str(i),'.png'));
%         
%         set(gcf,'units','centimeters')
%         axis equal
% 
%         paperDim = [10,12];
%         set(gcf,'papersize',paperDim)
%         set(gcf,'paperposition',[0 0 paperDim])
        print(hfig, '-dpng', image_name);

        %
        %>> Actually rotate it.
        % Selects lines, scatter and text on the plot.        %         alpha = 15; % For testing axis of rotation.
        plotTypes = {'line','scatter','text'};%,'hggroup','patch'};
        for p = plotTypes
            handles = findobj(gca,'type',p{:});
            if ~isempty(handles)
                % Modified rotate.m function to do the same work for
                % scatter plots as well (originally only accepted line,
                % text etc but not scatter).
                rotateEdL(handles,vector,alpha)
            end
        end
%         axis([48 72,90 100,123 147,-16e-3 15e-3])
        
        %         % ABANDONED Set desired viewpoint as axis of rotation.
        %         [az,el] = view;
        % %         vectoryz = [0;cos(el);sin(el)];
        %         vectordir = [cos(az),sin(az),0;
        %             -sin(az),cos(az),0;
        %             0,0,1];
        % %         vector = vectordir*vectoryz;
        %         vector = [sin(az)*cos(el);
        %             cos(az)*cos(el);
        %             sin(el)];
        % [az,el] = view;
        % z = sin(el);
        % hyp = cos(el);
        % y = hyp*cos(az);
        % x = hyp*sin(az);
        % vector = [x,y,z]
        % % vector = [58-56,94-95.6,133-133.1];
        %
        % vectorTop = [-0.3761    0.1782    0.9093];
        % alpha = 15; % For testing axis of rotation.
        % plotTypes = {'line','scatter','text'};%,'hggroup','patch'};
        % for p = plotTypes
        %     handles = findobj(gca,'type',p{:});
        %     if ~isempty(handles)
        %         rotateEdL(handles,vectorTop,alpha)
        %     end
        % end
        % axis equal
        % axis([42 62,80 100,123 147,-16e-3 15e-3])
        
        %         %>> Move the camera.
        %         camorbit(alpha,0,'coordsys',vectorY);
        
        
        %         hlines = findobj(gca,'type','line');
        %         htext = findobj(gca,'type','text');
        %         rotate(hlines,vectorY,alpha)
        %         if ~isempty(htext)
        %             rotate(htext,vectorY,alpha)
        %         end
    end
end
    % DEPRECATED Padding for rotating about y vector.
    function padding(direction)    
        tag = [direction 'lim'];
        dirLim = get(gca,tag);
        dirRange = abs(dirLim(1)-dirLim(2));
        padding = dirRange * 0.1;
        dirMin = dirLim(1)-padding;
        dirMax = dirLim(2)+padding;   
        set(gca,tag,[dirMin dirMax])
    end
end