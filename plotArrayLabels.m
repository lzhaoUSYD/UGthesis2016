% Based on Matlab figure created from Comsol coordinates. Electrodes
% unordered and rogue coordinates exist.
% 
% %% Get scatter data & pre-process.
% s = findobj(gca,'type','scatter');
% 
% xArray = s.XData;
% yArray = s.YData;
% zArray = s.ZData;
% 
% coords = [s.XData',s.YData',s.ZData'];
% 
% % Kill rogues at 1:8.
% coords(1:8,:) = [];
% % 2 more rogue dots.
% arrayRogues = [55.88,97.06,131.2;
%     55.92,97.04,131.2];
% % coords = rmCoords(coords,arrayRogues);
% xArray = coords(:,1);
% yArray = coords(:,2);
% zArray = coords(:,3);
% %%
% xCoordOrdered = [53.4700000000000;
%     54.2600000000000;
%     55.0500000000000;
%     55.8000000000000;
%     56.5100000000000;
%     
%     57.0700000000000;
%     57.32;
%     57.563700000000000;
%     57.564700000000000;
%     57.2600000000000;
%     
%     56.7700000000000;
%     56.03;%55.84;
%     55.2100000000000;
%     54.3800000000000;
%     53.6500000000000;
%     
%     53.2500000000000;
%     53.6300000000000;
%     54.2300000000000;
%     54.9600000000000;
%     55.47;
%     
%     55.43;
%     54.79];
% for c = 1:22
%     %     coordIndex = abs(xArray-xCoordOrdered(c))<1e-2
%     diffVector = abs(xArray-xCoordOrdered(c));
%     coordIndex = find(diffVector==min(diffVector));
%     
%     yCoordOrdered(c) = yArray(coordIndex);
%     zCoordOrdered(c) = zArray(coordIndex);
% end
% %% Plotting prep
% % % Get the electrode order (currently ordered by increasing x-value).
% % [~,~,ranks] = unique([40,44,50,55,58,60,62,64,63,61,59,56,52,46,43,41,42,45,49,53,54,51]);
% 


% 
% % Adjust colour
% colormap cool
% s.CData = s.CData*0;
% 
% save arrayCoords xCoordOrdered yCoordOrdered zCoordOrdered labels coords
%%


% 
% clear
% load arrayCoords

%% Plotting
% Start with a fig of the splines by themselves.
% uiopen('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/finalFormattingRun/Splining/splineSpiral.fig',1)
% Get electrode coordinates
coords = load('electrodesOrdered.mat');
electrodeLoops = coords.electrodes';

% Get the centre of each electrode, to 1) assign the text label and 2) use
% as reference for judging distance from electrode to nodes of Ranvier.
for e = 1:22
        
end    

% scatter3(coords(:,1),coords(:,2),coords(:,3),'g','filled')

% Generate label strings for 1:22.
labels = cellfun(@(x) num2str(x),...
    num2cell(1:22),'uniformoutput',0);

% Assign text labels to number each electrode.
for e = 1:22
    % 5x3 array of 4 corners + 1st corner again (to form a loop).
    loop =  electrodeLoops{e};
    corners = loop(1:end-1,:);
    xElec = corners(:,1);
    yElec = corners(:,2);
    zElec = corners(:,3);
    
    % Centre taken as mean of coordinates on each axis.
    eCentres(e,:) = [mean(xElec),mean(yElec),mean(zElec)];
    
    % TeX: red, green, yellow, magenta, blue, black, white, gray, darkGreen, orange, or lightBlue
%     text(xCoordOrdered(l),yCoordOrdered(l),zCoordOrdered(l),['\bf \color{darkGreen} E' labels{l} ''],'interpreter','tex')
    text(eCentres(e,1),eCentres(e,2),eCentres(e,3),['\bf \color{darkGreen} E' labels{e} ''],'interpreter','tex')
    
    plot3(loop(:,1),loop(:,2),loop(:,3),'Color',[0.5 0.5 0.5])
end
scatter3(eCentres(:,1),eCentres(:,2),eCentres(:,3),'.')



%%
% Number the fibres.
s = load('spiralSplineNewgreenwoodF100.mat');
scMediaSpline = s.scMediaSpline;
% Basal to apical
for t = [1:10:100]
    t
    text(scMediaSpline(t,1),scMediaSpline(t,2),scMediaSpline(t,3),['F' num2str(100-t+1)],'interpreter','tex');
end

%
az1 = -168.5;
el1 = 6;
% view(az1,el1)

az2 = 161.5;
el2 = 2;
% view(az2,el2)

axis auto
axis equal

azA = 218.5000;
elA = -28;

azB = -59.3145;
elB = -40.3428;

azC = 132.8076;
elC = 3.0742;

% view(azC,elC)

% rotate3d