function plotV(result)
c = result{1};
activeElectrodes = result{2};
inputCurrents = result{3};

maxCurrent = max(inputCurrents);

%% Setting up
figure('units','normalized','position',[0.5,0,0.5,1]);

x = c(:,1);
y = c(:,2);
z = c(:,3);
V = c(:,4);

scatterSize = 5;
scatter3(x,y,z,scatterSize,V);

% Viewpoint
viewTop = [-146.5,-10];
viewSide = [-155.5,-80];
view(viewSide)

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
xLeft = 0.05;
yBot = 0.1;
xWidth = 0.2;
yHeight = 0.3;
dat = mat2cell([activeElectrodes',inputCurrents'],...
    ones(length(activeElectrodes),1),[1 1]);
columnname =   {'Elec #', 'I0 (mA)'};
columnformat = {'char'     , 'numeric'};
t = uitable('Units','normalized','Position',...
    [xLeft,yBot,xWidth,yHeight], 'Data', dat,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'RowName',[],...
    'ColumnWidth',{50});
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);

% Viewing options
b1 = uicontrol('Style','pushbutton','String','Top view',...
    'Callback',@topView_Callback,'Units','normalized',...
    'Position',[xLeft,1-yBot,xWidth,0.05]);
b2 = uicontrol('Style','pushbutton','String','Side view',...
    'Callback',@sideView_Callback,'Units','normalized',...
    'Position',[xLeft,1-yBot*1.5,xWidth,0.05]);

    function topView_Callback(source,eventdata)
        view([-146.5,-10])
    end

    function sideView_Callback(source,eventdata)
        view([-155.5,-80])
    end

%% Visualise and tabulate active electrodes
% domBaseToApex = [40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51];
for e = 1:22
    eCoords = electrodeLoops{e};
%     % Ordering it as a loop.
%     eCoords = [eCoords(1,:);
%         eCoords(2,:);
%         eCoords(4,:);
%         eCoords(3,:);
%         eCoords(1,:)];
    %         plotxyz(eCoords)
    %         scatter3(eCoords(:,1),eCoords(:,2),eCoords(:,3),scatterSize,'rx')
%     electrodes{e} = eCoords;
    if any(activeElectrodes == e)
        % Hacky way of accessing successive active electrodes owing to
        % input structure for simulating electrode configurations.
        redness = (inputCurrents(1)/maxCurrent)/2 + 0.5;
        inputCurrents(1) = [];
        
        % Active electrodes displayed as red boxes.
        plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'Color',[redness 0 0])

%         plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'r-')
    else
        % Inactive electrodes displayed as black crosses.
        plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'bx')
    end
end

%% Visualise Greenwood frequency function
s = load('3500Fibres10Nodes.mat');
fMap = s.fMap;
scMediaSpline = s.scMediaSpline;
freqIndices = s.freqIndices;

for freqIndex = freqIndices
    coords = scMediaSpline(freqIndex,:);
    x = coords(1);y = coords(2); z = coords(3);
    freq = round(fMap(freqIndex));
    text(x,y,z,[' ' num2str(freq) ' Hz'],'fontsize',12)
end
plot3(scMediaSpline(:,1),scMediaSpline(:,2),scMediaSpline(:,3))
% 
% scatters = findobj('marker','o');
% lines =  findobj('type','line','linestyle','-');

end
