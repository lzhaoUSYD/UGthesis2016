% DEPRECATED. USE runStimPatternsV2.m.

doSave = 0;
doPlot = 1;
doEvaluate = 0;

if doPlot
    % Can't plot without evaluating.
    doEvaluate = 1;
end



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
active = 1:22;

% Sanity check. TODO put a warning in place. Also important for setxor.
active = active(active(active > 0) & active(active < 23));

% Make sure to set the inactive electrodes to 0 mA.
inactive = setxor(1:22,active);

%% Create terminals from Matlab. 22 terminals now in COMSOL model.
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
elecCurrents = [1:length(active)];
milliAmps = '[mA]';
for e = 1:3
    tag = ['term' num2str(e)];    
    current = elecCurrents(e); % Dummy current equivalent to electrode number for testing.
    currentStr = [num2str(current) milliAmps];

    % Set
    fprintf(['Setting ' tag ' to %.2f mA.\n'],current);
    model.physics('ec').feature(tag).set('I0',currentStr);
    
% model.physics('ec').feature('term1').set('V0',1);
% model.physics('ec').feature('term1').set('I0',0.1065e-3);
% model.physics('ec').feature('term1').set('Zref',50);
%
% model.physics('ec').feature('term1').set('Vinit',0);
% model.physics('ec').feature('term1').set('Iinit',1);
    
    % Query (check)
    mphgetproperties(model.physics('ec').feature(tag))    
end


%* Trouble reopening model
if doSave
    % Takes about 2 minutes.
    filename = ['Version ' datestr(now)];
    tic
    mphsave(model, filename)
    toc
end

%% Evaluate 3D cut points
if doEvaluate
    % Generated by runSplines
    load import2comsol.mat
    
    c = import2comsol;
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
    tic
    fprintf('Evaluating %d 3D cut points in COMSOL.\n',numPoints);
    V = mphinterp(model,'V','dataset',CPTag)';
    toc
    c = [c,V];
end

%% Plot
if doPlot
    figure('units','normalized','position',[0.5,0,0.5,1]);
    
    scatterSize = 5;
    scatter3(x,y,z,scatterSize,V);
    
    % Viewpoint
    viewTop = [-146.5,-10];
    viewSide = [-155.5,-80];
    view(viewSide)
    
    titleStr = sprintf('COMSOL output');
    title(titleStr)
    xlabel ('X coordinate (mm)', 'FontWeight','bold');
    ylabel ('Y coordinate (mm)', 'FontWeight','bold');
    zlabel ('Z coordinate (mm)', 'FontWeight','bold');
    
    hBar = colorbar;
    hBar.Label.String = 'Electric potential (V)';
    
    rotate3d on;
    
    hold on;
    
    cArray = mphgetcoords(model, 'geom1', 'domain',15)';
    plotxyz(cArray)
end

%     savefig(domName)

% Uses c, returns c0New with coordinates (hopefully) ordered as along
% the spiral, not just along an axis (COMSOL default: x-direction).
% cOrdered = orderCoords(c);
%     interpxyz = splining(cNew);
%     fname = [domName '.mat'];
%     save fname c cOrdered x y z V interpxyz