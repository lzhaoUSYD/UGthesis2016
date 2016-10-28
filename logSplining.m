% Adapted from Wong 2015
% Input a txt file of (tab-separated) 3D coordinates.

function interpxyz = logSplining(in,varargin)

verbose = 0;
doSave = 0;
%% Set up constants

if nargin > 1
    % Number of fibres desired
    % For 1500 data points (from one trial each):
    % 12.4 s for 100
    % 69.8 s for 1e4
    % 16.6 s for 1e3
    splinePoints = varargin{1};
else
    splinePoints = 500;
end

% Number of nodes along each fibre (for the first pass)
% Use at least the number of key points
fibre_nodes_first_pass = 20;

% Accuracy of trim - Use 25 in final
trim_accuracy = 25;

% Spacing between nodes of Ranvier (in millimetres)
PP_spacing = 0.175;
axon_spacing = 0.300;

% Start timer
timer_start = tic;

%% Pre-process inputs
if isa(in,'double')
    % Input is an array.
    coords = in;
elseif exist(in, 'file') == 2
    % Input is a file which exists where it's expected to.
    % fname = 'topCurve.txt';
    fname = in;
    coords = load(fname);
else
    warnStr = 'Check that the input is an array of coordinates OR a txt file with 3 tab-separated columns.';
    warning(warnStr)
    return
end

% Check it's a n x 3 array. Currently fine but better to be safe.
[rows,cols] = size(coords);
if any([rows,cols] == 3)
    if rows == 3
        coords = coords';
    else
        % 3 columns, all good.
    end
else
    % m x n array, m ~= 3 and n ~= 3
    warning('Check that the input is an n x 3 array of coordinates.')
end



%% Calculate interpolated points
px = coords(:,1); % These are temporary variables for plotting points
py = coords(:,2);
pz = coords(:,3);
interpxyz = logInterparc(splinePoints, px, py, pz);

if verbose
    timer_stop = toc(timer_start);
    fprintf('Seconds/fibre_count = %.4f\n',timer_stop/splinePoints);
end
end