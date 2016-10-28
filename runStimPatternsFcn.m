% Runs, plots, saves and re-loads for the next iteration. But do changes to
% the model in a function persist outside of it?

function result = runStimPatternsFcn(model,e,simStr,activeElectrodes,inputCurrents,result)
name = [simStr num2str(e)];

runStimVerboseHelperScript

result{e,1} = oneShotStimPattern(model,activeElectrodes,inputCurrents);
result{e,2} = activeElectrodes;
result{e,3} = inputCurrents;

plotV(result(e,:));
title(name);
figAdd = fullfile(pwd,'Outputs','Potentials',name);
savefig(figAdd)

tic
simDir = fullfile(pwd,'Outputs','simulations');
simAdd = fullfile(simDir,strrep(name,' ','_'));
fprintf('Saving as %s ...\n',simAdd);
mphsave(model,simAdd);
toc

end