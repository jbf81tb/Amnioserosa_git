% moviename = 'tmp_sl.tif';
% delete(moviename)
moviefol = 'slmovie';
if exist(moviefol,'dir'), rmdir(moviefol,'s'); end
mkdir(moviefol);
%
r = 100;
msk = fspecial('gaussian',[r r],r/5);
% msk = msk/msk(ceil((r+1)/2),ceil((r+1)/2))/(r/20);
figure('units','normalized','outerposition',[0 0 1 1])
% axes
% maxcol = maxsl;
% set(gca,'clim',[0 maxcol])
for fr = 1:100
    mdsl = median(pos_sl{fr}(pos_sl{fr}>0));
    preimg = pos_sl{fr};
    preimg(preimg>0) = 2*mdsl-preimg(preimg>0);
    img = conv2(preimg,msk,'same');
    dens_img = conv2(dens_map{fr},msk,'same');
%     subplot(1,2,1)
    imagesc(img./dens_img)%,'cdatamapping','scaled')
    colorbar
% imagesc(img)
    axis off
%     subplot(1,2,2)
%     imagesc(conv2(lt_map{fr},msk))
%     imagesc(DVSMap{fr,3})
    F = getframe(gcf);
    imwrite(F.cdata,fullfile(moviefol,[sprintf('%03i',fr) '.tif']));
end
close