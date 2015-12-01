if exist('movie','dir'), rmdir('movie','s'); end
mkdir('movie')
movie = 'apical1.tif';
% sec = 1; st = 2;
ml = length(imfinfo(movie));
str = anapst;
str2 = fxyc_struct;
if ~isempty(str2)
    frame2 = {str2.frame};
    x2 = {str2.xpos};
    y2 = {str2.ypos};
end
frame = {str.frame};
x = {str.xpos};
y = {str.ypos};
lvls = {str.st};
c = 'rgy';
for fr = 1:ml
    figure('units','normalized','outerposition',[0 0 1 1]);
    img = imread(movie,fr);
    imagesc(img);
    hold on
    for i = 1:length(frame)
        ind = find(frame{i}==fr);
        if isempty(ind), continue; end
        line(x{i}(ind),y{i}(ind),'Marker','o','MarkerEdgeColor',c(lvls{i}(ind)),'MarkerSize',14);
    end
    if ~isempty(frame2)
        for i = 1:length(frame2)
            ind2 = find(frame2{i}==fr);
            if isempty(ind2), continue; end
            line(x2{i}(ind2),y2{i}(ind2),'Marker','s','MarkerEdgeColor','k','MarkerSize',14);
        end
    end
    axis off
    F = getframe(gca);
    imwrite(F.cdata,fullfile('movie',sprintf('%04i.tif',fr)));
    close;
end