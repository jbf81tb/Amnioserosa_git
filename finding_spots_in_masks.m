maskd = dir('D:\Josh\Matlab\cmeAnalysis_movies\amnio_seams\movies\emb1_z0.4um_t3s_ant\max_projs\mask*');
mask = zeros([size(imread(['max_projs\' maskd(1).name])),length(maskd)]);
k = 1; 
fn = fieldnames(nsta);
fn(1:2:(2*end-1)) = fn;
fn(2:2:end+1) = cell(1,(length(fn)+1)/2);
tmpst = struct(fn{:});
for i = 1:length(maskd);
    mask(:,:,i) = imread(['max_projs\maskStack_' num2str(i) '.tif']);
    for j = 1:length(nsta)
        if abs(mean(nsta(j).st)-i)<.5
            if ~mask(round(mean(nsta(j).ypos)),round(mean(nsta(j).xpos)),i)
                tmpst(k) = nsta(j);
                k = k+1;
            end
        end
    end
end
%%
if exist('.\tmp.tif','file'), delete('tmp.tif'); end
ml = 11;
for mov = 1:length(maskd)
    sti = abs(cellfun(@mean,{tmpst.st})-mov)<.5;
    for fr = 1:ml
        hold off
        img = imread(['orig_movies\Stack_' num2str(mov) '.tif'],fr);
        imagesc(img);
        hold on
        xp = []; yp = [];
        for i = find(sti)
            frind = find(tmpst(i).frame==fr);
            if ~isempty(frind)
                xp(end+1) = tmpst(i).xpos(frind);
                yp(end+1) = tmpst(i).ypos(frind);
            end
        end
        scatter(xp,yp,100,'r')
        axis equal
        xlim([0 512])
        ylim([0 512])
        F = getframe(gca);
        imwrite(F.cdata,'tmp.tif','writemode','append')
    end
end
close