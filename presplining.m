close all

doFlush = 0;

if doFlush
    % Remove the model object in java.
    clear java
    % Unfortunately kills everything else, so restart them.
    mphstart;
    import com.comsol.model.*;
    import com.comsol.model.util.*;
end

%% Port the model
% Avoid unnecessary loading/waiting.
if ~exist('model','var')
    model = mphload('../COMSOL models/Model_Head - Phil''s model');
end
viewTop = [-146.5,-10];
viewSide = [-155.5,-80];

% Assumes get_coords has been run.
% Process the domain for scala media and spiral ganglion in order to help with splining.
% Only geometry is of interest here (x,y,z).

%>> Get coordinates
cScMedia = mphgetcoords(model, 'geom1', 'domain',35)';
plotxyz(cScMedia)
% 1653 coordinates.

cSpGang = mphgetcoords(model, 'geom1', 'domain',37)';
plotxyz(cSpGang)
% Inner curve of scala media is shared here.
cSpGang0 = cSpGang;

cNTrunk = mphgetcoords(model, 'geom1', 'domain',47)';
% plotxyz(cNTrunk)
% Random stuff for x > 55.42, or index > 100.
% cNTrunk = cNTrunk(1:100,:);
plotxyz(cNTrunk)

cCNVII = mphgetcoords(model, 'geom1', 'domain',25)';
% plotxyz(cCNVII)

cCNVIII = mphgetcoords(model, 'geom1', 'domain',31)';
plotxyz(cCNVIII)





legendStr = {'Scala media';
    'Spiral ganglion';
    'Nerve trunk';
%     'CN VII';
    'CN VIII'};    
legend(legendStr,'Location','SouthEast')
axis auto

%>> Remove coordinates that appear in cScMedia.
% Turn them into cells?
% Split into 3 columns?
% Sums? Reasonably unlikely to get coincidental hits.
% tScMedia = array2table(cScMedia,'VariableNames',{'x' 'y' 'z'});
% tSpGang = array2table(cSpGang,'VariableNames',{'x' 'y' 'z'});
% 
% tSpGangUniq = setdiff(tSpGang,tScMedia);
% cSpGang = table2array(tSpGangUniq);
% c0 = cSpGang;
% plotxyz(cSpGang)


%% Clever automated splining business (abandoned)
% % Backup copy.
% c0 = cScMedia;
% %>> Clean up coordinate arrays
% % Get electrode coordinates.
% cElectrodes = mphgetcoords(model, 'geom1', 'domain', dom.Array)';
% % 98 coordinates. Expected 88 (= 4 x 22).
% % Kill 1:8.
% cElectrodes(1:8,:) = [];
% % 2 more rogue dots.
% arrayRogues = [55.88,97.06,131.2;
%     55.92,97.04,131.2];
% cElectrodes = rmCoords(cElectrodes,arrayRogues);
% 
% % Remove the electrode coordinates from the scala media coordinates.
% cScMedia = rmCoords(cScMedia,cElectrodes);
% % More rogues.
% mediaRogues = [51.73,94.69,136.9];
%     
%>> Reorder the array to progress along the spiral
% cScMedia = orderCoords(cScMedia);
% cSpGang = orderCoords(cSpGang);
% cNTrunk = orderCoords(cNTrunk);
% 
% [cOrdered,interpxyz] = trysplining(cNTrunk);
% 
% plotSplines(cOrdered,interpxyz)
