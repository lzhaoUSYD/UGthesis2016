% Takes a loop and generates a spiral of n turns for any real, positive n.
function spiral = spiralPlanar(loop,turns,direction)
% Determine number of points required to generate.
numCoords = size(loop,1);
n = ceil(numCoords * turns);

% Set up output matrix
spiral = nan(n,3);

% Direction of the spiral i.e. scaling from 0 to 1 or 1 to 0.
scalingFactor = linspace(1-direction,direction,n);

for s = 1:n
    k = scalingFactor(s);
    tmp = resizeLoop(loop,k);
    spiral(s,:) = tmp(mod(s,numCoords)+1,:);
end
end