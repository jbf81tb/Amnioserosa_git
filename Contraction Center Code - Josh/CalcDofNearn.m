function [DistMap, inds]=CalcDofNearn(Cs,x,y)
global n
tmp = zeros(1+length(Cs),1);
tmp(1,:) = [x y];
tmp(2:end+1,:) = Cs;
D = pdist(tmp);
D = D(1:length(Cs));
[sorted,inds]=sort(D,'ascend');
DistMap = mean(sorted(1:n));
inds = inds(1:n);
end