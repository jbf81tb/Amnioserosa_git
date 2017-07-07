function structs = mix_n_replace(comb,n,o,s,structs,mov_sz)
global ord
lct = length(comb.trace);
ml = mov_sz(3);
if lct == 1,
    mixed = comb.trace;
    lvl = ones(length(comb.trace.frame),1)*comb.lvl;
    ind = ones(length(comb.trace.frame),1)*comb.ind;
else
    mixed = struct(s{:});
    mixed.class=0;
    lvl = []; ind = [];
    l = 1;
    for fr = 1:ml
        int = [0, 0, 0];
        rI = 0; I = 0; count = 0;
        for j = 1:lct
            fr_ind = find(comb.trace(j).frame == fr);
            if isempty(fr_ind), continue; end
%             if any(comb.trace(j).weight>0) && ~all(comb.trace(j).weight>0)
%                 comb.trace(j).weight(comb.trace(j).weight==0) = 1;
%             end
            if comb.trace(j).int(fr_ind) > int(1)
                int(1) = comb.trace(j).int(fr_ind);
                int(2) = j;
                int(3) = fr_ind;
            end
            rI = rI + comb.trace(j).st(fr_ind)*comb.trace(j).int(fr_ind)*comb.trace(j).weight(fr_ind);
            I = I + comb.trace(j).int(fr_ind)*comb.trace(j).weight(fr_ind);
        end
        if int(1) == 0, continue; end
        mixed.frame(l) = fr;
        mixed.int(l) = int(1);
        mixed.xpos(l) = comb.trace(int(2)).xpos(int(3));
        mixed.ypos(l) = comb.trace(int(2)).ypos(int(3));
        mixed.st(l) = rI/I;
        mixed.weight(l) = I/int(1);
        lvl(l) = comb.lvl(int(2)); %#ok<AGROW>
        ind(l) = comb.ind(int(2)); %#ok<AGROW>
        if isempty(comb.trace(int(2)).coin), continue; end
        if lvl(l) == o || o == ord(end)
            mixed.coin(1,l) = 0;
            mixed.coin(2,l) = 0;
        elseif lvl(l) == look(n,o)
            mixed.coin(:,l) = comb.trace(int(2)).coin(:,int(3));
        end
        l = l+1;
    end
    mixed.frame = mixed.frame';
    mixed.int =  mixed.int';
    mixed.xpos = mixed.xpos';
    mixed.ypos = mixed.ypos';
    mixed.st = mixed.st';
    mixed.weight = mixed.weight';
    mixed.lt = mixed.frame(end)-mixed.frame(1)+1;
end
if any(lvl==look(n,o))
    set_ind = mode(ind(lvl==look(n,o)));
    set_lvl = mode(lvl(lvl==look(n,o)));
else
    set_ind = mode(ind);
    set_lvl = mode(lvl);
end
    structs{set_lvl}(set_ind) = mixed;
for j = 1:lct
    if comb.lvl(j)==set_lvl && comb.ind(j)==set_ind, continue; end
    structs{comb.lvl(j)}(comb.ind(j)) = struct(s{:});
end

end