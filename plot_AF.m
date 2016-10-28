%% DEPRECATED. plotAF.m

comsolOutDir = '../COMSOL models/';

fname = 'scTympOut.txt';
data = load([comsolOutDir fname]);
% data = c0New;

x = data(:,1); y = data(:,2); z = data(:,3);
V = data(:,4);

figure('units','normalized','position',[0.5,0,0.5,1]);
scatter3(x,y,z,3,V);

% title(fname)

xlabel('x')
ylabel('y')
zlabel('z')

c = colorbar;
c.Label.String = 'Electric potential (V)';