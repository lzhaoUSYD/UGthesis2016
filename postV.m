close all 
clear
clc

load MPresults

numResults = length(MPresult);

for r = 1:numResults
    result = MPresult(r,:);
    
%     subplot(
    plotV(result)
end

