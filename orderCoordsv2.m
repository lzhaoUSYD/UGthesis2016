function cOrdered = orderCoordsv2(c)
%% Devastating problem
% Encountering NaNs from gradient between points that have the same x or y or z
% coordinates.

%% Thin the samples
% How far to step along the samples.
skipSize = 1;
c0 = c;
c = c(1:skipSize:end,1:3);


% c contains coordinates (x,y,z) and V.

verbose = 1;

dims = size(c);

numCoords = dims(1);

% Columns 1 to 3 for (x,y,z) data.
xyzRange = 1:3;

%% Nearest-neighbour search
% One way to try to order the coordinates along the spiral by a
% nearest-neighbour search. Accuracy not guaranteed.
cOrdered = zeros(dims);
refPoint = c(1,:);
thisPoint = c(2,:);
cOrdered(1,:) = refPoint;
% Why did I kill this?
% c(1,:) = [];
% Iterate this many times, regardless of indexing.
for i = 1 : numCoords
%     thisPoint = c(i,xyzRange);
    
    % Find the 3 nearest neighbours (and itself).
    numNeighbours = 3;
    [idx,~] = knnsearch(c(:,xyzRange),thisPoint,'k',numNeighbours+1);
    
    % Exclude index 1 because that's itself.
    compPoints = c(idx(2:end),:);
    
    
    %     grad0 =
    
    % Factor in gradient by using first principles of derivatives. Simple
    % dy/dx and dz/dx.
    [refdydx,refdzdx] = firstPrinciples(thisPoint,refPoint);
    
    nGrad = zeros(numNeighbours,3);
    for n = 1:numNeighbours
        compPoint = compPoints(n,:);
        [compdydx(n,:),compdzdx(n,:)] = firstPrinciples(compPoint,thisPoint);
        %         [coords;c(idx(n+1),:)]
        %        nGrad(n,:) = gradient()
    end
    
    % Evaluation
    diffxyz = sum(abs(compPoints - ones(numNeighbours,1)*thisPoint),2)
    diffGrad = sum(abs(ones(3,1)*[refdydx,refdzdx] - [compdydx compdzdx]),2)
%     disp('Difference in coordinates')    
%     disp('Difference from reference gradient')
%     disp('Difference in coordinates + difference from reference gradient')%     
    arbitrary = [diffxyz+diffGrad]
        
    %* Assign the nearest neighbour as the next in the array of
    % coordinates. Use index 2 because index 1 is itself.
    self = idx(1);
    idxNextPoint = idx(arbitrary == min(arbitrary))
    nextPoint = c(idxNextPoint,xyzRange);
    cOrdered(i+1,:) = c(idxNextPoint,:);
    %     % Remove that from the array to avoid duplicates.
    %     c0(idx,:) = [];
    
    if verbose
        fprintf('i = %.0f; (%.2f,%.2f,%.2f) closest to (%.2f,%.2f,%.2f). c0 size = [%.0f,%.0f]\n',...
            i,thisPoint,nextPoint,size(c));
    end
    
    refPoint = thisPoint;
    % Assume the match coords as the new coords to be matched. This could
    % be done at * but is done here for fprintf purposes.
    thisPoint = nextPoint;
    % Delete the original to avoid looping back and forth.
    c(self,:) = [];
end

% Hacky fix for value that went missing somewhere in the above process.
cOrdered(end,:) = [];

% %% screw this Intelligently segment and rejoin to get one continuous curve
% %> Find large distances between consecutive coordinates, to treat as
% % discontinuities.
% distances = dist([cScMedia,circshift(cScMedia,1)]');
% distAdj = diag(distances,1);
% [~,locs] = findpeaks(distAdj,'MinPeakHeight',1);
%
% %> Segment according to large distances.
% % Ignore the last peak because it's from the circular shift.
% numLocs = length(locs) - 1;
%
% segments = cell(numLocs,1);
% heads = cell(numLocs,1);
% tails = cell(numLocs,1);
% loc0 = 1;
%
% for l = 1 : numLocs
%     loc1 = locs(l);
%     % Segment of coordinates
%     segment = cScMedia(loc0:loc1,:);
%     segments{l} = segment;
%     heads{l} = segment(1,:);
%     tails{l} = segment(end,:);
%     loc0 = loc1;
% end
%
% % Iterate along head/tail of discontinuities to find small distances, to
% % treat as expected continuities.
%
% % Join according to small distances.
%
% end
    function [dydx,dzdx] = firstPrinciples(P,Q)
        dydx = (P(2)-Q(2)) / (P(1)-Q(1));
        dzdx = (P(3)-Q(3)) / (P(1)-Q(1));
    end
end