% Kill n coordinates described in an n x 3 matrix (rogues) from a set of m
% coordinates in an m x 3 matrix (in).
function out = rmCoords(in,rogues)
out = in;
for r = 1:size(rogues,1)
    [d,I] = min(abs(in - ones(size(in,1),1)*rogues(r,:)));
    sum(d);
    rogueI = mode(I);
    out(rogueI,:) = [];
end
end