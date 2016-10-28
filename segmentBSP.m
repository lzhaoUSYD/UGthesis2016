% Segment 
%> PARAM nodes:       starter spline.
%> PARAM varargin{1}: switch for visualising the adaptive segmentation
%>                    algorithm.
%> OUT   fullFibre:   array of segment lengths in µm
%> OUT   nodeSpacing: fullFibre normalised to between [0,1] for interparc.m 
%>                    as used in splining.m

% Spline length of this model: 11-16 mm. Pad out the rest with a 350 µm
% chunks.

function [nodeSpacingNorm,nodeSpacing] = segmentBSP(nodes,varargin)
if nargin == 2;
    doVisualise = varargin{1};
else
    doVisualise =  0;
end

%% Get lengths of segments
% Euclidean distances between coordinates in the spline, in µm.
diffs_micron = (nodes(1:end-1,:) - nodes(2:end,:))*1000;
dists_micron = sqrt(sum(diffs_micron.^2,2))';
% Total length of spline
splineLength_micron = sum(dists_micron);
% Length of starter spline distal to soma.
starterSeg_micron = dists_micron(1);

%% Start from the soma
% Determine segment lengths from the soma outwards. Soma defined as 1.5 to
% 1.8 mm from the primary spline, along the secondary spline.
% REF:
% Erixon 2009: ~1.5 mm of peripheral process (human). Rattay 2000: (by
% eye, of diagram) 250 [NoR] 300 [NoR] 300 [NoR] 300 [NoR] 350 [NoR] 350
% [soma] 500 so ~1.8 mm.
% Kalkman 2014: 1.38 mm of central axon included. Between periphery &
% proximal end of Kalkman's central axon: ~3 mm
% somaMin_micron = 1.5e3; % µm
% somaMax_micron = 1.8e3; % µm
% somaMid_micron = mean([somaMin_micron,somaMax_micron]);
% tolerance_micron = somaMax_micron - somaMid_micron;
% 
% if abs(starterSeg_micron - somaMid_micron) < tolerance_micron*1.5
%     % Coordinates at proximal end of soma
%     somaProximal_mm = nodes(1,:);
% else
%     error('Recheck preliminary starter spline for first segment to fall within %d to %d µm',somaMin_micron,somaMax_micron)
% end


%% Adaptive peripheral process length & number of central axon segments.
% REF: Kalkman et al 2014 Fig 4

syms periSegSym_micron numCentralSegsSym

%>>> Algebraic expression towards periphery.
periphery = [periSegSym_micron,periSegSym_micron,periSegSym_micron,...
    0.6*periSegSym_micron,0.4*periSegSym_micron,0.2*periSegSym_micron,...
    100,30];
sumSegments_micron = sum(periphery);

% Factor in internodes.
internode = 1; % µm
sumInter_micron = (numel(periphery)-1)*internode;

% Total algebraic length.
totalPeriLength_micron = sumSegments_micron + sumInter_micron;

% Solve for peri_micron using length of spline up to soma.
periSeg_micron = double(solve(starterSeg_micron - totalPeriLength_micron));

% REF: Briaire & Frijns 2006.
maxPeriSegLength_micron = 400; % µm

if periSeg_micron > maxPeriSegLength_micron
    % Put an extra peripheral segment in.
    periphery = [periSegSym_micron periphery];
    % Reconfigure node spacing array.
    sumSegments_micron = sum(periphery);
    sumInter_micron = (numel(periphery)-1)*internode;
    totalLength_micron = sumSegments_micron + sumInter_micron;
    % Solve for peri_micron using length of spline up to soma.
    periSeg_micron = double(solve(starterSeg_micron - totalLength_micron));
end

%>>> Algebraic expression towards central axon (after soma).
centralAxon = [150,200,250,300,350,numCentralSegsSym*350]; % µm

% Get total algebraic length of the central axon.
sumSegments_micron = sum(centralAxon);
sumInter_micron = (numel(centralAxon)-1)*internode;
totalLength_micron = sumSegments_micron + sumInter_micron;

% Length of starter spline proximal to soma.
starterSegProx = splineLength_micron-starterSeg_micron;

% Solve for centralSym_micron using length of spline after soma.
numCentralSegs = ceil(double(solve(starterSegProx - totalLength_micron)));

centralAxon = [centralAxon(1:end-1) 350*ones(1,numCentralSegs)];

% fprintf('Peripheral segments: %.2f µm; No. central segments: %d\n',periSeg_micron,numCentralSegs);

%>>> The whole nerve fibre.
fullFibreSym = [periphery,centralAxon];
fullFibre = double(subs(fullFibreSym,...
    {periSegSym_micron,numCentralSegsSym},...
    {periSeg_micron,numCentralSegs}));

% Cumulative sum, normalised between 0 and 1.
nodeSpacingCum = cumsum(fullFibre);
nodeSpacingNorm = [0 nodeSpacingCum./nodeSpacingCum(end)];
nodeSpacing = fullFibre;

%% Algebraic node spacing
% % REF: Kalkman et al 2014 Fig 4
% internode = 1; % µm
%
% syms x_micron
% nodeSpacingSym_micron = [x_micron,x_micron,x_micron,...
%     0.6*x_micron,0.4*x_micron,0.2*x_micron,...
%     100,30,150,200,250,300,350]; % µm
%
% chunk = 14500; % µm
% nodeSpacingSym_micron = [nodeSpacingSym_micron chunk];

% %% Create spline
% % Arbitrary process segment "length" to start with. splining.m only
% % factors in relative lengths, not absolute.
% xLength_micron = 600;
%
% itLimit = 3;
% tmp = 0;
% % REF: Briaire & Frijns 2006.
% maxPeriSegLength_micron = 400; % µm
%
% nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron)/1000);
%
% % As input to interparc.m, make it a cumulative array and normalise to
% % between 0 and 1 (dimensionless).
% nodeSpacingCum = cumsum(nodeSpacing_micron);
% nodeSpacing = nodeSpacingCum./nodeSpacingCum(end);
%
% spline_mm = splining(nodes,nodeSpacing);
%
% %% Get lengths of segments
% % Euclidean distances between coordinates in the spline, in µm.
% diffs_micron = (spline_mm(1:end-1,:) - spline_mm(2:end,:))*1000;
% dists_micron = sqrt(sum(diffs_micron.^2,2))';
% % Total length of spline
% splineLength_micron = sum(dists_micron);
%


% %% Adjust node spacing
% xLength_micron = dists_micron(1);
% while xLength_micron > maxPeriSegLength_micron && tmp < itLimit
%     % Put an extra peripheral segment in.
%     nodeSpacingSym_micron = [x_micron nodeSpacingSym_micron];
%     % Reconfigure node spacing array.
%     sumSegments_micron = sum(nodeSpacingSym_micron);
%     sumInter_micron = (numel(nodeSpacingSym_micron)-1)*internode;
%     totalLength_micron = sumSegments_micron + sumInter_micron;
%     % Solve for new configuration.
%     new_xLength_micron = double(solve(totalLength_micron - splineLength_micron));
%
%     if new_xLength_micron < 0
%         break
%     else
%         xLength_micron = new_xLength_micron;
%     end
%
% %% Re-spline & re-check
% nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron));
% 
% nodeSpacingCum = cumsum(nodeSpacing_micron);
% nodeSpacing = nodeSpacingCum./nodeSpacingCum(end);
% 
% spline_mm = splining(nodes,nodeSpacing);
% 
% if doVisualise
%     %% Illustrative purposes only.
%     % Put these lines in the code calling segmentBSP.
%     %     figure('units','normalized','position',[0.5,0,0.5,1]);
%     %     hold on; rotate3d; view([-155.5,-80])
%     coords = spline_mm;
%     x = coords(:,1);
%     y = coords(:,2);
%     z = coords(:,3);
%     plot3(x,y,z,'--x')
%     pause(0.1)
% end
% 
% diffs_micron = (spline_mm(1:end-1,:) - spline_mm(2:end,:))*1000;
% dists_micron = sqrt(sum(diffs_micron.^2,2))';
% splineLength_micron = sum(dists_micron);
% 
% xLength_micron = dists_micron(1);
% 
% tmp = tmp + 1;
% end
%% Final result
% nodeSpacing_micron = double(subs(nodeSpacingSym_micron,x_micron,xLength_micron));

end
