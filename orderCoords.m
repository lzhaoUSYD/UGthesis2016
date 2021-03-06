function cOrdered = orderCoords(c)
% c contains coordinates (x,y,z) and V.

verbose = 0;

dims = size(c);

numCoords = dims(1);

% Columns 1 to 3 for (x,y,z) data.
xyzRange = 1:3;

%% Nearest-neighbour search
% One way to try to order the coordinates along the spiral by a
% nearest-neighbour search. Accuracy not guaranteed.
cOrdered = zeros(dims);
cOrdered(1,:) = c(1,:);
coords = cOrdered(1,xyzRange);
c(1,:) = [];
for i = 1 : numCoords - 2
%     coords = c0(i,xyzRange);
    % Find the nearest neighbour.
    [idx,~] = knnsearch(c(:,xyzRange),coords,'k',2);
    %* Assign the nearest neighbour as the next in the array of
    % coordinates. Use index 2 because index 1 is itself.
    self = idx(1);
    match = idx(2);
    nearest = c(match,xyzRange);
    cOrdered(i+1,:) = c(match,:);
    %     % Remove that from the array to avoid duplicates.
    %     c0(idx,:) = [];
    
    if verbose
        fprintf('i = %.0f; (%.2f,%.2f,%.2f) closest to (%.2f,%.2f,%.2f). c0 size = [%.0f,%.0f]\n',...
            i,coords,nearest,size(c));
    end
    
    % Assume the match coords as the new coords to be matched. This could
    % be done at * but is done here for fprintf purposes.
    coords = nearest;
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
end