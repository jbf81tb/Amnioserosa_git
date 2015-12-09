int_sum = zeros(1,mov_sz(3));
fprintf('Percent Complete: %3u%%',0);
for fr = 1:mov_sz(3)
    here = cellfun(@any,cellfun(@eq,{nsta.frame},repmat({fr},[1 length(nsta)]),'uniformoutput',false));
    for j = 1:length(nsta)
        if ~here(j), continue; end
        fr_ind = nsta(j).frame == fr;
        int_sum(fr) = int_sum(fr) + nsta(j).int(fr_ind);
    end
    int_sum(fr) = int_sum(fr)/sum(here);
fprintf('\b\b\b\b%3u%%',ceil(100*fr/mov_sz(3)));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
int = zeros(1,length(nsta));
for i = 1:length(nsta)
    int(i) = sum(nsta(i).int./int_sum(nsta(i).frame)')/nsta(i).lt;
end
%%
% int = cellfun(@sum,{nsta.int})./[nsta.lt];
[~, tmpi] = sort(int,'descend');
good = false(1,length(nsta));
good(tmpi(1:ceil(2*end/100))) = true;
% [hy,hx] = hist(int,1000);
% shy = zeros(1,length(hy));
% shy(1) = hy(1)/sum(hy);
% for i = 2:length(hy)
%     shy(i) = shy(i-1)+hy(i)/sum(hy);
% end
% int_lim = hx(find(shy-.99>eps,1));
%%
mpname = 'E:\Josh\Matlab\cmeAnalysis_movies\mb1_z0.4um_t1s002_good\max_proj.tif';
if exist('tmp.tif','file'), delete('tmp.tif'); end
fprintf('Percent Complete: %3u%%',0);
for fr = 1:mov_sz(3)
%     img = zeros([mov_sz(1:2),3],'uint16');
    tmp = double(imread(mpname,'index',fr))/(2^16-1);
    img = cat(3,tmp,tmp,tmp);
    for i = 1:length(nsta)
        if ~good(i), continue; end
        fr_ind = find(nsta(i).frame == fr);
        xpos = ceil(nsta(i).xpos(fr_ind));
        ypos = ceil(nsta(i).ypos(fr_ind));
        for xi = -1:1
            for yi = -1:1
                img(ypos+yi,xpos+xi,1) = 1;
                img(ypos+yi,xpos+xi,2) = 0;
                img(ypos+yi,xpos+xi,3) = 0;
            end
        end
    end
%     image(img)
%     pause
imwrite(img,'tmp.tif','writemode','append')
fprintf('\b\b\b\b%3u%%',ceil(100*fr/mov_sz(3)));
end
fprintf('\b\b\b\b%3u%%\n',100);
% imagesc(img)
% axis equal
