function structs = find_coincidences(structs,mov_sz)

nps = length(structs);
lst = cellfun(@length, structs);
fprintf('Percent Complete (Coincidence Finding): %3i%%',0);

ml = mov_sz(3);
mask = cell(2,1);
ind_mask = cell(2,1);
% pinds = cell(nps-1,ml);
[xpos, ypos, frames, inds] = deal(cell(nps,1));
y_tot = mov_sz(1);
x_tot = mov_sz(2);
pri = primes((2*sum(lst))^(1.2));
pri = pri(1:sum(lst));
num_tr_st = zeros(1,nps);
for i = 2:nps
    num_tr_st(i) = num_tr_st(i-1) + lst(i-1);
end
for st = 1:nps    
    for i = 1:lst(st)
        structs{st}(i).coin = zeros(2,length(structs{st}(i).frame));
        structs{st}(i).st = st*ones(length(structs{st}(i).frame),1);
        structs{st}(i).weight = ones(size(structs{st}(i).frame));
    end
    
    xpos{st} = cell2mat({structs{st}.xpos}');
    ypos{st} = cell2mat({structs{st}.ypos}');
    frames{st} = cell2mat({structs{st}.frame}');
    tmp1 = cellfun(@gt,{structs{st}.frame},repmat({0},size(structs{st})),'UniformOutput',false);
    tmp2 = num2cell(1:lst(st));
    inds{st} = cell2mat(cellfun(@mtimes,tmp1,tmp2,'UniformOutput',false)');
end
    
for fr = 1:ml
    for st = 1:nps
        mask{keep(st)} = zeros(y_tot,x_tot);
        ind_mask{keep(st)} = ones(y_tot,x_tot);
        if ~any(frames{st}==fr), continue; end
        
        allx = xpos{st}(frames{st}==fr);
        ally = ypos{st}(frames{st}==fr);
        pind = pri(num_tr_st(st)+inds{st}(frames{st}==fr));
        
        mask{keep(st)}(sub2ind([y_tot,x_tot],ceil(ally),ceil(allx))) = 1;
        ind_mask{keep(st)}(sub2ind([y_tot,x_tot],ceil(ally),ceil(allx))) = pind;
        
        B = bwboundaries(mask{keep(st)});
        sz = cellfun(@size,B,repmat({1},length(B),1));
        tmpi = find(sz>2);
        if ~isempty(tmpi)
            for dum = 1:length(tmpi)
                for dum2 = 2:length(B{tmpi(dum)}-1)
                    mask{keep(st)}(B{tmpi(dum)}(dum2,1),B{tmpi(dum)}(dum2,2))=0;
                    ind_mask{keep(st)}(B{tmpi(dum)}(dum2,1),B{tmpi(dum)}(dum2,2))=1;
                end
            end
        end
        mask{keep(st)} = conv2(mask{keep(st)},.25*[1,1,1;...
                                                   1,4,1;...
                                                   1,1,1],'same');
        if st>1
            img=ind_mask{swap(st)}.*ind_mask{keep(st)}.*((mask{swap(st)}+mask{keep(st)})>1);
            B = bwboundaries(img,8,'noholes');
            pinds = zeros(length(B),2);
            for i = 1:length(B)
                if size(B{i},1)==2
                    tmp = sort(factor2(img(B{i}(1,1),B{i}(1,2)),pri));
                elseif size(B{i},1)==3
                    tmp = sort([img(B{i}(1,1),B{i}(1,2)),img(B{i}(2,1),B{i}(2,2))]);
                else
                    continue;
                end
                pinds(i,1) = find(tmp(1)==pri)-num_tr_st(st-1);
                pinds(i,2) = find(tmp(2)==pri)-num_tr_st(st);
                ind = pinds(i,:);
                fr_ind1 = structs{st-1}(ind(1)).frame==fr;
                fr_ind2 = structs{st}(ind(2)).frame==fr;
                structs{st-1}(ind(1)).coin(2,fr_ind1) = ind(2);
%                 structs{st-1}(ind(1)).weight(fr_ind1) = 1;
                structs{st}(ind(2)).coin(1,fr_ind2) = ind(1);
%                 structs{st}(ind(2)).weight(fr_ind2) = 1;
            end
        end
    end
    fprintf('\b\b\b\b%3i%%',ceil(100*((fr-1)*nps+st)/(nps*ml)));
end
fprintf('\b\b\b\b%3i%%\n',100);
end
function fac = factor2(n,list)
fac = list(rem(n,list)==0);
end