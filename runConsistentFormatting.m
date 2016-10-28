

% % Script of all relevant figures to open, resize fonts/format etc. 


% %% lol
% % uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/justbecauseitlookscool.fig',1)
% 
% 
% %% Comsol coordinates
% 
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/Array.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/BonyLab.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/CNVII.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/CNVIII.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/notSure.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/NTrunk.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/ScMedia.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/ScTymp.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/ScVest.fig',1)
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Comsol figures/SpGang.fig',1)
% 
% axis([45 60 89 100 128 140]) % to fit everything in the same scale
% view(-37.5,50)
% %% Splining: early
% 
% %% Splining: refined
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/spiralSpline.fig',1)
% 
% 
% set(0, 'defaultTextInterpreter', 'latex');
%% Summary of settings 
% clear
% close all
% 
% folder = './Outputs/finalFormattingRun/Splining';

% figPos
% fsize
% font
% 
% killBar
% fixTable
% killTitle
% grayscale
% 
% xLabel
% yLabel
% zLabel
% 
% axEq
% axLims
% 
% view2
% [az,el]
% 
% doSave

% formattingScript
%%
% clear
% close all
% [status,cmdout] = system('find ./Outputs/finalFormattingRun -type f -name "*.fig"');
% files = strsplit(cmdout,'\n')';
% % celldisp(files)
% 
% for f = files
%     file = f{:}
%     uiopen(f{:},1)
%     set(findall(gcf,'-property','FontSize'),...
%         'FontSize',18,'FontName','Cambria')
%     savefig(gcf,file)
% end
%     ,'Interpreter','LaTeX'
%% Comsol figs DONE
% % Array.fig
% % BonyLab.fig
% % CNVII.fig % DELETED BECAUSE ANNOYING AXIS LIMITS
% % CNVIII.fig
% % NTrunk.fig
% % ScMedia.fig
% % ScTymp.fig
% % ScVest.fig
% % SpGang.fig
% clear
% close all
% 
% folder = './Outputs/finalFormattingRun/comsolFigs';
% 
% fsize  = 20;
% font   = 'Cambria';
% figPos = [0.5 0 0.5 0.5];
% 
% killCBar = 1;
% grayscale = 1;
% 
% changeLabels = 1;
% xLabel = 'x (mm)';
% yLabel = 'y (mm)';
% zLabel = 'z (mm)';
% 
% changeView = 1;
% view2 = 1;
% % 
% axLims = [47,65,89,100,128,140];
% axEq = 1;
% 
% justTesting = 1;
% 
% doSave = 1;
% 
% formattingScript

%% Splining DONE
% clear
% close all
% 
% folder = './Outputs/finalFormattingRun/Splining';
% 
% fsize  = 20;
% font   = 'Cambria';
% figPos = [0 0 1 1];
% 
% killCBar  = 1;
% killTitle = 1;
% 
% changeLabels = 1;
% xLabel = 'x (mm)';
% yLabel = 'y (mm)';
% zLabel = 'z (mm)';
% 
% justTesting = 0;
% doSave = 1;
% 
% formattingScript
%% Potentials XY view
clear
close all

% folder = './Outputs/finalFormattingRun/XYviewPotentials';
folder = fullfile(pwd,'Outputs','finalFormattingRun','XYviewPotentials');

fsize  = 20;
font   = 'Arial';
figPos = [0 0 1 1];

fixTable    = 1;
% TODO find out actual range for clims
% cAxis = [0 100];
killTitle   = 1;

formattingScript

%%

% ax.Children(end).MarkerFaceColor = [1 1 1]

% ax.Children(end).SizeData = exp(ax.Children(end).CData)
%%
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/XYviewPotentials/Monopolar 11.fig',1)
% hfig = gcf;
% hfig.Units = 'inches';
% set(hfig,'PaperPosition',[0 0 6 9])


%%


    %%
% runMakeVideo