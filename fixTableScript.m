% close all
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/XYviewPotentials/Bipolar 5.fig',1)

%% Fix the table
% Kill the table because it prints out poorly.
hfig = gcf;
delete(findall(hfig,'-property','ColumnWidth'));
set(hfig,'Position',[0 0 1 1])
% set(hfig,'Position',[0.5 0 0.5 1])

htitle = get(gca,'title');

titleStr = htitle.String;

figNameParts = strsplit(titleStr);
e = str2double(figNameParts{end});
stimMode = strrep(titleStr,[' ' figNameParts{end}],'')

I0default = 0.1065; % mA

strStim   = sprintf('E%d = %+.4f mA',e,I0default);

%% Put electrode information in the legend instead
hLines = findobj(gca,'Type','Line');
m = 1;
hEReturn = [];
lWidth = 7;
for k = 1:length(hLines)
    if hLines(k).Color(3) == 0 % == [1 0 0]
        % Screwed up colours for BP+N
        if strcmp(stimMode(1),'B')
            hLines(k).Color = [0 0 0.75];
            % Blue = return electrode
            hEReturn(m) = hLines(k);
            % In case there are multiple return electrodes
            m = m + 1;
        else
            % Red = stimulating electrode
            hEStim = hLines(k);
        end
        hLines(k).LineWidth = lWidth;
        
    elseif hLines(k).Color(1) == 0 % == [0 0 0.75]
        % Screwed up colours for BP+N
        if strcmp(stimMode(1),'B')
            hLines(k).Color = [1 0 0];
            hEStim = hLines(k);
        else
            % Blue = return electrode
            hEReturn(m) = hLines(k);
            % In case there are multiple return electrodes
            m = m + 1;
        end
        hLines(k).LineWidth = lWidth;
    end
    
end
hElec = [hEStim hEReturn];
%%
vMax = [30.6377   36.4755   19.7467  137.7381   18.4668   97.6679   57.5977];
vMin = [-28.5405  -34.6147  -18.7431   53.3488   -5.7178   36.0234   18.0247];
% vMin = [0 0 0   53.3488   0  36.0234   18.0247];
cUpper = mean([vMin;vMax]) + (vMax - mean([vMin;vMax]))/2;
cLower = mean([vMin;vMax]) - (vMax - mean([vMin;vMax]))/2;
% cAxes = [vMin',vMax']/2; % mV
cAxes = [cLower',cUpper'];
% Figure out electrodes and currents again because of lack of
% foresight in code structure.
switch stimMode
    case 'Monopolar'
        I0mA = I0default;
        
        activeElectrodes = e;
        inputCurrents    = I0default;
        
        resultVarName = 'MPresult';
        hElec = [hEStim ];
        cAxis = cAxes(4,:);
        legendStr = {strStim};
        
    case 'Bipolar'
        e1 = e;
        % Went for latter direction in simulations (could be either
        % side).
        e2 = e1 + 1; % e1 must be within [1,21]
        e2 = e1 - 1; % e1 must be within [2,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        resultVarName = 'BPresult';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e2,inputCurrents(end));
        legendStr = {strStim,strReturn1};
        hElec = [hEStim hEReturn];
        cAxis = cAxes(3,:);
    case 'BP+1'
        e1 = e;
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        resultVarName = 'BP1result';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e2,inputCurrents(end));
        legendStr = {strStim,strReturn1};
        hElec = [hEStim hEReturn];
        cAxis = cAxes(1,:);
    case 'BP+1x5'
        e1 = e;
        e2 = e1 + 2; % e1 must be within [1,20]
        e2 = e1 - 2; % e1 must be within [3,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = 5*[I0mA,-I0mA];
        
        resultVarName = 'BP1x5result';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e2,inputCurrents(end));
        legendStr = {strStim,strReturn1};
        hElec = [hEStim hEReturn];
    case 'BP+2'
        e1 = e;
        e2 = e1 + 3; % e1 must be within [1,19]
        e2 = e1 - 3; % e1 must be within [4,22]
        I0mA = I0default;
        
        activeElectrodes = [e1,e2];
        inputCurrents    = [I0mA,-I0mA];
        
        resultVarName = 'BP2result';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e2,inputCurrents(end));
        legendStr = {strStim,strReturn1};
        hElec = [hEStim hEReturn];
        cAxis = cAxes(2,:);
    case 'Tripolar'
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2,I0mA,-I0mA/2];
        
        resultVarName = 'TPresult';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e1,inputCurrents(end));
        strReturn2 = sprintf('E%d = %+.4f mA',e3,inputCurrents(end));
        legendStr = {strReturn1,strStim,strReturn2};
        hElec = [hEReturn(1) hEStim hEReturn(2)];
        cAxis = cAxes(5,:);
    case 'Partial Tripolar 0pt33'
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        sigma = 1/3;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
        
        resultVarName = 'pTPsig033result';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e1,inputCurrents(end));
        strReturn2 = sprintf('E%d = %+.4f mA',e3,inputCurrents(end));
        legendStr = {strReturn1,strStim,strReturn2};
        hElec = [hEReturn(1) hEStim hEReturn(2)];
        cAxis = cAxes(6,:);
    case 'Partial Tripolar 0pt67'
        e2 = e;
        e1 = e2 - 1;
        e3 = e2 + 1;
        
        I0mA = I0default;
        sigma = 2/3;
        activeElectrodes = [e1,e2,e3];
        inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
        
        resultVarName = 'pTPsig067result';
        
        strReturn1 = sprintf('E%d = %+.4f mA',e1,inputCurrents(end));
        strReturn2 = sprintf('E%d = %+.4f mA',e3,inputCurrents(end));
        legendStr = {strReturn1,strStim,strReturn2};
        hElec = [hEReturn(1) hEStim hEReturn(2)];
        cAxis = cAxes(7,:);
end
% strReturn1 = sprintf('E%d = %+.4f mA',e1,inputCurrents(end));
% strReturn2 = sprintf('E%d = %+.4f mA',e3,inputCurrents(end));
%
% if exist('e2','var')
%     strReturn = sprintf('E%d = %+.4f mA',e2,inputCurrents(end));
% end

% hEBox = hLines(1);

legend(hElec,legendStr)
%%

% ABANDONED BECAUSE MATLAB TO EPS IS SHITTY WITH TABLES
% % Tabulate active electrodes
% % GUI positioning
% xWidth = 0.3;
% yHeight = 0.3;
% xLeft = 0.5 - xWidth/2;
% yBot = 0.1;
% ax = gca;
% pos = ax.Position;
%
% dat = mat2cell([activeElectrodes',inputCurrents'],...
%     ones(length(activeElectrodes),1),[1 1]);
% columnname =   {'Elec #', 'I0 (mA)'};
% columnformat = {'char'     , 'numeric'};
% t = uitable('Units','normalized',...
%     'Position', pos,...
%     'FontSize',8,...
%     'Data', dat,...
%     'ColumnName', columnname,...
%     'ColumnFormat', columnformat,...
%     'RowName',[]);
%
% set(findall(hfig,'-property','FontSize'),...
%     'FontSize',20,'FontName','Arial')
% %%
% tableWidth = t.Extent(4);
% tableHeight = t.Extent(3);
% % % Lower left
% % t.Position(1) = pos(1)+0.01;
% % % t.Position(2) = 0.5 - 2*t.Extent(4);
% % t.Position(2) = pos(2)+0.01;
% % t.Position(3) = t.Extent(3);
% % t.Position(4) = t.Extent(4);
%
% % % Top left
% t.Position(1) = pos(1);
% % t.Position(2) = 0.5 - 2*t.Extent(4);
% t.Position(2) = pos(2)+pos(4) - tableWidth;
% t.Position(3) = tableHeight;
% t.Position(4) = tableWidth;

%% Put a translucent sphere around the active electrodes
% caxis([60 100])
%
% load electrodesOrdered eCentres electrodes
%
% radius = 2; % mm
% % sphereCoords = sphere*radius;
% %
% % x = sphereCoords(:,1);
% % y = sphereCoords(:,2);
% % z = sphereCoords(:,3);
%
% [x,y,z] = sphere;
%
% x = x*radius;
% y = y*radius;
% z = z*radius;
% %
% for e = 1:length(activeElectrodes)
%     centre = eCentres(activeElectrodes(e),:);
%     s(e) = surf(x+centre(1),y+centre(2),z+centre(3));
%     s(e).EdgeAlpha = 0;
%     alpha(s(e),0.3)
% end
% %%
%
% axis equal
% % caxis([-15 15])
% rotate3d