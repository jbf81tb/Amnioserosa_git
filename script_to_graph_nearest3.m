fxyc_struct = slstno4;
simg = [size(near2,1),size(near2,2)];
frames = {fxyc_struct.frame};
slopes = {fxyc_struct.sl};
nzslp = cellfun(@nonzeros,slopes,'uniformoutput',false);
nzslpv = vertcat(nzslp{:});
medsl = median(nzslpv);
img = zeros([simg,100]);
ml = 100;
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
    slp = zeros(lisfr,2);
    for j = 1:lisfr
        ind = isframe{fr}(j);
        fr_ind = find(frames{ind}==fr);
        slp(j,1) = ind;
        slp(j,2) = slopes{ind}(fr_ind);
    end
    for i = 1:simg(1)
        for j = 1:simg(2)
            guess = 1; tot = 0; good = 1;
            while guess <= 10
                ind = slp(:,1)==near2(i,j,fr,guess);
                guess = guess + 1;
                if slp(ind,2)
                    tot = tot + (2*medsl - slp(ind,2));
                    good = good + 1;
                end
            end
            img(i,j,fr) = tot/good;
        end
    end
    fprintf('\b\b\b\b%3i%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3i%%\n',100);
save nearest3_img.mat img