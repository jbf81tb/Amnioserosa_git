st = osta;
% window = [76,260;260,436;436,684;684,925;925,1107;1107,1277]-75;
ml = max(cellfun(@max,{st.frame}));
ymax = ceil(max(cellfun(@max,{st.ypos})));
xmax = ceil(max(cellfun(@max,{st.xpos})));
nt = length(st);
% imsec = length(window);
img = zeros(ymax,xmax,ml,'uint16');
slopes = cell(ymax,xmax);
lts = cell(ymax,xmax);
fprintf('Percent Complete: %3u%%',0);
for i = 1:nt
timg = zeros(ymax,xmax,'uint16');
% timg2 = zeros(ymax,xmax);
    for fr = 1:length(st(i).frame)
        y = ceil(st(i).ypos(fr));
        x = ceil(st(i).xpos(fr));
        timg(y,x) = 1;
%         timg2(y,x) = timg2(y,x) + 1;
%         slopes{y,x}(end+1) = st(i).sl(fr);
%         slopes{y,x} = nonzeros(slopes{y,x});
    end
    fr = mean(st(i).frame);
%     sec = find(fr>=window(:,1)&fr<window(:,2));
    img(:,:,ceil(fr)) = img(:,:,ceil(fr))+timg;
%     if st(i).class~=3, continue; end
%     [~,I] = max(timg2(:));
%     [r,c] = ind2sub(size(timg2),I);
%     lts{r,c}(end+1) = st(i).lt;
fprintf('\b\b\b\b%3u%%',ceil(100*i/nt));
end
fprintf('\b\b\b\b%3u%%\n',100);
%%
B = zeros(ymax,xmax,ml-200);
for i = 101:ml-100
% sd = 10;
% B(:,:,i) = imgaussfilt(img(:,:,i),sd);
B(:,:,i-100) = imfilter(sum(img(:,:,i-100:i+100),3),fspecial('disk',10));
end
%%
if exist('tmp','dir'), rmdir('tmp','s'); end
mkdir('tmp');
prom = .5; wid = 80;
pks = zeros(size(B),'uint16');
close
figure
axes('units','pixels','position',[100 100 ymax xmax]);
for k = 1:size(B,3)
totes = B(:,:,k);
[~,locs] = findpeaks(totes(:),'minpeakprominence',prom,'minpeakdistance',wid);
pks1 = zeros(size(totes),'uint16');
r1 = zeros(1,length(locs));
c1 = zeros(1,length(locs));
for i = 1:length(locs)
    [r1(i),c1(i)] = ind2sub(size(totes),locs(i));
    pks1(r1(i),c1(i)) = 1;
end
totes = totes';
[~,locs] = findpeaks(totes(:),'minpeakprominence',prom,'minpeakdistance',wid);
pks2 = zeros(size(totes'),'uint16');
r2 = zeros(1,length(locs));
c2 = zeros(1,length(locs));
for i = 1:length(locs)
    [r2(i),c2(i)] = ind2sub(size(totes),locs(i));
    pks2(c2(i),r2(i)) = 1;
end
pks(:,:,k) = pks1+pks2;

% subplot(1,2,1)
totes = totes';
imagesc(totes)
hold on
plot(c1,r1,'kx')
plot(r2,c2,'kx')
axis off
% F = getframe(gcf,[99 99 ymax xmax]);
% imwrite(F.cdata,fullfile('tmp',sprintf('%04u.tif',k)),'tif')
pause(1/30)
% % close
% % figure
% subplot(1,2,2)
% tmp = totes.*pks1+totes.*pks2;
% tmp = conv2(tmp,fspecial('disk',3),'same');
% % tmp = imgaussfilt(tmp,10);
% [~,L,N] = bwboundaries(tmp);
% la = zeros(1,N);
% for j = 1:N
% la(j) = bwarea(L==j);
% end
% la = sort(la,'descend');
% imagesc(bwareaopen(tmp>0,round(la(10))));
% pause
end
close
%%
close
figure
tmp = totes.*pks1+totes.*pks2;
tmp = conv2(tmp,[0 1 0;1 1 1;0 1 0]/5,'same');
imagesc(bwareaopen(tmp>0,250));