function plotSplines(coords,interpxyz)
doSave = 0;
%% Format plot
% Axes, title, etc.
axis([48 70 90 100 129 138])
% axis([49 63 91.5 99.5 130.5 137])

grid on;
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 12)

% title 'Interpolated nerve fibres';
% xlabel ('X coordinate (mm)', 'FontWeight','bold');
% ylabel ('Y coordinate (mm)', 'FontWeight','bold');
% zlabel ('Z coordinate (mm)', 'FontWeight','bold');


xlabel ('X (mm)', 'FontWeight','bold');
ylabel ('Y (mm)', 'FontWeight','bold');
zlabel ('Z (mm)', 'FontWeight','bold');


hold on;

% Colours
color_grey = [0.7,0.7,0.7];
color_proc = [253,227,154]/255; % [239,217,151] in ScanIP
color_gang = [250,69,64]/255;
color_axon = [251,200,54]/255;
colour_orange = [1 .5 0];

% Viewpoint
viewTop = [-146.5,-10];
viewSide = [-155.5,-80];
view(viewSide)

rotate3d on;

% Plot RC
plot3(coords(:,1), coords(:,2), coords(:,3),'r.','markersize',30);      % Original points (from manual selection)
% hold on;
% plot3(interpxyz(:,1), interpxyz(:,2), interpxyz(:,3), ...
%     '-r.', 'LineWidth', 3, 'MarkerEdgeColor', color_gang, 'MarkerSize', 1);
plot3(interpxyz(:,1), interpxyz(:,2), interpxyz(:,3),'-co');

if doSave
    if ~exist('fname','var')
        % If input was only an array.
        fname = inputdlg('Save as ______.csv');
        fname = fname{:};
    end
    csvwrite([fname(1:end-4) '.csv'], interpxyz);
end
end