% Original: determines segment lengths from the nerve trunk up.

function nodeSpacing = segmentBSPold(nodes,varargin)
if nargin == 2;
    doVisualise = varargin{1};
else
    doVisualise =  0;
end

%% Algebraic node spacing
% REF: Kalkman et al 2014 Fig 4
internode = 1; % µm

syms x_micron
nodeSpacingSym_micron = [x_micron,x_micron,x_micron,...
    0.6*x_micron,0.4*x_micron,0.2*x_micron,...
    100,30,150,200,250,300,350]; % µm
% REF:
% Erixon 2009: ~1.5 mm of peripheral process (human).
% Rattay 2000: (by eye, of diagram) 250, 300, 300, 300, 350, 350 [soma] 500
% so ~1.8 mm.
% Kalkman 2014: 1.38 mm of central axon included.
% Between periphery & proximal end of Kalkman's central axon: ~3 mm
% Spline length of this model: 11-16 mm. Pad out the rest with a big
% 8 mm chunk.
chunk = 14500; % µm
nodeSpacingSym_micron = [nodeSpacingSym_micron chunk];

%% Create spline
% Arbitrary process segment "length" to start with. splining.m only
% factors in relative lengths, not absolute.
xLength_micron = 600;

itLimit = 3;
tmp = 0;
% REF: Briaire & Frijns 2006.
maxSegLength_micron = 400; % µm

nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron)/1000);

% As input to interparc.m, make it a cumulative array and normalise to
% between 0 and 1 (dimensionless).
nodeSpacingCum = cumsum(nodeSpacing_micron);
nodeSpacing = nodeSpacingCum./nodeSpacingCum(end);

spline_mm = splining(nodes,nodeSpacing);

%% Get lengths of segments
% Euclidean distances between coordinates in the spline, in µm.
diffs_micron = (spline_mm(1:end-1,:) - spline_mm(2:end,:))*1000;
dists_micron = sqrt(sum(diffs_micron.^2,2))';
% Total length of spline
splineLength_micron = sum(dists_micron);



%% Adjust node spacing
xLength_micron = dists_micron(1);
while xLength_micron > maxSegLength_micron && tmp < itLimit
    % Put an extra peripheral segment in.
    nodeSpacingSym_micron = [x_micron nodeSpacingSym_micron];
    % Reconfigure node spacing array.
    sumSegments_micron = sum(nodeSpacingSym_micron);
    sumInter_micron = (numel(nodeSpacingSym_micron)-1)*internode;
    totalLength_micron = sumSegments_micron + sumInter_micron;
    % Solve for new configuration.
    new_xLength_micron = double(solve(totalLength_micron - splineLength_micron));
    
    if new_xLength_micron < 0
        break
    else
        xLength_micron = new_xLength_micron;
    end
        
    %% Re-spline & re-check
    nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron));
    
    nodeSpacingCum = cumsum(nodeSpacing_micron);
    nodeSpacing = nodeSpacingCum./nodeSpacingCum(end);
    
    spline_mm = splining(nodes,nodeSpacing);
    
    if doVisualise
    %% Illustrative purposes only. 
    % Put these lines in the code calling segmentBSP.
%     figure('units','normalized','position',[0.5,0,0.5,1]);
%     hold on; rotate3d; view([-155.5,-80])     
        coords = spline_mm;
        x = coords(:,1);
        y = coords(:,2);
        z = coords(:,3);
        plot3(x,y,z,'--x')
        pause(0.1)
    end
    
    diffs_micron = (spline_mm(1:end-1,:) - spline_mm(2:end,:))*1000;
    dists_micron = sqrt(sum(diffs_micron.^2,2))';
    splineLength_micron = sum(dists_micron);
    
    xLength_micron = dists_micron(1);
    
    tmp = tmp + 1;
end
%% Final result
nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron));

nodeSpacingCum = cumsum(nodeSpacing_micron);
nodeSpacing = [0 nodeSpacingCum./nodeSpacingCum(end)];

end
