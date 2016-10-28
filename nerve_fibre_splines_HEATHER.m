%% Initialise workspace
clear all;
close all;
clf;
clc;

makeNerveFibres = 0;
videoExport = 0;

% Start timer
timer_start = tic;

% Notify start of script
fprintf('Extrapolating coordinates of auditory nerve fibres.\n\n');

%% Set up constants

% Number of fibres desired
fibre_count = 100;

% Number of nodes along each fibre (for the first pass)
% Use at least the number of key points
fibre_nodes_first_pass = 20;

% Accuracy of trim - Use 25 in final
trim_accuracy = 25;

% Spacing between nodes of Ranvier (in millimetres)
PP_spacing = 0.175;
axon_spacing = 0.300;

%% Input coordinates

fname = 'topCurve.txt';
load(fname)

% Rosenthal's canal
RC_points = [1.800 4.225 2.150;
1.750 4.000 2.150;
1.675 3.775 2.200;
1.600 3.575 2.350;
1.600 3.450 2.550;
1.700 3.350 2.775;
1.875 3.275 2.950;
2.075 3.250 3.075;
2.300 3.200 3.150;
2.550 3.150 3.150;
2.775 3.100 3.025;
2.900 3.050 2.800;
2.950 3.000 2.550;
2.800 2.925 2.350;
2.550 2.850 2.250;
2.325 2.700 2.350;
2.250 2.550 2.550;
2.325 2.400 2.775;
2.550 2.250 2.850;
2.775 2.125 2.775;
2.850 2.000 2.550];

%% Peripheral processes
PP_points = [1.549 4.371 1.555;
1.323 3.802 1.505;
1.073 3.446 1.825;
0.990 3.293 2.360;
1.115 3.237 2.910;
1.545 3.214 3.410;
2.215 3.131 3.600;
2.789 3.076 3.570;
3.173 3.011 3.165;
3.247 2.992 2.740;
3.154 2.951 2.350;
2.891 2.872 2.060;
2.544 2.775 1.975;
2.197 2.650 2.065;
1.980 2.516 2.345;
1.980 2.382 2.675;
2.146 2.271 2.945;
2.419 2.160 3.120;
2.706 2.086 3.115;
3.025 1.979 2.860;
3.066 1.919 2.580;
3.062 1.910 2.535];

mid_PP_points = [1.623 4.292 1.780;
1.360 3.677 1.800;
1.216 3.409 2.150;
1.235 3.288 2.700;
1.656 3.210 3.250;
2.165 3.126 3.430;
2.627 3.071 3.455;
3.029 3.015 3.180;
3.131 2.983 2.810;
3.094 2.946 2.445;
2.858 2.858 2.135;
2.525 2.752 2.075;
2.197 2.618 2.185;
2.077 2.502 2.420;
2.095 2.368 2.730;
2.354 2.238 2.965;
2.678 2.104 3.025;
2.951 1.998 2.820;
2.974 1.929 2.540];

%% Nerve trunk

% Axon (RC exit)
A1_points = [1.924 4.223 2.340;
1.753 3.760 2.355;
1.855 3.441 2.755;
2.178 3.316 3.015;
2.590 3.242 3.060;
2.835 3.187 2.815;
2.849 3.085 2.495;
2.683 2.914 2.340;
2.405 2.761 2.350;
2.290 2.678 2.560;
2.390 2.502 2.790;
2.613 2.300 2.795;
2.790 2.210 2.670;
2.812 2.140 2.565];

% Axon (first guide)
A2_points = [2.160 4.218 2.370;
2.063 4.010 2.540;
2.054 3.732 2.705;
2.155 3.524 2.895;
2.521 3.372 2.990;
2.817 3.390 2.875;
2.817 3.430 2.620;
2.710 3.460 2.400;
2.450 3.460 2.435;
2.400 3.350 2.635;
2.485 3.230 2.800;
2.729 3.110 2.750;
2.715 2.980 2.555];

% Axon (at bend)
A3_points = [2.511 4.297 2.465;
2.410 4.371 2.635;
2.659 4.116 2.990;
2.979 3.839 2.800;
2.872 3.940 2.475;
2.650 4.158 2.515;
2.562 4.213 2.710;
2.683 4.102 2.915;
2.918 3.890 2.695];

% Axon (past bend)
A4_points = [3.039 4.676 2.510;
2.974 4.759 2.695;
3.177 4.403 3.150;
3.409 4.070 2.725;
3.187 4.431 2.450;
3.025 4.680 2.740;
3.182 4.403 3.050;
3.358 4.144 2.725];

% Axon (far end)
A6_points = [3.617 4.967 2.390; % 2.365
3.580 5.032 2.535;
3.547 5.097 2.710;
3.538 5.120 2.930;
3.598 5.004 3.080;
3.691 4.824 3.165;
3.788 4.639 3.200;
3.867 4.482 3.120;
3.945 4.329 2.940;
3.996 4.236 2.700;
3.964 4.301 2.505;
3.885 4.445 2.430;
3.797 4.625 2.335;
3.709 4.791 2.355;
3.631 4.944 2.530;
3.598 5.004 2.790;
3.635 4.926 2.975;
3.728 4.754 3.075;
3.811 4.593 3.055;
3.885 4.445 2.925;
3.941 4.343 2.755];
% 3.917 4.389 2.585];

% Axon (near end, offset)
shift_vector = [3.492 4.912 2.370] - [3.617 4.967 2.365];
A5_points = zeros(size(A6_points));

for i=1:size(A6_points,1)
    A5_points(i,:) = A6_points(i,:) + shift_vector;
end

%% Format plot

figure(1)
% set(1, 'Position', [-1000 200 900 1000], 'PaperPositionMode', 'auto');
set(1, 'Position', [-1000 200 1000 1000], 'PaperPositionMode', 'auto');

% Axes, title, etc.
axis equal;
grid on;
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 12)

% title 'Interpolated nerve fibres';
xlabel ('X coordinate (mm)', 'FontWeight','bold');
ylabel ('Y coordinate (mm)', 'FontWeight','bold');
zlabel ('Z coordinate (mm)', 'FontWeight','bold');

hold on;

% Colours
color_grey = [0.7,0.7,0.7];
color_proc = [253,227,154]/255; % [239,217,151] in ScanIP
color_gang = [250,69,64]/255;
color_axon = [251,200,54]/255;

% Viewpoint
view([0 -90]);

rotate3d on;

%% MAKE SPIRAL SPLINES

%% Rosenthal's canal

% Calculate interpolated points
px = RC_points(:,1); % These are temporary variables for plotting points
py = RC_points(:,2);
pz = RC_points(:,3);
interp_points_RC = interparc(fibre_count, px, py, pz);

% Plot RC
% plot3(px, py, pz);      % Original points (from manual selection)
plot3(interp_points_RC(:,1), interp_points_RC(:,2), interp_points_RC(:,3), ...
    '-ro', 'LineWidth', 1, 'MarkerEdgeColor', color_gang, 'MarkerSize', 10);

csvwrite('cutpoints_RC.csv', interp_points_RC);

%% Peripheral processes

% Calculate interpolated points
px = PP_points(:,1);
py = PP_points(:,2);
pz = PP_points(:,3);
interp_points_PP = interparc(fibre_count, px, py, pz);

% Plot PP
plot3(interp_points_PP(:,1), interp_points_PP(:,2), interp_points_PP(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);

% Calculate interpolated points
px = mid_PP_points(:,1);
py = mid_PP_points(:,2);
pz = mid_PP_points(:,3);
interp_points_PP_mid = interparc(fibre_count, px, py, pz);

% Plot PP-mid
plot3(interp_points_PP_mid(:,1), interp_points_PP_mid(:,2), interp_points_PP_mid(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_PP_mid(:,1), interp_points_PP_mid(:,2), interp_points_PP_mid(:,3));

%% Axon start

% Calculate interpolated points
px = A1_points(:,1);
py = A1_points(:,2);
pz = A1_points(:,3);
% scatter3(px,py,pz);
interp_points_A1 = interparc(fibre_count, px, py, pz);

% Plot A1
plot3(interp_points_A1(:,1), interp_points_A1(:,2), interp_points_A1(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_A1(:,1), interp_points_A1(:,2), interp_points_A1(:,3));

%% Test

% Calculate interpolated points
px = A2_points(:,1);
py = A2_points(:,2);
pz = A2_points(:,3);
% scatter3(px,py,pz);
interp_points_A2 = interparc(fibre_count, px, py, pz);

% Plot A2
plot3(interp_points_A2(:,1), interp_points_A2(:,2), interp_points_A2(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);

%% Axon, near bend

% Calculate interpolated points
px = A3_points(:,1);
py = A3_points(:,2);
pz = A3_points(:,3);
% scatter3(px,py,pz);
interp_points_A3 = interparc(fibre_count, px, py, pz);

% Plot A3
plot3(_points_A3(:,1), interp_points_A3(:,2), interp_points_A3(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_A2(:,1), interp_points_A2(:,2), interp_points_A2(:,3));

% Calculate interpolated points
px = A4_points(:,1);
py = A4_points(:,2);
pz = A4_points(:,3);
% scatter3(px,py,pz);
interp_points_A4 = interparc(fibre_count, px, py, pz);

% Plot A4
plot3(interp_points_A4(:,1), interp_points_A4(:,2), interp_points_A4(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_A2(:,1), interp_points_A2(:,2), interp_points_A2(:,3));

%% Axon end offset

% Calculate interpolated points
px = A5_points(:,1);
py = A5_points(:,2);
pz = A5_points(:,3);
interp_points_A5 = interparc(fibre_count, px, py, pz);

% Plot A5
plot3(interp_points_A5(:,1), interp_points_A5(:,2), interp_points_A5(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_A5(:,1), interp_points_A5(:,2), interp_points_A5(:,3));

%% Axon end

% Calculate interpolated points
px = A6_points(:,1);
py = A6_points(:,2);
pz = A6_points(:,3);
interp_points_A6 = interparc(fibre_count, px, py, pz);

% Plot A6
plot3(interp_points_A6(:,1), interp_points_A6(:,2), interp_points_A6(:,3), ...
    '-', 'Color', color_grey, 'LineWidth', 1);
% scatter3(interp_points_A6(:,1), interp_points_A6(:,2), interp_points_A6(:,3));

%% MAKE NERVE FIBRES
if makeNerveFibres
    % Initialise array for trim_after points
    trim_after_node = zeros(fibre_count, 1);
    
    % Initialise arrays for export node count
    cutpoint_index = 1;
    nodes_per_fibre_PP_RC = zeros(fibre_count, 1);
    nodes_per_fibre_RC_AN = zeros(fibre_count, 1);
    
    % For each fibre
    for i = 1:fibre_count
        
        % Get key points
        fibre_key_points_spiral = vertcat(interp_points_PP(i,:), interp_points_PP_mid(i,:), ...
            interp_points_RC(i,:), interp_points_A1(i,:), interp_points_A2(i,:), ...
            interp_points_A3(i,:), interp_points_A4(i,:), interp_points_A5(i,:), ...
            interp_points_A6(i,:));
        
        % Interpolate additional nodes for rough fibre (overall path)
        fibre_approx = interparc(fibre_nodes_first_pass, fibre_key_points_spiral(:,1), ...
            fibre_key_points_spiral(:,2), fibre_key_points_spiral(:,3));
        
        % Find "trim point" at RC
        for j = 1:size(fibre_approx,1)-1    % Where 1 is the peripheral end
            %         scatter3(periph_fibre(j,1), periph_fibre(j,2), periph_fibre(j,3));
            
            dist_1 = sqrt((fibre_approx(j,1)-interp_points_RC(i,1))^2 ...
                + (fibre_approx(j,2)-interp_points_RC(i,2))^2 ...
                + (fibre_approx(j,3)-interp_points_RC(i,3))^2);
            dist_2 = sqrt((fibre_approx(j+1,1)-interp_points_RC(i,1))^2 ...
                + (fibre_approx(j+1,2)-interp_points_RC(i,2))^2 ...
                + (fibre_approx(j+1,3)-interp_points_RC(i,3))^2);
            dist_R = sqrt((fibre_approx(j+1,1)-fibre_approx(j,1))^2 ...
                + (fibre_approx(j+1,2)-fibre_approx(j,2))^2 ...
                + (fibre_approx(j+1,3)-fibre_approx(j,3))^2);
            
            if and(dist_1 < dist_R, dist_2 < dist_R)
                %             fprintf(['Split fibre ' num2str(i) ' after node ' num2str(j) '\n']);
                trim_after_node(i) = j;
            end
        end
        
        % Split into two splines (PP-RC, RC-AN) at Rosenthal's canal
        fibre_PP_RC_points = zeros(trim_after_node(i)+1, 3);
        fibre_PP_RC_points(1,:) = interp_points_RC(i,:); % First point is RC
        
        for k = 2:size(fibre_PP_RC_points,1);
            fibre_PP_RC_points(k,:) = fibre_approx(trim_after_node(i)+2-k,:);
        end
        
        fibre_PP_RC = interparc(fibre_nodes_first_pass, fibre_PP_RC_points(:,1), ...
            fibre_PP_RC_points(:,2), fibre_PP_RC_points(:,3));
        %     plot3(fibre_PP_RC(:,1), fibre_PP_RC(:,2), fibre_PP_RC(:,3));
        %     scatter3(fibre_PP_RC(:,1), fibre_PP_RC(:,2), fibre_PP_RC(:,3));
        
        fibre_RC_AN_points = zeros(fibre_nodes_first_pass - trim_after_node(i) + 1, 3);
        fibre_RC_AN_points(1,:) = interp_points_RC(i,:); % First point is RC
        
        for k = 2:size(fibre_RC_AN_points,1);
            fibre_RC_AN_points(k,:) = fibre_approx(trim_after_node(i)-1+k,:);
        end
        
        fibre_RC_AN = interparc(fibre_nodes_first_pass, fibre_RC_AN_points(:,1), fibre_RC_AN_points(:,2), fibre_RC_AN_points(:,3));
        %     plot3(fibre_RC_AN(:,1), fibre_RC_AN(:,2), fibre_RC_AN(:,3));
        %     scatter3(fibre_RC_AN(:,1), fibre_RC_AN(:,2), fibre_RC_AN(:,3));
        
        
        % Adjust length to closest multiple of Ranvier spacing
        % Get length of existing arc
        fibre_length_orig = arclength(fibre_PP_RC(:,1), fibre_PP_RC(:,2), fibre_PP_RC(:,3));
        fprintf(['Arc length at fibre ' num2str(i) ': %0.3f mm '], fibre_length_orig);
        
        whole_divs = floor(fibre_length_orig / PP_spacing);
        part_divs = mod(fibre_length_orig, PP_spacing) / PP_spacing;
        
        % Make a temporary high resolution fibre
        fibre_temp = interparc(trim_accuracy * fibre_nodes_first_pass, fibre_PP_RC_points(:,1), fibre_PP_RC_points(:,2), fibre_PP_RC_points(:,3));
        %         scatter3(fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        
        fibre_length = arclength(fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        target_fibre_length = PP_spacing * whole_divs;
        
        % Trim by progressively removing data points
        while (fibre_length > target_fibre_length)
            fibre_temp = fibre_temp(1:(size(fibre_temp,1)-1),:);
            fibre_length = arclength(fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        end
        
        shorter_by = fibre_length_orig - fibre_length;
        fprintf('(shortened by: %0.3f mm)\n', shorter_by);
        
        % Interpolate new spline with spacing based on nodes of Ranvier separation
        fibre_PP_RC = interparc(whole_divs+1, fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        plot3(fibre_PP_RC(:,1), fibre_PP_RC(:,2), fibre_PP_RC(:,3), ...
            '-k.', 'Color', color_proc, 'LineWidth', 1, 'MarkerSize', 12);
        
        % Adjust length to closest multiple of Ranvier spacing
        % Get length of existing arc
        fibre_length_orig = arclength(fibre_RC_AN(:,1), fibre_RC_AN(:,2), fibre_RC_AN(:,3));
        fprintf(['Arc length at fibre ' num2str(i) ': %0.3f mm '], fibre_length_orig);
        
        whole_divs = floor(fibre_length_orig / axon_spacing);
        part_divs = mod(fibre_length_orig, axon_spacing) / axon_spacing;
        
        % Make a temporary high resolution fibre
        fibre_temp = interparc(trim_accuracy * fibre_nodes_first_pass, fibre_RC_AN_points(:,1), fibre_RC_AN_points(:,2), fibre_RC_AN_points(:,3));
        
        fibre_length = arclength(fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        target_fibre_length = axon_spacing * whole_divs;
        
        % Trim by progressively removing data points
        while (fibre_length > target_fibre_length)
            fibre_temp = fibre_temp(1:(size(fibre_temp,1)-1),:);
            fibre_length = arclength(fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        end
        
        shorter_by = fibre_length_orig - fibre_length;
        fprintf('(shortened by: %0.3f mm)\n', shorter_by);
        
        % Interpolate new spline with spacing based on nodes of Ranvier separation
        fibre_RC_AN = interparc(whole_divs+1, fibre_temp(:,1), fibre_temp(:,2), fibre_temp(:,3));
        plot3(fibre_RC_AN(:,1), fibre_RC_AN(:,2), fibre_RC_AN(:,3), ...
            '-k.', 'Color', color_axon, 'LineWidth', 1, 'MarkerSize', 12);
        
        % Add node coordinates to CSV matrix
        nodes_per_fibre_PP_RC(i) = size(fibre_PP_RC,1);
        nodes_per_fibre_RC_AN(i) = size(fibre_RC_AN,1);
        
        if i==1
            cutpoints_PP_RC = fibre_PP_RC;
            cutpoints_RC_AN = fibre_RC_AN;
        else
            cutpoints_PP_RC = vertcat(cutpoints_PP_RC, fibre_PP_RC);
            cutpoints_RC_AN = vertcat(cutpoints_RC_AN, fibre_RC_AN);
        end
    end
    
    % Export CSVs
    csvwrite('node_counts_PP_RC.csv', nodes_per_fibre_PP_RC);
    csvwrite('cutpoints_PP_RC.csv', cutpoints_PP_RC);
    
    csvwrite('node_counts_RC_AN.csv', nodes_per_fibre_RC_AN);
    csvwrite('cutpoints_RC_AN.csv', cutpoints_RC_AN);

end

%% End timer
timer_end = toc(timer_start);

hours = floor(timer_end/3600);
mins = floor((timer_end-hours*3600)/60);
secs = rem(timer_end,60);

%% Mark end of script
fprintf('\n');
fprintf(['SCRIPT COMPLETED']);
fprintf('\n');
if (hours == 0)
	fprintf('Time taken: %d minutes and %0.2f seconds.\n\n', mins, secs);
else
    fprintf('Time taken: %d hours, %d minutes and %0.2f seconds.\n\n', hours, mins, secs);
end

%% Video frames export
if videoExport
    xlim([0.5 5])
    set(gca,'visible','off');
    
    oh=findobj(gca,'type','line');      % Get all plotted line objects
    % frames_dir = 'B:\Temp\Modelling\3. GP_complete\5. MATLAB\vid';
    frames_dir = 'frames/';
    
    
    for i = 0:359
        image_name = fullfile(frames_dir, strcat('fibres_',num2str(i),'.png'));
        print(1, '-dpng', image_name);
    
        rotate(oh,[0 1 0],1)             % Rotate objects about y axis by 10 degrees
    end
end

%% Run batch
% cd 'B:\Temp\Modelling\3. GP_complete\4. COMSOL\2.1. Validation update';
% VD_batch;
