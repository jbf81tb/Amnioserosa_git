fxyc{1} = structs{1,1};
fxyc{2} = structs{1,2};
s = [fieldnames(fxyc{1}(1))';repmat({[]},size(fieldnames(fxyc{1}(1))'))];
z = repmat({0},size(fxyc{1}));
es = repmat({struct(s{:})},size(fxyc{1}));
comb = struct('trace',es,'lvl',z,'ind',z);
for i = 1:length(fxyc{1})
%     if fxyc{1}(i).class == 4, continue; end
    matches = cell(2,1);
    comb(i).trace(1) = fxyc{1}(i);
    comb(i).lvl(1) = 1;
    comb(i).ind(1) = i;
    if isempty(fxyc{1}(i).coin), continue; end
    matches{1} = unique(fxyc{1}(i).coin(2,:));
    matches{1}(matches{1}==0) = [];
    
    cmb_nm = 2;
    for k = 1:length(matches{1})
        comb(i).trace(cmb_nm) = fxyc{2}(matches{1}(k));
        comb(i).lvl(cmb_nm) = 2;
        comb(i).ind(cmb_nm) = matches{1}(k);
        cmb_nm = cmb_nm + 1;
    end
    
    for j = 1:length(matches{1})
        matches{2} = [matches{2}, fxyc{2}(matches{1}(j)).coin(1,:)];
    end
    matches{2} = unique(matches{2});
    matches{2}(matches{2}==0|matches{2}==i) = [];
    
    for k = 1:length(matches{2})
        comb(i).trace(cmb_nm) = fxyc{1}(matches{2}(k));
        comb(i).lvl(cmb_nm) = 1;
        comb(i).ind(cmb_nm) = matches{2}(k);
        cmb_nm = cmb_nm + 1;
    end
    
    
    lm = cellfun(@length,matches);
    
    lvl = 1; cont = true;
    while cont == true
        for j = 1:length(matches{mod(lvl,2)+1})
            matches{lvl} = [matches{lvl}, fxyc{lvl}(matches{mod(lvl,2)+1}(j)).coin(mod(lvl,2)+1,:)];
        end
        matches{lvl} = unique(matches{lvl});
        matches{lvl}(matches{lvl}==0|matches{lvl}==i) = [];
        if length(matches{lvl})==lm(lvl), cont = false; continue; end
        for k = 1:length(matches{lvl})
            comb(i).trace(cmb_nm) = fxyc{mod(lvl,2)+1}(matches{lvl}(k));
            comb(i).lvl(cmb_nm) = mod(lvl,2)+1;
            comb(i).ind(cmb_nm) = matches{lvl}(k);
            cmb_nm = cmb_nm + 1;
        end
        lm = cellfun(@length,matches);
        lvl = mod(lvl,2)+1;
    end
end

for i = 1:length(comb)
    if isempty(comb(i).trace), continue; end
    dist = zeros(length(comb(i).trace),1);
    num = zeros(length(comb(i).trace),1);
   for fr = comb(i).trace(1).frame'
       ind1 = find(comb(i).trace(1).frame==fr);
       x1 = comb(i).trace(1).xpos(ind1);
       y1 = comb(i).trace(1).ypos(ind1);
       for j = 1:length(comb(i).trace)
           ind = find(comb(i).trace(j).frame==fr);
           if isempty(ind), continue; end
           x2 = comb(i).trace(j).xpos(ind);
           y2 = comb(i).trace(j).ypos(ind);
           dist(j) = dist(j) + sqrt((x1-x2)^2+(y1-y2)^2);
           num(j) = num(j) + 1;
       end
   end
   d = dist./num.^1.1>sqrt(2)|num<6;
   d(1) = false;
   comb(i).trace(d) = [];
   comb(i).lvl(d) = [];
   comb(i).ind(d) = [];
end

e = repmat({[]},size(comb));
z = repmat({0},size(comb));
mixed = struct('frame',e,'xpos',e,'ypos',e,'int',e,'lt',z,'lvl',z,'ind',z);

for i = 1:length(comb)
    if isempty(comb(i).trace), continue; end
    lct = length(comb(i).trace);
    l = 1;
    for fr = 1:100;
        int = [0, 0, 0];
        for j = 1:lct
            ind = find(comb(i).trace(j).frame == fr);
            if isempty(ind), continue; end
            if comb(i).trace(j).int(ind) > int(1)
                int(1) = comb(i).trace(j).int(ind);
                int(2) = j;
                int(3) = ind;
            end
            
        end
        if sum(int) == 0, continue; end
        mixed(i).frame(l) = fr;
        mixed(i).int(l) = int(1);
        mixed(i).xpos(l) = comb(i).trace(int(2)).xpos(int(3));
        mixed(i).ypos(l) = comb(i).trace(int(2)).ypos(int(3));
        mixed(i).lvl(l) = comb(i).lvl(int(2));
        mixed(i).ind(l) = comb(i).ind(int(2));
        l = l+1;
    end
    mixed(i).lt = mixed(i).frame(end)-mixed(i).frame(1)+1;
end


%{
%%
ml = length(imfinfo('good_amneo.tif'));
img = zeros([size(imread('good_amneo.tif')),100]);
for i = 1:3:298
    img(:,:,(i+2)/3) = imread('good_amneo.tif',i);
end

%%
c = 'rgbmyc';
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:length(comb)%ceil(length(comb)*rand(1,20))
    if length(comb(i).trace)<4, continue; end
    for fr = 1:100%comb(i).trace(1).frame';
        imagesc(img(:,:,fr));
        axis off
        hold on
        for j = 1:length(comb(i).trace)
            ind = find(comb(i).trace(j).frame==fr);
            line(comb(i).trace(j).xpos(ind),comb(i).trace(j).ypos(ind),'Color',c(mod(j,6)+1),'Marker','o','MarkerSize',10);
        end
        getframe;
    end
    pause
end
close
%}