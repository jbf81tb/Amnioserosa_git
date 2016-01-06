% for i = 1:length(nsta)
%     nsta(i).cell = cfs{i};
% end
%%
good_orig = false(length(nsta),size(Centers,3));
for i = 1:size(Centers,3);
    good_orig(:,i) = cellfun(@any,cellfun(@eq,{nsta.cell},repmat({i},[1 length(nsta)]),'uniformoutput',false));
end
%%
ml = max(cellfun(@max,{nsta.frame}));
gs = 1;%grid size
numC = size(Centers,3);
window = 2;
% vec = -0.15:.01:.15;
vec = -.06:.03:.06;
% vec = -.04:.02:.04;
% spf = cell(1,ml);
hy = cell(numC,ml);
num = zeros(numC,ml);
fprintf('Percent Complete: %3u%%',0);
good = cell(1,gs^2);
for cen = 1:gs^2
    cenx = mod(cen,gs)+(mod(cen,gs)==0)*gs;
    ceny = ceil(cen/gs);
    good{cen} = false(length(nsta),1);
    for i = 1:numC
        px = false; py = false;
        for il = 0:ogs-gs
            if grid_pos(i,1)==cenx+il, px = true; end
            if grid_pos(i,2)==ceny+il, py = true; end
            if px && py
                good{cen} = good{cen} | good_orig(:,i); 
                break; 
            end
        end
    end
    cond = good{cen}'&basal&~blob;
%     cond = blob;
    frames = {nsta(cond).frame};
    slopes = {nsta(cond).sl};
    for fr = 1:ml
        spf = [];
        for i = 1:length(frames);
            fr_ind = find(frames{i}==fr);
            if isempty(fr_ind), continue; end
            stfr = max(1,fr_ind-window);
            enfr = min(length(frames{i}),fr_ind+window);
            spf = [spf; slopes{i}(stfr:enfr)];
        end
        num(cen,fr) = length(spf);
        [hy{cen,fr}, x] = hist(nonzeros(spf),vec);
        hy{cen,fr} = hy{cen,fr}/sum(hy{cen,fr});
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*cen/gs^2));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
if exist('tmp.tif','file'), delete('tmp.tif'); end
% gs = 7; %grid size
% cmap = colormap('parula');
color = 'rkgbm';
% ah = tight_subplot(gs,gs,.005,[0 .02],.005);
for fr = 1:ml
    close
figure('position',[0 0 1 1])
ah = tight_subplot(gs,gs,.005,[0 .02],.005);
%     hold off
% sub = 0;
%     for cen = 1:size(Centers,3)
    for cen = 1:gs^2
        axes(ah(cen))
        axis off
%         cen = find(grid_pos==cen);
%         if isempty(cen), continue; end
%         axes(ah(grid_pos(cen)))
%         sub = sub+1;
%         if sub>25, continue; end
        if num(cen,fr)<100, continue; end
%         subplot(8,8,grid_pos(cen))
        for pi = 1:length(vec);
            px = x(pi)+.03*((1:fr)-1)/ml;
            py = zeros(1,fr);
            for pfri = 1:fr
                py(pfri) = hy{cen,pfri}(pi);
            end
%             plot(px,hy{cen,fr},'.','color',cmap(ceil(64*fr/ml),:))
          plot(px,py,color(pi))
%         plot(x,hy{cen,fr},'color',cmap(ceil(64*fr/ml),:))
            hold on
        end
        title(num2str(num(cen,fr)))
        ylim([0 .6]);
        xlim([-.06 .09])
        axis off
    end
%       title(num2str(num(fr)))
%     ylim([0 .5])
    axis off
    F = getframe(gcf);
    imwrite(F.cdata,'tmp.tif','writemode','append');
    pause(1/20)
end