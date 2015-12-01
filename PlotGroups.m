function PlotGroups(movie,Cfxyswn)
if exist('tmp','dir'), rmdir('tmp','s'); end
mkdir('tmp');
% delete(newfile);
frames=length(imfinfo(movie));
[ymax,xmax]=size(imread(movie,'Index',1));
% M=max(max(imread(movie)));
isframe = cell(1,frames);
for fr = 1:frames
    for i = 1:length(Cfxyswn)
        if sum(Cfxyswn{i}(:,1) == fr)
            isframe{fr} = [isframe{fr} i];
        end
    end
end
% centers = cell(frames,1);
fprintf('  0%%');
for i=1:frames
figure('units','normalized','outerposition',[.1 .1 .8 .8]);
axes('units','pixels','position',[10 10 xmax ymax]);
    A=imread(movie,'Index',i);
    imagesc(A);
%     image(zeros(ymax,xmax))
    hold on;
    for i2=isframe{i}
        ind = find(Cfxyswn{i2}==i,1);
        x=ceil(Cfxyswn{i2}(ind,2));
        y=ceil(Cfxyswn{i2}(ind,3));
        W=ceil(Cfxyswn{i2}(ind,5));
        rectangle('Position',[x-W y-W 2*W 2*W], 'Curvature', 1,'EdgeColor',[1 0 0]);%,'FaceColor',[1 1 1])
        text(x+W,y+W,num2str(i2),'Color','w');
    end
    xlim([1 xmax]);
    ylim([1 ymax]);
    colormap('gray');
    axis off
    axis equal
    F = getframe(gca,[10 10 xmax ymax]);
%     pause;
%     centers{i} = rgb2gray(F.cdata);
%     centers{i} = centers{i}==255;
    imwrite(F.cdata,fullfile('tmp',sprintf('%04i.tif',i)));
    fprintf('\b\b\b\b%3u%%',ceil(100*i/frames));
    close;
end
fprintf('\b\b\b\b%3u%%\n',100);
%     save centers.mat centers
end