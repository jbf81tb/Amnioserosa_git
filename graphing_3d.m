nsta = [];
for i = 1:6
    nsta = [nsta, nst{i}];
end
ml = mov_sz(3);
max_int = max(cellfun(@max,{nsta.int}));
max_lt = max([nsta.lt]);
figure
cmap = colormap('parula');
close
xpos = cell(1,ml); ypos = cell(1,ml); zpos = cell(1,ml); c = cell(1,ml);
fprintf('Percent complete: %3u%%',0);
for fr = 1:ml
    for i = 1:length(nsta)
        if ~any(nsta(i).frame==fr), continue; end
        fr_ind = nsta(i).frame==fr;
        xpos{fr} = [xpos{fr}, nsta(i).xpos(fr_ind)];
        ypos{fr} = [ypos{fr}, nsta(i).ypos(fr_ind)];
        zpos{fr} = [zpos{fr}, nsta(i).st(fr_ind)];
        col_int = min(ceil(64*nsta(i).st(fr_ind)/6),64);
        c{fr} = [c{fr}; cmap(col_int,:)];
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
if exist('tmp','dir'), rmdir('tmp','s'); end
mkdir('tmp');

for fr = 1:ml
close all
figure('color','k');
axes('units','pixels','position',[10 10 512 512]);
    %     scatter3(xpos{fr},ypos{fr},zpos{fr},50,c{fr},'.')
    for i = 1:length(nsta)
        if ~any(nsta(i).frame==fr), continue; end
        fr_ind = find(nsta(i).frame==fr);
%         col_int = min(ceil(64*nsta(i).st(end)/6),64);
%         line(nsta(i).xpos(1:fr_ind),nsta(i).ypos(1:fr_ind),nsta(i).st(1:fr_ind),'color',cmap(col_int,:))
        for j = 2:fr_ind;
            col_int = min(ceil(64*nsta(i).st(j)/6),64);
            line(nsta(i).xpos(j-1:j),nsta(i).ypos(j-1:j),nsta(i).st(j-1:j),'color',cmap(col_int,:))
        end
    end
    axis equal
    axis ij
    axis off
    
    xlim([0 512])
    ylim([0 512])
    zlim([0,6])
    view(0,90)
%     pause(.1)
    F = getframe(gca,[9 9 512 512]);
    imwrite(F.cdata,['tmp\' sprintf('%03u',fr) '.tif'],'tif')
end