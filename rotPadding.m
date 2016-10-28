% Given rotation about one axis (x, y or z), pad the other two to make room
% for rotation without clipping off.
function rotPadding(direction)

% Select the other two
directions = 'xyz';
rotAxis = strfind(directions,direction);
directions(rotAxis) = [];

% Get the two axis ranges
for d = 1:2    
    dirLims(d,1:2) = get(gca,[directions(d) 'lim']);
    dirRange(d,1) = abs(dirLims(d,1)-dirLims(d,2));
end
dirLims;
dirRange;
% Get the wider of the two axes.
newRange = max(dirRange);
% newLims = dirLims(newRange == dirRange,:)

for d = 1:2
    padding = newRange * 0.05;
%     newMin = newLims(1)-padding;
    oldMid = mean(dirLims(d,:));
    newLim = newRange/2 + padding;
    newMin = oldMid - newLim;
    newMax = oldMid + newLim;
    set(gca,[directions(d) 'lim'],[newMin newMax]);
end


% %% Fix the table
% % Kill the table because it prints out poorly.
% hfig = gcf;
% delete(findall(hfig,'-property','ColumnWidth'));
% set(hfig,'Position',[0 0 1 1])
% 
% htitle = get(gca,'title');
% 
% titleStr = htitle.String;
% 
% figNameParts = strsplit(titleStr);
% e = str2double(figNameParts{2});
% stimMode = figNameParts{1};
% 
% I0default = 0.1065; % mA
% 
% % Figure out electrodes and currents again because of lack of
% % foresight in code structure.
% switch stimMode
%     case 'Monopolar'
%         I0mA = I0default;
%         
%         activeElectrodes = e;
%         inputCurrents    = I0default;
%         
%         resultVarName = 'MPresult';
%     case 'Bipolar'
%         e1 = e;
%         % Went for latter direction in simulations (could be either
%         % side).
%         e2 = e1 + 1; % e1 must be within [1,21]
%         e2 = e1 - 1; % e1 must be within [2,22]
%         I0mA = I0default;
%         
%         activeElectrodes = [e1,e2];
%         inputCurrents    = [I0mA,-I0mA];
%         
%         resultVarName = 'BPresult';
%     case 'BP+1'
%         e1 = e;
%         e2 = e1 + 2; % e1 must be within [1,20]
%         e2 = e1 - 2; % e1 must be within [3,22]
%         I0mA = I0default;
%         
%         activeElectrodes = [e1,e2];
%         inputCurrents    = [I0mA,-I0mA];
%         
%         resultVarName = 'BP1result';
%     case 'BP+1x5'
%         e1 = e;
%         e2 = e1 + 2; % e1 must be within [1,20]
%         e2 = e1 - 2; % e1 must be within [3,22]
%         I0mA = I0default;
%         
%         activeElectrodes = [e1,e2];
%         inputCurrents    = 5*[I0mA,-I0mA];
%         
%         resultVarName = 'BP1x5result';
%     case 'BP+2'
%         e1 = e;
%         e2 = e1 + 3; % e1 must be within [1,19]
%         e2 = e1 - 3; % e1 must be within [4,22]
%         I0mA = I0default;
%         
%         activeElectrodes = [e1,e2];
%         inputCurrents    = [I0mA,-I0mA];
%         
%         resultVarName = 'BP2result';
%     case 'Tripolar'
%         e2 = e;
%         e1 = e2 - 1;
%         e3 = e2 + 1;
%         
%         I0mA = I0default;
%         activeElectrodes = [e1,e2,e3];
%         inputCurrents    = [-I0mA/2,I0mA,-I0mA/2];
%         
%         resultVarName = 'TPresult';
%     case 'Partial_Tripolar_0pt33'
%         e2 = e;
%         e1 = e2 - 1;
%         e3 = e2 + 1;
%         
%         I0mA = I0default;
%         sigma = 1/3;
%         activeElectrodes = [e1,e2,e3];
%         inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
%         
%         resultVarName = 'pTPsig033result';
%     case 'Partial_Tripolar_0pt67'
%         e2 = e;
%         e1 = e2 - 1;
%         e3 = e2 + 1;
%         
%         I0mA = I0default;
%         sigma = 2/3;
%         activeElectrodes = [e1,e2,e3];
%         inputCurrents    = [-I0mA/2*sigma,I0mA,-I0mA/2*sigma];
%         
%         resultVarName = 'pTPsig067result';
% end
% 
% 
% % Tabulate active electrodes
% % GUI positioning
% 
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
%     'FontSize',20,'FontName','Cambria')
% 
% % % Lower left
% t.Position(1) = pos(1); 
% % t.Position(2) = 0.5 - 2*t.Extent(4);
% t.Position(2) = pos(2);
% t.Position(3) = t.Extent(3);
% t.Position(4) = t.Extent(4);

end

