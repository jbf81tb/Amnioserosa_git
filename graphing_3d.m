nstca = [];
for i = 1:6
    nstca = [nstca, nst{i}];
end
%%
mov_nm = 'E:\MATLAB\Josh\ran_movies\Hela_movie\20151005_hela plaques cell 7_z1.tif';
mov_sz = [size(imread(mov_nm)), length(imfinfo(mov_nm))];
%%
cond = [];%true(1,length(nsta));
nstca = nstaw4;%nsta(cond);
%%
ml = mov_sz(3);
max_int = max(cellfun(@max,{nstca.int}));
max_lt = max([nstca.lt]);
figure
cmap = colormap('jet');
close
%%
xpos = cell(1,ml); ypos = cell(1,ml); zpos = cell(1,ml); c = cell(1,ml);
fprintf('Percent complete: %3u%%',0);
for fr = 1:ml
    for i = 1:length(nstca)
        if ~any(nstca(i).frame==fr), continue; end
        fr_ind = nstca(i).frame==fr;
        xpos{fr} = [xpos{fr}, nstca(i).xpos(fr_ind)];
        ypos{fr} = [ypos{fr}, nstca(i).ypos(fr_ind)];
        zpos{fr} = [zpos{fr}, nstca(i).st(fr_ind)];
        col_int = min(ceil(64*nstca(i).st(fr_ind)/10),64);
        c{fr} = [c{fr}; cmap(col_int,:)];
%         c{fr} = [c{fr}, nstca(i).int(fr_ind)];
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
if exist('tmp','dir'), rmdir('tmp','s'); end
mkdir('tmp');

for fr = 1:ml
close all
fh = figure('color',.4*ones(3,1));
%      cond = true(1,length(xpos{fr}));%ypos{fr}>100&ypos{fr}<200&xpos{fr}>100&xpos{fr}<200;
axes('units','pixels','position',[10 10 512 512]);
%         scatter3(xpos{fr}(cond),ypos{fr}(cond),zpos{fr}(cond),50,c{fr}(cond),'.')
    for i = 1:length(nstca)
        if ~any(nstca(i).frame==fr), continue; end
        fr_ind = find(nstca(i).frame==fr);
        col_int = min(ceil(64*nstca(i).st(end)/21),64);
        line(nstca(i).xpos(1:fr_ind),nstca(i).ypos(1:fr_ind),nstca(i).st(1:fr_ind),'color',cmap(col_int,:))
%         for j = 2:fr_ind;
%             col_int = min(ceil(64*nstca(i).st(j)/6),64);
%             line(nstca(i).xpos(j-1:j),nstca(i).ypos(j-1:j),nstca(i).st(j-1:j),'color',cmap(col_int,:))
%         end
    end
    axis equal
    axis ij
    axis off
    set(fh,'name',num2str(fr));
    xlim([0 512])
    ylim([0 512])
    zlim([0,22])
    view(0,90)
%     pause(1/30)
    F = getframe(gca,[0 0 512 512]);
    imwrite(F.cdata,['tmp\' sprintf('%03u',fr) '.tif'],'tif')
end