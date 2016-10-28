% Assumes Phil's model has been loaded.
% Bug: cln problem somewhere in java so can't run as a function.

% function varargout = plotDomain(model,domNum)
%% Get cut points
c = mphgetcoords(model, 'geom1', 'domain', domNum)';
x = c(:,1);
y = c(:,2);
z = c(:,3);

%% Evaluate V at 3D cut points
if ~exist('cln','var')
    % Chucks an error if this exists.
    cln = model.result.dataset.create('cln', 'CutPoint3D');
end
cln.set('pointx',x);
cln.set('pointy',y);
cln.set('pointz',z);

V = mphinterp(model,'V','dataset','cln');

%% Plot

figure('units','normalized','position',[0.5,0,0.5,1]);

scatterSize = 5;
scatter3(x,y,z,scatterSize,V);

titleStr = sprintf('%s (domain %d)',domName,domNum);
title(titleStr)
xlabel('x')
ylabel('y')
zlabel('z')

hBar = colorbar;
hBar.Label.String = 'Electric potential (V)';

rotate3d on;
%
%     varargout{1} = xValues;
%     varargout{2} = yValues;
%     varargout{3} = zValues;
%     varargout{4} = V;
% end