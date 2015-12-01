function CenterMap=CentersofExp(DVSMap)

VT=.1;
ST=-.024;
T = length(DVSMap);
[X, Y] = size(DVSMap{1,1});
CenterMap=cell(T,1);
cond1sum = zeros(T,1);
cond2sum = zeros(T,1);
for t=1:T
    CenterMap{t} = zeros(X,Y);
    cond1 = DVSMap{t,1}<=VT;
    cond2 = DVSMap{t,2}<ST;
    cond = cond2;
    CenterMap{t}=DVSMap{t,2}.*double(cond);
    cond1sum(t) = sum(cond1(:));
    cond2sum(t) = sum(cond2(:));
end
save conds.mat cond1sum cond2sum
end