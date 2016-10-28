%% Load Comsol
modelAddress   = fullfile('..','COMSOL models','Phil plus MP for COMSOL v5_0');
fprintf(['Loading ' modelAddress '\n']);
tic
model = mphload(modelAddress);
toc
%% Load splines
fid = fopen('spiralSplineNew.txt');
C = textscan(fid, '%f,%f,%f');
fclose(fid);

%% Kill NaNs, Comsol can't handle them. No way to identify splines in cpt3D
coords = cell2mat(C);

hasNan = cellfun(@(x) isnan(x),C(:,1),'uniformoutput',0);
hasNan = cell2mat(hasNan);

cpt3D = coords(~hasNan,:);
%%
numSplinePoints = length(cpt3D);

for p = 1:numSplinePoints
    aPoint = cpt3D(p,:);
    dom_idx{p} = mphgetadj(model,'geom1','domain','point',aPoint);
end

dom_idx

% Do any cells have more than one element (i.e. one domain)?
any(cellfun(@(x) numel(x),dom_idx)~=1)


