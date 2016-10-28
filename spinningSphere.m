[X Y Z] = sphere(64);
X = X(:); Y = Y(:); Z = Z(:);

%# set-up figure
hFig = figure('Backingstore','off', 'renderer','zbuffer');

%# use lower-level function LINE
line(0.50*[X,X], 0.50*[Y,Y], 0.50*[Z,Z], 'LineStyle','none', 'Marker','.', 'MarkerSize',1, 'Color','r')
line(0.75*[X,X], 0.75*[Y,Y], 0.75*[Z,Z], 'LineStyle','none', 'Marker','.', 'MarkerSize',1, 'Color','g')
line(1.00*[X,X], 1.00*[Y,Y], 1.00*[Z,Z], 'LineStyle','none', 'Marker','.', 'MarkerSize',1, 'Color','b')
view(3)

%# freeze the aspect ratio to override stretch-to-fill behaviour
axis vis3d

%# fix the axes limits manually
%#set(gca, 'xlim',[-1 1], 'ylim',[-1 1], 'zlim',[-1 1])
axis manual

%# maybe even remove the tick labels
%set(gca, 'xticklabel',[], 'yticklabel',[], 'zticklabel',[])

%# animate (until figure is closed)
% while ishandle(hFig); camorbit(0.9,-0.1); drawnow; end
for i = 1:100; camorbit(0.9,-0.1); drawnow; end