function f = plotV(result)
c = result{1};
activeElectrodes = result{2};
inputCurrents = result{3};

maxCurrent = max(abs(inputCurrents));

%% Setting up
f = figure('units','normalized','position',[0.5,0,0.5,1]);
% figure('units','normalized','position',[0,0,1,1]);

x = c(:,1);
y = c(:,2);
z = c(:,3);
V = c(:,4)*1000; % mV

scatterSize = 5;
scatter3(x,y,z,scatterSize,V);
% axis equal
% axis([48 72,90 100,123 147,-16e-3 15e-3])

% Viewpoint
viewTop = [-146.5,-10];
viewSide = [-155.5,-80];
view(viewSide)
view(2)

titleStr = sprintf('COMSOL output');
title(titleStr)
% xlabel ('X coordinate (mm)', 'FontWeight','bold');
% ylabel ('Y coordinate (mm)', 'FontWeight','bold');
% zlabel ('Z coordinate (mm)', 'FontWeight','bold');

xlabel ('X (mm)', 'FontWeight','bold');
ylabel ('Y (mm)', 'FontWeight','bold');
zlabel ('Z (mm)', 'FontWeight','bold');

hBar = colorbar;
hBar.Label.String = 'Electric potential (mV)';
% set(hBar,'ylim',[-20,30])

rotate3d on;

hold on;

% Get electrodeCoords and electrodeLoops
% electrodeLoops = load electrodes
coords = load('electrodesOrdered.mat');
electrodeLoops = coords.electrodes;
% plotxyz(cArray)
%% Tabulate active electrodes
% GUI positioning

xWidth = 0.3;
yHeight = 0.3;
xLeft = 0.5 - xWidth/2;
yBot = 0.1;
ax = gca;
pos = ax.Position;

dat = mat2cell([activeElectrodes',inputCurrents'],...
    ones(length(activeElectrodes),1),[1 1]);
columnname =   {'Elec #', 'I0 (mA)'};
columnformat = {'char'     , 'numeric'};
t = uitable('Units','normalized',...
    'Position', pos,...
    'FontSize',8,...
    'Data', dat,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'RowName',[],...
    'ColumnWidth',{50});
% % Works nicely for display but incompatible when saving using print or
% % saveas.
% t.Position(1) = pos(1)+pos(3)-t.Extent(3)*1.5; 
% t.Position(2) = pos(4)-t.Extent(4)*1.5;
% t.Position(3) = t.Extent(3);
% t.Position(4) = t.Extent(4);

% Bottom right
t.Position(1) = pos(1) + pos(3) - t.Extent(3); 
t.Position(2) = 0.5 - t.Extent(4);
% t.Position(3) = t.Position(1) + length(activeElectrodes)*0.01;
% t.Position(4) = t.Position(2) + length(activeElectrodes)*0.05;

t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);

% % Lower left
% t.Position(1) = pos(1); 
% t.Position(2) = 0.5 - 2*t.Extent(4);
% t.Position(3) = t.Extent(3);
% t.Position(4) = t.Extent(4);

% xRight = 0.5;
% % Viewing options
% b1 = uicontrol('Style','pushbutton','String','Top view',...
%     'Callback',@topView_Callback,'Units','normalized',...
%     'Position',[xRight,yBot,xWidth,0.05]);
% b2 = uicontrol('Style','pushbutton','String','Side view',...
%     'Callback',@sideView_Callback,'Units','normalized',...
%     'Position',[xRight,yBot*1.5,xWidth,0.05]);
% 
%     function topView_Callback(source,eventdata)
%         view([-146.5,-10])
%     end
% 
%     function sideView_Callback(source,eventdata)
%         view([-155.5,-80])
%     end

%% Visualise and tabulate active electrodes
% domBaseToApex = [40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51];
for e = 1:22
    eCoords = electrodeLoops{e};
    if any(activeElectrodes == e)
        % Hacky way of accessing successive active electrodes owing to
        % input structure for simulating electrode configurations.
        inputCurrent = inputCurrents(1);
        if inputCurrent >= 0
            % Red
            redness = (inputCurrent/maxCurrent)/2 + 0.5;
            blueness = 0;
        else
            % Blue
            redness = 0;
            blueness = (abs(inputCurrent)/maxCurrent)/2 + 0.5;
        end
        inputCurrents(1) = [];
        
        % Active electrodes displayed as red boxes.
        plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'Color',[redness 0 blueness])
    else
        % Inactive electrodes displayed as grey dots.
        plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'.','Color',[0.5 0.5 0.5],'MarkerSize',10)
    end
end

%% Visualise Greenwood frequency function
% Contains following code as one stand-alone script
plotGreenwood

% s = load('3500Fibres10Nodes.mat');
% fMap = s.fMap;
% scMediaSpline = s.scMediaSpline;
% freqIndices = s.freqIndices;
% % Currently 40 fibres 20 nodes. 30 frequency points is good for A_ labels.
% freqIndices = round(linspace(1,3500,30)); 
% 
% for freqIndex = freqIndices
%     coords = scMediaSpline(freqIndex,:);
%     x = coords(1);y = coords(2); z = coords(3);
%     freq = round(fMap(freqIndex));
%     % Cater for the A_s to add special labels.
%     As = 27.5*2.^[0:7];
%     comp = abs((freq-As)./As);
%     if any(comp<0.1)
%         % We've got an A
%         match = As(comp == min(comp));
%         octave = find(comp == min(comp)) - 1;
%         textStr = [' ' num2str(match) ' Hz (A' num2str(octave) ')']      
%     else        
%         textStr = [' ' num2str(freq) ' Hz'];
%     end
%     text(x,y,z,textStr,'fontsize',8)
% end
% plot3(scMediaSpline(:,1),scMediaSpline(:,2),scMediaSpline(:,3))
% % 
% % scatters = findobj('marker','o');
% % lines =  findobj('type','line','linestyle','-');

end
