%% USE FOR LOADING AND REDRAWING

clear
close all
load('theAllImportantMatrix.mat');

figWidth = 1/2;%/2;
hfig = figure('units','normalized');
set(hfig, 'MenuBar', 'none');
set(hfig, 'ToolBar', 'none');
set(hfig,'position',[1-figWidth,0,figWidth,1]);


fnames = {
    'AFMonopolar';
    'AFBipolar';
    'AFBipolar1';
    'AFBipolar2';
    'AFTripolar';
    'AFpTripolarSig033';
    'AFpTripolarSig2';
    };

% Plot by stimulation mode.
for l = 1:size(numActiveFibres,1)
    plot(numActiveFibres(l,:))
%     semilogy(1:22,1./numActiveFibres(l,:))

%     legend(fnames{1:l},'location','northwest')
    legend(fnames{1:l},'location','northeast')

    pause(0.5)
    hold on;

end

xlim([1 22])
xlabel('Electrode')
% ylabel('Percentage of modelled fibres excited')
ylabel('log(1/Percentage of modelled fibres excited)')
st = suptitle({'Specificity of neural activation','from electrode stimulation','in a FEM human cochlea'});
set(findall(gcf,'-property','FontSize'),'FontSize',18)

set(st,'FontSize',20)
