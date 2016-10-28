%% DEPRECATED. plotGreenwood.m

load('3500Fibres10Nodes.mat')

for freqIndex = freqIndices
    coords = scMediaSpline(freqIndex,:);
    x = coords(1);y = coords(2); z = coords(3);
    freq = round(fMap(freqIndex));
    text(x,y,z,[' ' num2str(freq) ' Hz'],'fontsize',12)
end
plot3(scMediaSpline(:,1),scMediaSpline(:,2),scMediaSpline(:,3))

scatters = findobj('marker','o');
lines =  findobj('type','line','linestyle','-');
