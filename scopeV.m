clear
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/BP.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/BP1.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/BP2.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/MP.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/pTPsig033.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/pTPsig067.mat')
load('/Users/lukezhao/Dropbox/UNI/Thesis/Modelling/NerveTrajectories/Outputs/Potentials/TP.mat')

S=whos;

allV = nan(1e6,7);
for d = 1:length(S)
    datset = eval(S(d).name);
    xyzV = cell2mat(datset(:,1));
    V = xyzV(:,4);
    V = V(~isnan(V));
    allV(1:length(V),d) = V*1000; % mV
end

 max(allV)
min(allV)