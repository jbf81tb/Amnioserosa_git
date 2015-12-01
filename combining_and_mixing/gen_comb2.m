function comb = gen_comb2(fxyc,i,s)
global ord
comb = struct('trace',struct(s{:}),'lvl',0,'ind',0);
o = ord(end);
matches = cell(o+1,1); %ugly :(
comb.trace(1) = fxyc{o}(i);
comb.lvl(1) = o;
comb.ind(1) = i;
if isempty(fxyc{o}(i).coin), return; end
cmb_nm = 2;
for q = -1:2:1
    matches{o+q} = unique(fxyc{o}(i).coin((q+3)/2,:));
    matches{o+q}(matches{o+q}==0) = [];
    for k = 1:length(matches{o+q})
        comb.trace(cmb_nm) = fxyc{o+q}(matches{o+q}(k));
        comb.lvl(cmb_nm) = o+q;
        comb.ind(cmb_nm) = matches{o+q}(k);
        cmb_nm = cmb_nm + 1;
    end
    for j = 1:length(matches{o+q})
        if isempty(fxyc{o+q}(matches{o+q}(j)).coin), continue; end
        matches{o} = [matches{o}, fxyc{o+q}(matches{o+q}(j)).coin((3-q)/2,:)];
    end
    matches{o} = unique(matches{o});
    matches{o}(matches{o}==0|matches{o}==i) = [];
end
for k = 1:length(matches{o})
    comb.trace(cmb_nm) = fxyc{o}(matches{o}(k));
    comb.lvl(cmb_nm) = o;
    comb.ind(cmb_nm) = matches{o}(k);
    cmb_nm = cmb_nm + 1;
end

lm = cellfun(@length,matches);
at = o;
while true
    for j = 1:length(matches{at})
        if isempty(fxyc{at}(matches{at}(j)).coin), continue; end
        switch at
            case o-1
                matches{o} = [matches{o}, fxyc{o-1}(matches{o-1}(j)).coin(2,:)];
            case o
                for q = -1:2:1
                    matches{o+q} = [matches{o+q}, fxyc{o}(matches{o}(j)).coin((q+3)/2,:)];
                end
            case o+1
                matches{o} = [matches{o}, fxyc{o-1}(matches{o-1}(j)).coin(1,:)];
        end
    end
    switch at
        case {o-1,o+1}
            matches{o} = unique(matches{o});
            matches{o}(matches{o}==0|matches{o}==i) = [];
        case o
            for q = -1:2:1
                matches{o+q} = unique(matches{o+q});
                matches{o+q}(matches{o+q}==0) = [];
            end
    end
    if length(matches{at})==lm(at), break; end
    for k = 1:length(matches{at})
        switch at
            case {o-1,o+1}
                comb.trace(cmb_nm) = fxyc{o}(matches{o}(k));
                comb.lvl(cmb_nm) = o;
                comb.ind(cmb_nm) = matches{o}(k);
                cmb_nm = cmb_nm + 1;
            case o
                for q = -1:2:1
                    comb.trace(cmb_nm) = fxyc{o+q}(matches{o+q}(k));
                    comb.lvl(cmb_nm) = o+q;
                    comb.ind(cmb_nm) = matches{o+q}(k);
                    cmb_nm = cmb_nm + 1;
                end
        end
    end
    lm = cellfun(@length,matches);
    switch at
        case o
            at = o-1;
        case o-1
            at = o+1;
        case o+1
            at = o;
    end
end
end