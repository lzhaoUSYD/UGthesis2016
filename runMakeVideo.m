% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/Splining/splineSpiralWithELabels.fig',1)
close all
figAdd = '/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/XYviewPotentials/BP+1 5.fig';

% Check extension string if want robustness. Just want the file name right
% now to identify it.
[~,figName,~] = fileparts(figAdd);
numIndex = regexp(figName,'\d');

figNameParts = strsplit(figName);
e = str2double(figNameParts{2});
stimMode = figNameParts{1};

uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/XYviewPotentials/BP+1 5.fig',1)
% uiopen(figAdd);
hfig = gcf;


%
% Standardise fonts



% Quick run for testing
% titleStr = 'Fischer et al 2016 STN-DBS Coronal to scale';
% title(titleStr)

% If publishing, try this. Only works for single figure. Or close figures
% successively, and still avoid that annoying empty figure from publish().
% close
% hfig = figure(1);

% % If not publishing, stay with this.
htitle = get(gca,'title');

titleStr = htitle.String;
% titleStr = titleStr{:};
if isempty(titleStr)
    titleStr = inputdlg('Title: ');
    titleStr = titleStr{:};
    title(titleStr)
end

% Kill the table because it prints out poorly.
hfig = gcf;
delete(findall(hfig,'-property','ColumnWidth'));
set(hfig,'Position',[0 0 1 1])

hax = gca;
axLeft = 0.07;
axWidth = 1 - 2.3*axLeft;
axBot = 0.15;
axHeight = 1 - axBot*1.4;
set(hax,'Position',[axLeft axBot axWidth axHeight])
axis equal

set(hfig, 'menubar', 'none', 'toolbar', 'none');
set(findall(hfig,'-property','FontSize'),...
    'FontSize',24,'FontName','Cambria')


%% ABANDONED Just rotate
axis equal

direction = 2; % Y-direction.
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
% Degrees in each revolution.
alpha = 0.5;
% Number of revolutions.
numRev = 3*alpha/360; 
numRev = 1;
rotArray = 1:numRev*360/alpha;

tic
for r = rotArray
    rotatePotentialPlot(alpha,vector)
    %     pause(1)
    %     hfig = copy(hfig);
    %%
    %%
    %     fig1 = get(hfig,'children');
    %     hfig2 = figure('units','normalized','position',[0 0 1 1]);
    %     copyobj(fig1,hfig2)
    %     hfig = copy(hfig2);
    %     close(hfig2)
    %     axis equal
end
toc
%
% %% Rotate and save
% %
% % close all
% % uiopen('B:\Luke\Dropbox\UNI\Thesis\Modelling\NerveTrajectories\spiralSplineNew.fig',1)
% % set(gcf, 'units','normalized','position',[0 0 1 1]);
% % % set(gcf, 'Position', get(0, 'Screensize'));
% % set(findall(gcf,'-property','FontSize'),'FontSize',8)
% % zoom out
% %
% % tic
% % figs2frames(4,2)
% %
% % toc
% % 513 s for 360 frames
% %
%
% %% Then turn .png files into .avi
%
% % tic
% % fname = strrep(titleStr,' ','_');
% % frames2video(fname)
% % toc
%
% %% DEPRECATED: IMPLEMENTED IN runProcessingV2.m
% % % Activating function comparisons
% % % ECHO runPostprocessingV2.m
% % fnames = {...
% %     'MP';
% %     'BP';
% %     'BP1';
% %     'BP2';
% %     'TP';
% %     'pTPsig067';
% %     'pTPsig033';
% %     };
% %
% % for f = 1:length(fnames)
% %     tic
% %     frames2video(fnames{f},0.3)
% %     toc
% % end
%
% % % %% Full run
% % % Uses currently open figures and creates n frames of a 360 rotation about
% % % the vector [0 1 0].
% % tic
% % figs2frames(200)
% % toc
% % % Finds all .png files beginning with vidTitle and compiles them into a
% % % video (.avi). Put files in the Nerve trajectories/Outputs/vid/ folder.
% % vidTitles = {'Monopolar';
% %     'Bipolar';
% %     'BP+1';
% %     'BP+2';
% %     'Tripolar';
% %     'Partial Tripolar'};
% % vidTitle = 'MP';
% % for v = 1:length(vidTitles)
% %     vidTitle = vidTitles{v};
% %     tic
% %     frames2video(vidTitle)
% %     toc
% % end