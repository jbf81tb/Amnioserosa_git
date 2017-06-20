function comb = gen_comb(fxyc,o,i,n,s)
comb = struct('trace',struct(s{:}),'lvl',0,'ind',0);

matches = cell(2,1);
comb.trace(1) = fxyc{o}(i);
comb.lvl(1) = o;
comb.ind(1) = i;
if isempty(fxyc{o}(i).coin), return; end
matches{n} = nonzeros(unique(fxyc{o}(i).coin(swap(n),:)))';

cmb_nm = 2;
for k = 1:length(matches{n})
    comb.trace(cmb_nm) = fxyc{look(n,o)}(matches{n}(k));
    comb.lvl(cmb_nm) = look(n,o);
    comb.ind(cmb_nm) = matches{n}(k);
    cmb_nm = cmb_nm + 1;
end

for j = 1:length(matches{n})
    if isempty(fxyc{look(n,o)}(matches{n}(j)).coin), continue; end
    matches{swap(n)} = [matches{swap(n)}, fxyc{look(n,o)}(matches{n}(j)).coin(n,:)];
end
matches{swap(n)} = unique(matches{swap(n)});
matches{swap(n)}(matches{swap(n)}==0|matches{swap(n)}==i) = [];

for k = 1:length(matches{swap(n)})
    comb.trace(cmb_nm) = fxyc{o}(matches{swap(n)}(k));
    comb.lvl(cmb_nm) = o;
    comb.ind(cmb_nm) = matches{swap(n)}(k);
    cmb_nm = cmb_nm + 1;
end

lm = cellfun(@length,matches);
which_o = [o, look(n,o)];
while true
    for j = 1:length(matches{swap(n)})
        if isempty(fxyc{o}(matches{swap(n)}(j)).coin), continue; end
        matches{n} = [matches{n}, fxyc{o}(matches{swap(n)}(j)).coin(swap(n),:)];
    end
    matches{n} = unique(matches{n});
    matches{n}(matches{n}==0|matches{n}==i) = [];
    if length(matches{n})==lm(n), break; end
    for k = 1:length(matches{n})
        if any(comb.lvl==which_o(which_o~=o)&comb.ind==matches{n}(k)), continue; end
        comb.trace(cmb_nm) = fxyc{which_o(which_o~=o)}(matches{n}(k));
        comb.lvl(cmb_nm) = which_o(which_o~=o);
        comb.ind(cmb_nm) = matches{n}(k);
        cmb_nm = cmb_nm + 1;
    end
    lm = cellfun(@length,matches);
    o = which_o(which_o~=o);
    n = swap(n);
end
end