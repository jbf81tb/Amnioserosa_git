function fxyc_struct = find_and_fix_self_coincidence(fxyc_struct,mov_sz)
ml = mov_sz(3);
lst = length(fxyc_struct);
y_tot = mov_sz(1);
x_tot = mov_sz(2);
pinds = cell(lst,ml);
pri = primes(10^7);
pri = pri(1:lst);
good = ~cellfun(@isempty,{fxyc_struct.frame});
good_ind = find(good);
xpos = {fxyc_struct(good).xpos};
ypos = {fxyc_struct(good).ypos};
frames = {fxyc_struct(good).frame};
if exist(fullfile('.','pself_coin.mat'),'file')
    load pself_coin.mat pinds
else
    isframe = cell(ml,1);
    for i = 1:ml
        for j = 1:length(frames)
            if sum(frames{j}==i)
                isframe{i} = [isframe{i} j];
            end
        end
    end
    fprintf('Percent complete: %3i%%',0);
    for fr = 1:ml
        allx = []; ally = []; pind = [];
        for i = 1:length(xpos)
            if sum(isframe{fr}==i)
                ind = find(frames{i}==fr);
                if mod(xpos{i}(ind),1)~=0||mod(ypos{i}(ind),1)~=0, continue; end
                allx = [allx xpos{i}(ind)]; %#ok<*AGROW>
                ally = [ally ypos{i}(ind)];
                pind = [pind pri(good_ind(i))];
            end
        end
        mask = zeros(y_tot,x_tot);
        ind_mask = ones(y_tot,x_tot);
        for i = 1:length(allx)
            mask(ceil(ally(i)),ceil(allx(i))) = mask(ceil(ally(i)),ceil(allx(i))) + 1;
            ind_mask(ceil(ally(i)),ceil(allx(i))) = ind_mask(ceil(ally(i)),ceil(allx(i)))*pind(i);
        end
        mask = conv2(mask,.25*[1,1,1;1,4,1;1,1,1],'same');
        
        img=ind_mask.*(mask>1);
        B = bwboundaries(img);
        for i = 1:length(B)
            uB = unique(B{i},'rows');
            tmp = [];
            for j = 1:size(uB,1)
                tmp = [tmp sort(factor2(img(B{i}(j,1),B{i}(j,2)),pri))];
            end
            tmp = unique(tmp);
            for j = 1:length(tmp)
                tmp(j) = find(tmp(j)==pri);
            end
            for j = 1:length(tmp)
                pinds{tmp(j),fr} = tmp(tmp~=tmp(j));
            end
        end
        fprintf('\b\b\b\b%3i%%',ceil(100*fr/ml));
    end
    fprintf('\b\b\b\b%3i%%\n',100);
end
for i = 1:size(pinds,1)
    if isempty(fxyc_struct(i).frame), continue; end
    tmp = [];
    for j = 1:size(pinds,2)
        tmp = [tmp pinds{i,j}];
    end
    if isempty(tmp), continue; end
    utmp = unique(tmp);
    sum_ind = 0;
    for j = 1:length(utmp)
        ind_bin = sum(utmp(j) == tmp);
        if ind_bin>sum_ind
            sum_ind = ind_bin;
            max_ind = utmp(j);
        end
    end
    s = [fieldnames(fxyc_struct(1))';repmat({[]},size(fieldnames(fxyc_struct(1))'))];
    tmpst = struct(s{:});
    nind = 1;
    for fr = 1:ml
        ind1 = find(fxyc_struct(i).frame == fr);
        ind2 = find(fxyc_struct(max_ind).frame == fr);
        if isempty(ind1) && isempty(ind2), continue; end
        if isempty(ind2)
            tmpst.frame(nind,1) = fxyc_struct(i).frame(ind1);
            tmpst.xpos(nind,1) = fxyc_struct(i).xpos(ind1);
            tmpst.ypos(nind,1) = fxyc_struct(i).ypos(ind1);
            tmpst.int(nind,1) = fxyc_struct(i).int(ind1);
            tmpst.coin(:,nind) = fxyc_struct(i).coin(:,ind1);
            tmpst.st(nind,1) = fxyc_struct(i).st(ind1);
            nind = nind + 1;
        elseif isempty(ind1)
            tmpst.frame(nind,1) = fxyc_struct(max_ind).frame(ind2);
            tmpst.xpos(nind,1) = fxyc_struct(max_ind).xpos(ind2);
            tmpst.ypos(nind,1) = fxyc_struct(max_ind).ypos(ind2);
            tmpst.int(nind,1) = fxyc_struct(max_ind).int(ind2);
            tmpst.coin(:,nind) = fxyc_struct(max_ind).coin(:,ind2);
            tmpst.st(nind,1) = fxyc_struct(max_ind).st(ind2);
            nind = nind + 1;
        else
            [~,m] = max([fxyc_struct(i).int(ind1),fxyc_struct(max_ind).int(ind2)]);
            if m == 1
                tmpst.frame(nind,1) = fxyc_struct(i).frame(ind1);
                tmpst.xpos(nind,1) = fxyc_struct(i).xpos(ind1);
                tmpst.ypos(nind,1) = fxyc_struct(i).ypos(ind1);
                tmpst.int(nind,1) = fxyc_struct(i).int(ind1);
                tmpst.coin(:,nind) = fxyc_struct(i).coin(:,ind1);
                tmpst.st(nind,1) = fxyc_struct(i).st(ind1);
                nind = nind + 1;
            elseif m ==2
                tmpst.frame(nind,1) = fxyc_struct(max_ind).frame(ind2);
                tmpst.xpos(nind,1) = fxyc_struct(max_ind).xpos(ind2);
                tmpst.ypos(nind,1) = fxyc_struct(max_ind).ypos(ind2);
                tmpst.int(nind,1) = fxyc_struct(max_ind).int(ind2);
                tmpst.coin(:,nind) = fxyc_struct(max_ind).coin(:,ind2);
                tmpst.st(nind,1) = fxyc_struct(max_ind).st(ind2);
                nind = nind + 1;
            end
        end
    end
    tmpst.class = 0;
    tmpst.lt = tmpst.frame(end)-tmpst.frame(1)+1;
    fxyc_struct(i) = tmpst;
    for j = 1:length(utmp)
        fxyc_struct(utmp(j)) = struct(s{:});
    end
end
% save pself_coin.mat pinds
end
function fac = factor2(n,list)
fac = list(rem(n,list)==0);
end