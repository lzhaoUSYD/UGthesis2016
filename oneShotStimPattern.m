% Run COMSOL, plot and return c which contains (x,y,z,V).
% Inputs: active (non-zero-current) electrodes and index-matched currents.
% And the model.

function c = oneShotStimPattern(model,activeElectrodes,inputCurrents)

doSave = 1;
doPlot = 1;
doEvaluate = 1;

if doPlot
    % Can't plot without evaluating.
    doEvaluate = 1;
end

% Enable this inside the model so it doesn't have to be set here every time.
model.sol('sol1').feature('s1').feature('i1').active(1);
% solver = model.sol('sol1').feature('s1').feature('i1');

% Set relative tolerance. Don't know where to set it.
% model.sol('sol1').feature('st1').set('rtol',1e-6);

%% Assumptions

% Electrodes
% - Perfectly shaped
% - Homogeneous
%
% Current
% - Same current throughout electrode

%% mph commands

% mphtable % But don't know table tags

% GUI of expressions in the model (includes materials, physics objects,
% variables)
% mphsearch

%% Electrode settings
%>> Getting values
% % Dimension, geom, entities etc.
% mphgetselection(model.physics('ec').feature('term1'))
% % All fields and values, as a struct.
% mphgetproperties(model.physics('ec').feature('term1'))
% % All fields, as Java String[]
% ECfields = model.physics('ec').feature('term1').param;

%>> Multipolar stimulation
% % More active electrodes (terminals)
% activeElectrodes = [1 2 3 4 5];
% activeElectrodes = 1:22;

% Sanity check. TODO put a warning in place. Also important for setxor.
activeElectrodes = activeElectrodes(activeElectrodes(activeElectrodes > 0) & activeElectrodes(activeElectrodes < 23));

% % DEPRECATED Make sure to set the inactive electrodes to 0 mA.
% inactiveElectrodes = setxor(1:22,activeElectrodes);
% for inactiveElectrode = inactiveElectrodes
%     inputCurrents(inactiveElectrode) = 0;
% end

% % ONE-OFF IF NEEDED Create terminals from Matlab. 22 terminals now in COMSOL model.
% for e = 1:22
%     tag = ['term' num2str(e)];
%     try
%         model.physics('ec').feature().create(tag,'Terminal');
%     catch
%         fprintf('%s already exists.\n',tag);
%     end
%     model.physics('ec').feature(tag).selection.set(boundBasetoApexRange(e));
%     model.physics('ec').feature(tag).set('I0','0');
% end

% Set electrode currents using terminals created within COMSOL.
currents = zeros(1,22);
numActive = length(activeElectrodes);
for e = 1:numActive
    electrodeNum = activeElectrodes(e);
    currents(electrodeNum) = inputCurrents(e);
end

milliAmps = '[mA]';
for e = 1 : 22
    tag = ['term' num2str(e)];
    current = currents(e); % Dummy current equivalent to electrode number for testing.
    currentStr = [num2str(current) milliAmps];
    
    % Set
    fprintf(['Setting ' tag ' to %.4f mA.\n'],current);
    model.physics('ec').feature(tag).set('I0',currentStr);
    
    % model.physics('ec').feature('term1').set('V0',1);
    % model.physics('ec').feature('term1').set('I0',0.1065e-3);
    % model.physics('ec').feature('term1').set('Zref',50);
    %
    % model.physics('ec').feature('term1').set('Vinit',0);
    % model.physics('ec').feature('term1').set('Iinit',1);
    
    % Query (check)
    %     mphgetproperties(model.physics('ec').feature(tag))
end



%% Evaluate 3D cut points
if doEvaluate
    % Generated by runSplinesV3
    fname = 'spiralSplineNew.txt';
    
    % Generated by runSplines
%     fname = 'cutPoints3D.txt';
%     fname = '10Fibres10Nodes.txt';
%     fname = '3500Fibres10Nodes.txt';
    c = csvread(fname);
    numPoints = size(c,1);
    
    x = c(:,1);
    y = c(:,2);
    z = c(:,3);
    
    CPTag = 'cpt';
    
    % try-catch block as alternative to exist() for dealing with Java API.
    try
        model.result.dataset(CPTag);
        % If it exists, do nothing.
        % If it doesn't exist, we get a java error and go to catch.
    catch
        % Since it doesn't exist, create it.
        cpt = model.result.dataset.create(CPTag, 'CutPoint3D');
    end
    
    % Designate cut points at which to evaluate the model.
    model.result.dataset(CPTag).set('pointx',x);
    model.result.dataset(CPTag).set('pointy',y);
    model.result.dataset(CPTag).set('pointz',z);
    
    % Evaluate the model.
    % model.sol('sol1').feature('st1')
    % model.sol('sol1').feature('v1').feature('mod1_V')
    
    fprintf('Computing solution...\n');
    tic
    %     model.sol('sol1').updateSolution()
    model.sol('sol1').run()
    toc
    
    fprintf('Evaluating %d 3D cut points in COMSOL...\n',numPoints);
    tic
    V = mphinterp(model,'V','dataset',CPTag)';
    %     pd = mpheval(model,{e1,...,en},...)
    toc
    c = [c,V];
end

%* Trouble reopening model
% if doSave
%     % Takes about 2 minutes.
%     saveDir = 'B:\Luke';    
%     filename = ['Version ' strrep(datestr(now),':','-')];
%     saveAdd = fullfile(saveDir,filename);
%     tic
%     mphsave(model, saveAdd)
%     toc
% end


% Plotting decoupled from simulation. Now in plotV.m
% %% Plot
% if doPlot
%     figure('units','normalized','position',[0.5,0,0.5,1]);
%     
%     x = c(:,1);
%     y = c(:,2);
%     z = c(:,3);
%     
%     scatterSize = 5;
%     scatter3(x,y,z,scatterSize,V);
%     
%     % Viewpoint
%     viewTop = [-146.5,-10];
%     viewSide = [-155.5,-80];
%     view(viewSide)
%     
%     titleStr = sprintf('COMSOL output');
%     title(titleStr)
%     xlabel ('X coordinate (mm)', 'FontWeight','bold');
%     ylabel ('Y coordinate (mm)', 'FontWeight','bold');
%     zlabel ('Z coordinate (mm)', 'FontWeight','bold');
%     
%     hBar = colorbar;
%     hBar.Label.String = 'Electric potential (mV)';
%     
%     rotate3d on;
%     
%     hold on;
%     
%     cArray = mphgetcoords(model, 'geom1', 'domain',15)';
%     plotxyz(cArray)
%     
%     % Visualise and tabulate active electrodes
%     domBaseToApex = [40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51];
%     for e = activeElectrodes
%         eCoords = mphgetcoords(model, 'geom1','domain',domBaseToApex(e))';
%         % Ordering it as a loop.
%         eCoords = [eCoords(1,:);
%             eCoords(2,:);
%             eCoords(4,:);
%             eCoords(3,:);
%             eCoords(1,:)];
%         %         plotxyz(eCoords)
%         %         scatter3(eCoords(:,1),eCoords(:,2),eCoords(:,3),scatterSize,'rx')
%         plot3(eCoords(:,1),eCoords(:,2),eCoords(:,3),'r-')
%     end
%     
%     % GUI positioning
%     xLeft = 0.05;
%     yBot = 0.1;
%     xWidth = 0.15;
%     % Tabulate active electrodes
%     dat = mat2cell([activeElectrodes',inputCurrents'],...
%         ones(length(activeElectrodes),1),[1 1]);
%     columnname =   {'Elec #', 'I0 (mA)'};
%     columnformat = {'char'     , 'numeric'};
%     t = uitable('Units','normalized','Position',...
%         [xLeft,yBot,xWidth,0.15], 'Data', dat,...
%         'ColumnName', columnname,...
%         'ColumnFormat', columnformat,...
%         'RowName',[],...
%         'ColumnWidth',{50});
%     t.Position(3) = t.Extent(3);
%     t.Position(4) = t.Extent(4);
%     
%     % Viewing options
%     b1 = uicontrol('Style','pushbutton','String','Top view',...
%         'Callback',@topView_Callback,'Units','normalized',...
%         'Position',[xLeft,1-yBot,xWidth,0.05]);
%     b2 = uicontrol('Style','pushbutton','String','Side view',...
%         'Callback',@sideView_Callback,'Units','normalized',...
%         'Position',[xLeft,1-yBot*2,xWidth,0.05]);
% end
% 
%     function topView_Callback(source,eventdata)
%         view([-146.5,-10])
%     end
% 
%     function sideView_Callback(source,eventdata)
%         view([-155.5,-80])
%     end



%     savefig(domName)

% Uses c, returns c0New with coordinates (hopefully) ordered as along
% the spiral, not just along an axis (COMSOL default: x-direction).
% cOrdered = orderCoords(c);
%     interpxyz = splining(cNew);
%     fname = [domName '.mat'];
%     save fname c cOrdered x y z V interpxyz

end