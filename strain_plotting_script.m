sec=1;
for st = 1:3
    tmpl = cellfun(@isempty,{structs{sec,st}.frame});
    structs{sec,st}(tmpl) = [];
    mst{sec,st} = slope_finding(structs{sec,st},1,400);
end
msta = [mst{1} mst{2} mst{3}];
%%
for i = 1:length(nsta)
        nsta(i).strain = zeros(length(nsta(i).frame),1);
    for j = 1:length(nsta(i).frame)
        nsta(i).strain(j) = DVSMap_full_all{nsta(i).frame(j),2}(ceil(nsta(i).xpos(j)),ceil(nsta(i).ypos(j)));
    end
end
%%
close all
figure
cmap = colormap('jet');
clear tmp
tmp(:,1) = cell2mat({nsta.sl}');
tmp(:,2) = cell2mat({nsta.strain}');
q = tmp(:,1)==0;
tmp(q,:) = [];
[~, ssi] = sort(tmp(:,1));
sstrain = tmp(ssi,2);
clear w
for i = 1:10
w(:,i) = sstrain((1+(i-1)*floor(length(sstrain)/10)):(i*floor(length(sstrain)/10)));
vec = -.03:.001:.03;
[y,x] = hist(w(:,i),vec);
plot(x,y/sum(y),'Color',cmap(6*i,:))
hold on
end
%%
