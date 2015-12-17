movie = 'near';
mov = eval(movie);
moviefol = [movie '_movie'];
if exist(moviefol,'dir'), rmdir(moviefol,'s'); end
mkdir(moviefol);
ml = length(mov);
minsl = 0; maxsl = 0;
for i = 1:ml
    if max(mov{i}(:))>maxsl
        maxsl = max(mov{i}(:));
    end
    if min(mov{i}(:))<minsl
        minsl = min(mov{i}(:));
    end
end

for fr = 1:ml
    figure('units','normalized','outerposition',[0 0 1 1])
    axes('units','pixels','position',[100 100 370 386]);
    set(gca,'clim',[minsl maxsl])
    imagesc(mov{fr},'cdatamapping','scaled')
    axis off
    F = getframe(gcf,[99 99 370 386]);
    imwrite(F.cdata,fullfile(moviefol,[sprintf('%04u',fr) '.tif']));
    close
end