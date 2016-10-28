% Resize a loop by inputting a multiplicative factor. Outputs coordinates
% of resized loop.

function out = resizeLoop(in,factor)
if factor == 1;
    out = in;
    return
end

% Interval division: +ve k for internal division, -ve k for external 
% division.
k = 1/(1/factor - 1);
centre = mean(in,1);
out = (ones(size(in,1),1) * centre ...
    + k * in) / (1 + k);
end