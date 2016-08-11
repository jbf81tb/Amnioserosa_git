nstca = [];
for i = 1:length(nsta)
    nstca = [nstca, nsta{i}];
end
%%
mov_nm = 'E:\Josh\Matlab\cmeAnalysis_movies\new_amneo_movies\movies\160714_emb2_late\apical_proj.tif';
mov_sz = [size(imread(mov_nm)), length(imfinfo(mov_nm))];
%%
cond = apical;
nstca = nsta(cond);
%%
ml = mov_sz(3);
max_int = max(cellfun(@max,cellfun(@single,{nstca.int},'UniformOutput',false)));
max_st = max(cellfun(@max,cellfun(@single,{nstca.st},'UniformOutput',false)));
max_lt = max([nstca.lt]);
ml = max(cellfun(@max,cellfun(@single,{nstca.frame},'UniformOutput',false)));

cmap = rainbow;
% figure
% cmap = colormap('jet');
% close
%%
xpos = cell(1,ml); ypos = cell(1,ml); zpos = cell(1,ml); c = cell(1,ml);
fprintf('Percent complete: %3u%%',0);
for fr = 1:ml
    for i = 1:length(nstca)
        if ~any(nstca(i).frame==fr), continue; end
        fr_ind = nstca(i).frame==fr;
        if nstca(i).sl(fr_ind)~=0
            xpos{fr} = [xpos{fr}, single(nstca(i).xpos(fr_ind))];
            ypos{fr} = [ypos{fr}, single(nstca(i).ypos(fr_ind))];
            zpos{fr} = [zpos{fr}, single(nstca(i).st(fr_ind))];
            col_int = max(min(ceil(64*(nstca(i).sl(fr_ind)+.06)/.12),64),1);
            c{fr} = [c{fr}; cmap(col_int,:)];
        end
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
if exist('tmp','dir'), rmdir('tmp','s'); end
mkdir('tmp');

for fr = 1:ml
close all
fh = figure('color',.4*ones(3,1),'units','pixels','position',[1 1 1025 1025]);
     cond = true(1,length(xpos{fr}));%ypos{fr}>100&ypos{fr}<200&xpos{fr}>100&xpos{fr}<200;
axes('units','pixels','position',[1 1 1024 1024]);
cmap = [colormap(gray); rainbow];
img = imread(mov_nm,fr);
maximg = max(img(:));
imagesc(img-min(img(:)),[1 maximg-min(img(:))])
%         scatter3(xpos{fr}(cond),ypos{fr}(cond),zpos{fr}(cond),50,c{fr}(cond),'.')
    for i = 1:length(nstca)
        if ~any(nstca(i).frame==fr), continue; end
        fr_ind = find(nstca(i).frame==fr);
        col_int = 64+min(ceil(64*nstca(i).st(end)/15),64);
        line(nstca(i).xpos(1:fr_ind),nstca(i).ypos(1:fr_ind),nstca(i).st(1:fr_ind),'color',cmap(col_int,:))
%         for j = 2:fr_ind;
%             if nstca(i).sl(j)~=0
%                 col_int = max(min(ceil(64*(nstca(i).sl(j)+.06)/.12),64),1);
%                 line(nstca(i).xpos(j-1:j),nstca(i).ypos(j-1:j),'color',cmap(col_int+64,:),'linewidth',2)
%             end
%         end
    end
    axis equal
    axis ij
    axis off
    set(fh,'name',num2str(fr));
    xlim([0 512])
    ylim([0 512])
%     zlim([0,3*max_st]) 3*nstca(i).st(j-1:j),
%     view(10,80)
%     pause(1/30)
    F = getframe(gca,[0 0 1024 1024]);
    imwrite(F.cdata,['tmp\' sprintf('%03u',fr) '.tif'],'tif')
end
close