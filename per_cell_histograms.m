for i = 1:length(nsta)
    nsta(i).cell = cfs{i};
end
%%
good = false(length(nsta),size(Centers,1));
for i = 1:size(Centers,1);
    good(:,i) = cellfun(@any,cellfun(@eq,{nsta.cell},repmat({i},[1 length(nsta)]),'uniformoutput',false));
end
%%
numC = size(Centers,3);
window = 2;
% vec = -0.15:.01:.15;
vec = -.06:.03:.06;
% spf = cell(1,ml);
hy = cell(numC,ml);
num = zeros(numC,ml);
fprintf('Percent Complete: %3u%%',0);
for cen = 1:numC
    frames = {nsta(good(:,cen)&basal'&~blob').frame};
    slopes = {nsta(good(:,cen)&basal'&~blob').sl};
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
    fprintf('\b\b\b\b%3u%%',ceil(100*cen/numC));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
if exist('tmp.tif','file'), delete('tmp.tif'); end

cmap = colormap('parula');
color = 'rkgbm';
ah = tight_subplot(8,8,.01,.01,.01);
for fr = 1:ml
    close
figure('position',[0 0 4 4])
ah = tight_subplot(8,8,.01,.01,.01);
%     hold off
% sub = 0;
%     for cen = 1:size(Centers,3)
    for axi = 1:64
        axes(ah(axi))
        axis off
        cen = find(grid_pos==axi);
        if isempty(cen), continue; end
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
        title(num2str(cen))
        ylim([0 .4]);
        xlim([-.1 .1])
        axis off
    end
    %   title(num2str(num(fr)))
%     ylim([0 .4])
%     axis off
    F = getframe(gcf);
    imwrite(F.cdata,'tmp.tif','writemode','append');
    pause(1/20)
end