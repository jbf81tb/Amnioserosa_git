function structs = mix_n_replace(comb,n,o,s,structs,mov_sz)
global sec ord
lct = length(comb.trace);
ml = mov_sz(3);
if lct == 1,
    mixed = comb.trace;
    lvl = ones(length(comb.trace.frame),1)*comb.lvl;
    ind = ones(length(comb.trace.frame),1)*comb.ind;
else
    mixed = struct('frame',[],'xpos',[],'ypos',[],'class',0,'int',[],'lt',0,'coin',[],'st',[]);
    lvl = []; ind = [];
    l = 1;
    for fr = 1:ml
        int = [0, 0, 0];
        for j = 1:lct
            fr_ind = find(comb.trace(j).frame == fr);
            if isempty(fr_ind), continue; end
            if comb.trace(j).int(fr_ind) > int(1)
                int(1) = comb.trace(j).int(fr_ind);
                int(2) = j;
                int(3) = fr_ind;
            end
        end
        if int(1) == 0, continue; end
        mixed.frame(l) = fr;
        mixed.int(l) = int(1);
        mixed.xpos(l) = comb.trace(int(2)).xpos(int(3));
        mixed.ypos(l) = comb.trace(int(2)).ypos(int(3));
        mixed.st(l) = comb.trace(int(2)).st(int(3));
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
    mixed.lt = mixed.frame(end)-mixed.frame(1)+1;
end
if sum(lvl==look(n,o))
    set_ind = mode(ind(lvl==look(n,o)));
    set_lvl = mode(lvl(lvl==look(n,o)));
else
    set_ind = mode(ind);
    set_lvl = mode(lvl);
end
    structs{sec,set_lvl}(set_ind) = mixed;
for j = 1:lct
    if comb.ind(j)==set_ind && comb.lvl(j)==set_lvl, continue; end
    structs{sec,comb.lvl(j)}(comb.ind(j)) = struct(s{:});
end

end