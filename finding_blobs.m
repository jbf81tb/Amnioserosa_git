ml = max(cellfun(@max,{nsta.frame}));
int_sum = zeros(1,ml);
fprintf('Percent Complete: %3u%%',0);
for fr = 1:ml
    here = cellfun(@any,cellfun(@eq,{nsta.frame},repmat({fr},[1 length(nsta)]),'uniformoutput',false));
    for j = 1:length(nsta)
        if ~here(j), continue; end
        fr_ind = nsta(j).frame == fr;
        int_sum(fr) = int_sum(fr) + nsta(j).int(fr_ind);
    end
    int_sum(fr) = int_sum(fr)/sum(here);
fprintf('\b\b\b\b%3u%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
int = zeros(1,length(nsta));
for i = 1:length(nsta)
    int(i) = sum(nsta(i).int./int_sum(nsta(i).frame)')/nsta(i).lt;
%     int(i) = max(nsta(i).int./int_sum(nsta(i).frame)');
end

% int = cellfun(@sum,{nsta.int})./[nsta.lt];
[~, tmpi] = sort(int.*double([nsta.class]~=4),'descend');
blob = false(1,length(nsta));
blob(tmpi(1:ceil(2*length(tmpi)/100))) = true;
% [hy,hx] = hist(int,1000);
% shy = zeros(1,length(hy));
% shy(1) = hy(1)/sum(hy);
% for i = 2:length(hy)
%     shy(i) = shy(i-1)+hy(i)/sum(hy);
% end
% int_lim = hx(find(shy-.99>eps,1));
%%
mpname = 'E:\MATLAB\Josh\ran_movies\Hela_movie\orig_movies\20151005_hela plaques cell 7_z2.tif';
if exist('tmp.tif','file'), delete('tmp.tif'); end
fprintf('Percent Complete: %3u%%',0);
for fr = 1:mov_sz(3)
%     img = zeros([mov_sz(1:2),3],'uint16');
    tmp = uint8(double(imread(mpname,'index',fr))/(2^8-1));
    img = uint8(cat(3,tmp,tmp,tmp));
    for i = 1:length(nsta)
        if ~blob(i), continue; end
        fr_ind = find(nsta(i).frame == fr);
        xpos = ceil(nsta(i).xpos(fr_ind));
        ypos = ceil(nsta(i).ypos(fr_ind));
        for xi = -1:1
            for yi = -1:1
                if abs(xi) == abs(yi)
                    img(ypos+yi,xpos+xi,1) = 255;
                    img(ypos+yi,xpos+xi,2) = 0;
                    img(ypos+yi,xpos+xi,3) = 0;
                end
            end
        end
    end
%     image(img)
%     pause
imwrite(img,['tmp\' num2str(fr) '.tif'])
fprintf('\b\b\b\b%3u%%',ceil(100*fr/mov_sz(3)));
end
fprintf('\b\b\b\b%3u%%\n',100);
% imagesc(img)
% axis equal
