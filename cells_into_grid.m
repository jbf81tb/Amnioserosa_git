grid_full = false(1,64);
grid_pos = zeros(1,size(Centers,3));
for i = 1:size(Centers,3)
    cx = mean(Centers(:,1,i));
    cy = mean(Centers(:,2,i));
    gridx = ceil(cx/64);
    gridy = ceil(cy/64);
    dist_vec = repmat([gridx gridy],[64 1]) - [repmat((1:8)',[8 1]) ceil(((1:64)/8)')];
    dist = sqrt(dist_vec(:,1).^2+dist_vec(:,2).^2);
    [sd, sdi] =  sort(dist,'ascend');
    done = false;
    testi = 1;
    while ~done
        if ~grid_full(sdi(testi))
            grid_pos(i) = sdi(testi);
            grid_full(sdi(testi)) = true;
            done = true;
        else
            testi = testi+1;
        end
    end     
end

% [gvs,gi] = sort(grid_val,'ascend');