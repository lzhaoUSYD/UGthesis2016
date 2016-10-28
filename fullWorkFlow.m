%% BEFORE RUNNING THIS SCRIPT:
% Remember to:
% - Comment out all settings/flags in the scripts, otherwise they will
% override the settings in this script.
% - Comment out/move all checks/warnings for long simulations.



%% Load the COMSOL model
get_coords
% TODO: specify which model, after 92 models for each configuration have
% been saved.

%% Create splines
% Compare splines against plotted structures exported from Comsol
doCompare = 0; 

% Save unordered cut points for COMSOL evaluation.
% Save frequencies, key points for plotting frequencies and coordinates
% along structure (needed only once per splining).
doSave = 0; % 
% Plot Greenwood function on the splines.
doPlotGreenwood = 0;

% Number of fibres & nodes of Ranvier to estimate locations for. First
% implementation: 40 fibres x 20 nodes. ABEC abstract: 100 fibres.
% numFibres = 3500;
% numNodesRanvier = 10;
% numFibres = 100;
% numNodesRanvier = 20;

runSplines

%% Interface Comsol for setting electrode configurations and computing potentials
% Reference current for all stimulation configuration settings.
I0default = 0.1065; % mA

% Generate a video of the figure rotating about the Y axis.
makeVid = 0;
% Save all open figures as .fig files, named by the title string.
doSaveFig = 1;

% Set up configurations.
% 1. MP
% 2. BP
% 3. BP+1
% 4. BP+2
% 5. TP
% 6. pTP
% 7. PA (not implemented yet)

% doRun = [1 0 0 0 0 0 0];
% doRun = [0 1 0 0 0 0 0];
% doRun = [0 0 0 0 1 0 0];
% doRun = ones(1,6);
% doRun = [0 0 0 1 1 1 ];
% doRun =  [0 0 0 0 0 1];
% %        1 2 3 4 5 6 7
% 
% doRun = doRun > 0; % Get a boolean
% configs = {...
%     1:22;
%     2:22;
%     3:22;
%     13:22;
%     2:21;
%     2:21};
% % sigmas for pTP
% sigmas = [0.2 2];

% runStimPatternsV2
runStimPatternsV3
%% Load results
loadSimFn

%% Compute activating function
runPostprocessing
% runMakeVideo

%% Make gifs of AF
ffmpegGenerator
%% 