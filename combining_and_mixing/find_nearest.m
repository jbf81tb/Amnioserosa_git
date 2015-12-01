function near = find_nearest(fxyc_struct,mov_sz)
xpos = {fxyc_struct.xpos};
ypos = {fxyc_struct.ypos};
frames = {fxyc_struct.frame};
ml = mov_sz(3);
nn = 10; %number near (how much to save)
ymax = mov_sz(1);
xmax = mov_sz(2);
near = zeros(ymax,xmax,ml,nn,'uint16');

isframe = cell(ml,1);
for i = 1:ml
    for j = 1:length(frames)
        if sum(frames{j}==i)
            isframe{i} = [isframe{i} j];
        end
    end
end
fprintf('Percent Complete: %3i%%',0);
for fr = 1:ml
    lisfr = length(isframe{fr});
    xy = zeros(lisfr,2);
    for j = 1:lisfr
        ind = isframe{fr}(j);
        fr_ind = find(frames{ind}==fr);
        xy(j,1) = xpos{ind}(fr_ind);
        xy(j,2) = ypos{ind}(fr_ind);
    end
    for x = 1:xmax
        for y = 1:ymax
            dist_ar = xy - repmat([x y],[lisfr 1]);
            dist = sqrt(dist_ar(:,1).^2 + dist_ar(:,2).^2);
            [sd, sdi] = sort(dist,'ascend');
            if sd(1) == 0
                near{fr}(y,x) = isframe{fr}(sdi(1:nn));
            end
        end
    end
    fprintf('\b\b\b\b%3i%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3i%%\n',100);
end