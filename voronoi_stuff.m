if exist('tmp.tif','file'), delete('tmp.tif'), end
% sames = false(1,size(Centers,2));

V = cell(1,size(Centers,1));
C = cell(1,size(Centers,1));
for i = 1:size(Centers,1)
%     for st = 1:22
        close
        figure('units','pixels','position',[100 100 700 700])
        axes('units','pixels','position',[10 10 512 512])
%         img = imread('emb1_z0.4um_t1s002_good.tif',(i-1)*22+st);
        cent_img = imread('centers_proj.tif',i);
        imagesc(cent_img.*uint16(cent_img<intmax('uint16')));
        colormap('gray')
%         imagesc(uint16(nathan_apical{i}/maxsl*(2^16-1)))
        hold on
%         scatter(squeeze(Centers(:,i,1)),squeeze(Centers(:,i,2)),'.r')
        [V{i},C{i}] = voronoin([squeeze(Centers(i,1,:)),squeeze(Centers(i,2,:))]);
        %     V{i}(1,:) = [512,512];
        for j = 1:length(C{i})
            %   C{i}{j}(C{i}{j}==1) = [];
            C{i}{j}(end+1) = C{i}{j}(1);
            plot(V{i}(C{i}{j},1),V{i}(C{i}{j},2),'r');
        end
        plot(tb(:,1),tb(:,2),'r');
        text_cell = arrayfun(@num2str,1:size(Centers,3),'uniformoutput',false);
        text(squeeze(Centers(i,1,:)),squeeze(Centers(i,2,:)),text_cell,'color','w','FontSize',14);
        % v = V{i}; c = C{i};
        % q = pdist([v(:,1),v(:,2);squeeze(Centers(:,i,1)),squeeze(Centers(:,i,2))]);
        % w = squareform(q);
        % e = w(length(v)+1:end,1:length(v));
        % whichcell = zeros(1,length(c));
        % for j = 1:length(c)
        % tmp = zeros(size(e,1),length(c{j})-1);
        % for k = 1:length(c{j})-1
        %     tmp(:,k) = e(:,c{j}(k));
        % end
        % tmp = mean(tmp,2);
        % [~,whichcell(j)] = min(tmp);
        % end
        % sames(i) = all(whichcell==find(whichcell));
        axis off
        F = getframe(gca,[0 0 512 512]);
        imwrite(F.cdata,'tmp.tif','writemode','append')
        %     pause(1/30)
%     end
end
close