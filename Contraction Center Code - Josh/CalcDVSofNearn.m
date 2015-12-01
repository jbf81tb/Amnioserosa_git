function [Velocity, Strain]=CalcDVSofNearn(Cs,Ds,x,y,n)
% DensityMap = zeros(1,4);
Dar = Cs - repmat([x y], [length(Cs) 1]);
D = sqrt(Dar(:,1).^2 + Dar(:,2).^2);
[~,inds]=sort(D,'ascend');
% DensityMap(1) = mean(sorted(1:n));
inds = inds(1:n);

inds = inds(~isnan(Ds(inds,1)));
drfar = Cs(inds,:)+Ds(inds,:) - repmat([x y], [length(inds) 1]);
driar = Cs(inds,:)-Ds(inds,:) - repmat([x y], [length(inds) 1]);
drf = sqrt(drfar(:,1).^2 + drfar(:,2).^2);
dri = sqrt(driar(:,1).^2 + driar(:,2).^2);
drs = drf-dri;
rs = (drf+dri)/2;

[~,Velocity]=cart2pol(sum(Ds(inds,1)),sum(Ds(inds,2)));
Velocity = Velocity/n;
Strain = sum(drs)/sum(rs);
end