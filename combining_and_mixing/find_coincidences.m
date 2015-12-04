function structs = find_coincidences(structs,mov_sz)
sst = size(structs);
ml = mov_sz(3);
mask = cell([sst,ml]);
ind_mask = cell([sst,ml]);
pinds = cell([sst-[0,1],ml]);
lst = cellfun(@length, structs);
y_tot = mov_sz(1);
x_tot = mov_sz(2);
fprintf('Percent Complete (Coincidence Finding): %3i%%',0);

for sec = 1:sst(1)
    pri = primes((2*sum(lst(sec,:)))^(1.2));
    pri = pri(1:sum(lst(sec,:)));
    num_tr_st = zeros(1,sst(2));
    for i = 2:sst(2)
        num_tr_st(i) = num_tr_st(i-1) + lst(sec,i-1);
    end
    for st = 1:sst(2)
        xpos = {structs{sec,st}.xpos};
        ypos = {structs{sec,st}.ypos};
        frames = {structs{sec,st}.frame};
        
        for i = 1:length(frames)
            structs{sec,st}(i).coin = zeros(2,length(frames{i}));
            structs{sec,st}(i).st = st*ones(length(frames{i}),1);
        end
        
        isframe = cell(ml,1);
        for i = 1:ml
            for j = 1:length(frames)
                if sum(frames{j}==i)
                    isframe{i} = [isframe{i} j];
                end
            end
        end
        
        for fr = 1:ml
            allx = []; ally = []; pind = [];
            for i = 1:length(xpos)
                if sum(isframe{fr}==i)
                    ind = find(frames{i}==fr);
%                     if mod(xpos{i}(ind),1)~=0||mod(ypos{i}(ind),1)~=0, continue; end
                    allx = [allx xpos{i}(ind)]; %#ok<*AGROW>
                    ally = [ally ypos{i}(ind)];
                    pind = [pind pri(num_tr_st(st)+i)];
                end
            end
            mask{sec,st,fr} = zeros(y_tot,x_tot);
            ind_mask{sec,st,fr} = ones(y_tot,x_tot);
            if isempty(isframe{fr}), continue; end
            for i = 1:length(allx)
                mask{sec,st,fr}(ceil(ally(i)),ceil(allx(i))) = 1;
                ind_mask{sec,st,fr}(ceil(ally(i)),ceil(allx(i))) = pind(i);
            end
            B = bwboundaries(mask{sec,st,fr});
            sz = cellfun(@size,B,repmat({1},length(B),1));
            tmpi = find(sz>2);
            if ~isempty(tmpi)
                for dum = 1:length(tmpi)
                    for dum2 = 2:length(B{tmpi(dum)}-1)
                        mask{sec,st,fr}(B{tmpi(dum)}(dum2,1),B{tmpi(dum)}(dum2,2))=0;
                        ind_mask{sec,st,fr}(B{tmpi(dum)}(dum2,1),B{tmpi(dum)}(dum2,2))=1;
                    end
                end
            end
            mask{sec,st,fr} = conv2(mask{sec,st,fr},.25*[1,1,1;1,4,1;1,1,1],'same');
            if st>1
                img=ind_mask{sec,st-1,fr}.*ind_mask{sec,st,fr}.*(mask{sec,st-1,fr}+mask{sec,st,fr}>1);
                B = bwboundaries(img);
                pinds{sec,st-1} = zeros(length(B),2);
                for i = 1:length(B)
                    if size(B{i},1)==2
                        tmp = sort(factor2(img(B{i}(1,1),B{i}(1,2)),pri));
                    elseif size(B{i},1)==3
                        tmp = sort([img(B{i}(1,1),B{i}(1,2)),img(B{i}(2,1),B{i}(2,2))]);
                    end
                    pinds{sec,st-1,fr}(i,1) = find(tmp(1)==pri)-num_tr_st(st-1);
                    pinds{sec,st-1,fr}(i,2) = find(tmp(2)==pri)-num_tr_st(st);
                    ind = pinds{sec,st-1,fr}(i,:);
                    fr_ind1 = structs{sec,st-1}(ind(1)).frame==fr;
                    fr_ind2 = structs{sec,st}(ind(2)).frame==fr;
                    structs{sec,st-1}(ind(1)).coin(2,fr_ind1) = ind(2);
                    structs{sec,st}(ind(2)).coin(1,fr_ind2) = ind(1);
                end
            end
            fprintf('\b\b\b\b%3i%%',ceil(100*((sec-1)*sst(2)*ml+(st-1)*ml+fr)/(sst(1)*sst(2)*ml)));
        end
    end
end
fprintf('\b\b\b\b%3i%%\n',100);
end
function fac = factor2(n,list)
fac = list(rem(n,list)==0);
end