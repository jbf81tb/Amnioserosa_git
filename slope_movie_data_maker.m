function slope_movie_data_maker(fxyc_struct)
pos_sl = cell(100,1);
dens_map = cell(100,1);
lt_map = cell(100,1);
fintdif = [];
fintinc = [];
maxsl = 0;
x_tot = 386;
y_tot = 370;

frame_rate = 1;
ml = 100;
trlts = [fxyc_struct.lt]*frame_rate;
ints = {fxyc_struct.int};
intdif = cell(length(ints),1);
intinc = cell(length(ints),1);
xpos = {fxyc_struct.xpos};
ypos = {fxyc_struct.ypos};
frames = {fxyc_struct.frame};

isframe = cell(ml,1);
for i = 1:ml
    isframe{i} = [];
    for j = 1:length(frames)
        if sum(frames{j}==i)
            isframe{i} = [isframe{i} j];
        end
    end
end

trange = 12;
forwardp = .5;
front = ceil(trange*forwardp/frame_rate);
rear = floor(trange*(1-forwardp)/frame_rate);
for i = 1:length(ints)
    if isempty(ints{i}), continue; end
    lint = length(ints{i});
    if lint>(trange/2)
        for j = 1:lint
            sub = (max(1,j-rear):min(lint,(j+front)));
            tmp = (ints{i}-min(ints{i}(sub)))/...
                (max(ints{i}(sub))-min(ints{i}(sub)));
            mx = mean(sub);
            tmpy = tmp(sub)';
            my = mean(tmpy);
            nume = sum(sub.*tmpy)/length(sub)-mx*my;
            denom = sum(sub.^2)/length(sub)-mx^2;
            intdif{i}(j) = nume/denom/frame_rate;
        end
    else
        intdif{i} = zeros(lint,1);
    end
    intinc{i} = intdif{i}.*(intdif{i}>0);
end

for i = 1:ml
    if ~isempty(isframe{i})
        mintinc = 0; counti = 0;
        for j = 1:length(isframe{i})
            ind = frames{isframe{i}(j)}==i;
            mintinc = mintinc + intinc{isframe{i}(j)}(ind);
            fintdif = [fintdif; intdif{isframe{i}(j)}(ind)];
            if intinc{isframe{i}(j)}(ind)>0, counti = counti+1; end
        end
        fintinc(i) = mintinc/counti;
    end
end

for fr = 1:ml
    allx = []; ally = []; allintinc= []; alllt = [];
    for i = 1:length(xpos)
        if sum(isframe{fr}==i)
            ind = find(frames{i}==fr);
            allx = [allx xpos{i}(ind)]; %#ok<*AGROW>
            ally = [ally ypos{i}(ind)];
            if intinc{i}(ind)>maxsl, maxsl=intinc{i}(ind); end
            allintinc = [allintinc intinc{i}(ind)];
            alllt = [alllt trlts(i)];
        end
    end
    pos_sl{fr} = zeros(y_tot,x_tot);
    lt_map{fr} = zeros(y_tot,x_tot);
    dens_map{fr} = zeros(y_tot,x_tot);
    for i = 1:length(allx)
        pos_sl{fr}(ceil(ally(i)),ceil(allx(i))) = allintinc(i);
        dens_map{fr}(ceil(ally(i)),ceil(allx(i))) = 1;
        lt_map{fr}(ceil(ally(i)),ceil(allx(i))) = alllt(i);
    end
end
save slope_movie_data.mat pos_sl maxsl lt_map dens_map -v7.3
end