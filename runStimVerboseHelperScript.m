% Doesn't make much sense out of context.

activeCell = num2cell(activeElectrodes);
fprintf('\nActive electrodes: ');
fprintf('\t\t%d\t',activeCell{:});
currentsCell =  num2cell(inputCurrents);
fprintf('\nElectrode currents: ');
fprintf('\t%.4f\t',currentsCell{:});
fprintf('\n');
