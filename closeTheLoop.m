function out = closeTheLoop(in,iterations)
for i = 1:iterations
    temp = [in;mean([in(1,:);in(end,:)],1)];
end
out = [temp;in(1,:)];
end