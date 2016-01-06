int_sum = cell(1,length(cnsta));
for sec = 1:length(cnsta)
int_sum{sec} = zeros(1,ml);
fprintf('Percent Complete: %3u%%',0);
for fr = 1:ml
    here = cellfun(@any,cellfun(@eq,{cnsta{sec}.frame},repmat({fr},[1 length(cnsta{sec})]),'uniformoutput',false));
    for j = 1:length(cnsta{sec})
        if ~here(j), continue; end
        fr_ind = cnsta{sec}(j).frame == fr;
        int_sum{sec}(fr) = int_sum{sec}(fr) + cnsta{sec}(j).int(fr_ind);
    end
    int_sum{sec}(fr) = int_sum{sec}(fr)/sum(here);
fprintf('\b\b\b\b%3u%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3u%%\n',100);
end
%%
int = cell(1,length(cnsta));
for sec = 1:length(cnsta)
int{sec} = zeros(1,length(cnsta{sec}));
for i = 1:length(cnsta{sec})
%     int(i) = sum(cnsta{sec}(i).int./int_sum{sec}(cnsta{sec}(i).frame)')/cnsta{sec}(i).lt;
    int{sec}(i) = max(cnsta{sec}(i).int./int_sum{sec}(cnsta{sec}(i).frame)');
end
end
%%
blob = cell(1,length(cnsta));
for sec = 1:length(cnsta)
% int = cellfun(@sum,{cnsta{sec}.int})./[cnsta{sec}.lt];
[~, tmpi] = sort(int{sec},'descend');
blob{sec} = false(1,length(cnsta{sec}));
blob{sec}(tmpi(1:ceil(end/100))) = true;
% [hy,hx] = hist(int,1000);
% shy = zeros(1,length(hy));
% shy(1) = hy(1)/sum(hy);
% for i = 2:length(hy)
%     shy(i) = shy(i-1)+hy(i)/sum(hy);
% end
% int_lim = hx(find(shy-.99>eps,1));
end
%%
mpname = 'E:\Josh\Matlab\cmeAnalysis_movies\emb2_z0.4um_t1s001_good\max_proj.tif';
if exist('tmp.tif','file'), delete('tmp.tif'); end
fprintf('Percent Complete: %3u%%',0);
for fr = 1:mov_sz(3)
%     img = zeros([mov_sz(1:2),3],'uint16');
    tmp = double(imread(mpname,'index',fr))/(2^16-1);
    img = cat(3,tmp,tmp,tmp);
    for i = 1:length(cnsta{sec})
        if ~blob{sec}(i), continue; end
        fr_ind = find(cnsta{sec}(i).frame == fr);
        xpos = ceil(cnsta{sec}(i).xpos(fr_ind));
        ypos = ceil(cnsta{sec}(i).ypos(fr_ind));
        for xi = 0%-1:1
            for yi = 0%-1:1
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
