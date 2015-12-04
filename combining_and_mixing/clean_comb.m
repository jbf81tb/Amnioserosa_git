function comb = clean_comb(comb)
if length(comb.trace) == 1, return; end
dist = zeros(length(comb.trace),1);
num = zeros(length(comb.trace),1);
for fr = comb.trace(1).frame'
    ind1 = find(comb.trace(1).frame==fr);
    x1 = comb.trace(1).xpos(ind1);
    y1 = comb.trace(1).ypos(ind1);
    for j = 1:length(comb.trace)
        ind = find(comb.trace(j).frame==fr);
        if isempty(ind), continue; end
        x2 = comb.trace(j).xpos(ind);
        y2 = comb.trace(j).ypos(ind);
        dist(j) = dist(j) + sqrt((x1-x2)^2+(y1-y2)^2);
        num(j) = num(j) + 1;
    end
end
d = dist./num.^1.1>sqrt(2)|num<6;
d(1) = false;
comb.trace(d) = [];
comb.lvl(d) = [];
comb.ind(d) = [];
end