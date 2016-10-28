%% Visualise Greenwood frequency function
s = load('spiralSplineNewgreenwoodF100.mat');
% 20 Hz to 20 kHz in numFreqLabels-1 steps
fMap = s.fMap;
% Spline for the scala media
scMediaSpline = s.scMediaSpline;

freqIndices = s.freqIndices;
% Currently 40 fibres 20 nodes. 30 frequency points is good for A_ labels.
% freqIndices = round(linspace(1,numFreqLabels,30)); 

for freqIndex = freqIndices
    coords = scMediaSpline(freqIndex,:);
    x = coords(1);y = coords(2); z = coords(3);
    freq = round(fMap(freqIndex));
    % Cater for the A_s to add special labels.
    As = 27.5*2.^(0:7);
    comp = abs((freq-As)./As);
    if any(comp<0.1)
        % We've got an A
        match = As(comp == min(comp));
        octave = find(comp == min(comp)) - 1;
        textStr = ['$ \bf' num2str(freq) ' Hz \left( \approx A_{' num2str(octave) '} \right) $'];
%         textStr = ['\bf \fontsize{18} '  num2str(match) ' Hz ($\approx$ A' num2str(octave) ')'];
    else        
        textStr = ['\it ' num2str(freq) ' Hz'];
    end
    text(x,y,z,textStr,'Interpreter','latex')
end
plot3(scMediaSpline(:,1),scMediaSpline(:,2),scMediaSpline(:,3))
