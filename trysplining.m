% Assumes cOrdered exists as [x,y,z,V] ordered along the spiral.
% Only geometry is of interest here (x,y,z).

function [cOrdered,interpxyz] = trysplining(c,varargin)
switch nargin
    case 1
        skipSize = 20; % 1 means no skipping
    case 2
        skipSize = varargin{1};
end

cOrdered = orderCoords(c);

%% Thin the samples
% How far to step along the samples.
cSample = cOrdered(1:skipSize:end,1:3);

interpxyz = splining(cSample);
hold on;

plot3(c(:,1),c(:,2),c(:,3),'k.');

end