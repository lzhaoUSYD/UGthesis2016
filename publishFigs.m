close all

% % publish for latex in one go.
% 
% folder = '/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/';
folder = fullfile(pwd,'Outputs','finalFormattingRun');
folder = fullfile(pwd,'Outputs','finalFormattingRun');
folder = fullfile(pwd,'Outputs','finalFormattingRun');
folder = fullfile(pwd,'Outputs','finalFormattingRun','Splining');
folder = fullfile(pwd,'Outputs','finalFormattingRun','XYviewPotentials');
folder = fullfile(pwd,'Outputs','finalFormattingRun','dummy');
ls(folder)

fileType = '.fig';
[status,cmdout] = system(['find ' folder ' -type f -name "*' fileType '"']);
files = strsplit(cmdout,'\n')';
% Kill random empty string.
files(cellfun(@(x) isempty(x),files)) = []

uiopen(files{:},1)
%%