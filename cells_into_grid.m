ogs = 8; %grid size
grid_full = false(1,ogs^2);
grid_pos = zeros(size(Centers,3),2);
for i = 1:size(Centers,3)
    cx = mean(Centers(~isnan(Centers(:,1,i)),1,i));
    cy = mean(Centers(~isnan(Centers(:,2,i)),2,i));
    gridx = ceil(cx/(512/ogs));
    gridy = ceil(cy/(512/ogs));
    dist_vec = repmat([gridx gridy],[ogs^2 1]) - [repmat((1:ogs)',[ogs 1]) ceil(((1:ogs^2)/ogs)')];
    dist = sqrt(dist_vec(:,1).^2+dist_vec(:,2).^2);
    [sd, sdi] =  sort(dist,'ascend');
    done = false;
    testi = 1;
    while ~done
        if ~grid_full(sdi(testi))
            [t1, t2] = ind2sub([ogs ogs],sdi(testi));
            grid_pos(i,:) = [t1 t2];
            grid_full(sdi(testi)) = true;
            done = true;
        else
            testi = testi+1;
        end
    end     
end

% [gvs,gi] = sort(grid_val,'ascend');