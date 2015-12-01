function slope_graph
load structs.mat structs
pos_sl = cell(12,3,100);
sst = size(structs);
for sec = 1:sst(1)
    for st = 1:sst(2)
        xpos = {structs{sec,st}.xpos};
        ypos = {structs{sec,st}.ypos};
        frames = {structs{sec,st}.frame};
        isframe = cell(ml,1);
        for i = 1:ml
            for j = 1:length(frames)
                if sum(frames{j}==i)
                    isframe{i} = [isframe{i} j];
                end
            end
        end
        for fr = 1:ml
            allx = []; ally = []; allintinc= []; pind = [];
            for i = 1:length(xpos)
                if sum(isframe{fr}==i)
                    ind = find(frames{i}==fr);
                    if mod(xpos{i}(ind),1)~=0||mod(ypos{i}(ind),1)~=0, continue; end
                    allx = [allx xpos{i}(ind)]; %#ok<*AGROW>
                    ally = [ally ypos{i}(ind)];
                    pind = [pind pri(num_tr_st(st)+i)];
                    allintinc = [allintinc intinc{i}(ind)];
                end
            end
            for i = 1:length(allx)
                pos_sl{sec,st,fr}(ceil(ally(i)),ceil(allx(i))) = allintinc(i);
            end
        end
    end
end