F = @(A1,x01,s1,A2,x02,s2,x)(A1*exp(-(x-x01).^2/(2*s1^2))+A2*exp(-(x-x02).^2/(2*s2^2)));
ml = max(cellfun(@max,{nsta.frame}));
fit_returns_a = zeros(ml,4);
for fr = 1:ml
    xp = []; yp = []; zp = [];
    for i = 1:length(nsta)
        if ~any(nsta(i).frame==fr), continue; end
        fr_ind = abs(nsta(i).frame-fr)<=eps;
        xp = [xp; nsta(i).xpos(fr_ind)];
        yp = [yp; nsta(i).ypos(fr_ind)];
        zp = [zp; nsta(i).st(fr_ind)];
    end
    [hy,tmp] = histcounts(zp,1:1:21);
    hx = (tmp(1:end-1)+tmp(2:end))/2;
    f = fit(hx',hy',F,'startpoint',[max(hy), 4, 1, max(hy)/2, 10, 1]);
    tmpval = coeffvalues(f);
    fit_returns_a(fr,1) = tmpval(2);
    fit_returns_a(fr,2) = tmpval(3);
    fit_returns_a(fr,3) = tmpval(5);
    fit_returns_a(fr,4) = tmpval(6);
end
mid = round((fit_returns_a(:,1)+fit_returns_a(:,3))/2);
%%
close
figure
hold on
plot(squeeze(fit_returns_a(:,1)),'b')
plot(squeeze(fit_returns_a(:,1))+squeeze(fit_returns_a(:,2)),'b--')
plot(squeeze(fit_returns_a(:,1))-squeeze(fit_returns_a(:,2)),'b--')
plot(squeeze(fit_returns_a(:,3)),'r')
plot(squeeze(fit_returns_a(:,3))+squeeze(fit_returns_a(:,4)),'r--')
plot(squeeze(fit_returns_a(:,3))-squeeze(fit_returns_a(:,4)),'r--')
title('blue = apical | red = basal')
ylim([1,21])
%%
mov_nm = 'E:\Josh\Matlab\cmeAnalysis_movies\mb1_z0.4um_t1s002_good\orig_movies\Section_1_Stack_1.tif';
mov_sz = [size(imread(mov_nm)), length(imfinfo(mov_nm))];
sum_img = zeros(mov_sz);
for fr = 1:mov_sz(3)
    tmp = zeros([mov_sz(1:2) range(mid(fr))+1],'uint16');
    for i = mid(fr)'
        tmp(:,:,i) = imgaussfilt(imread([mov_nm(1:end-5) num2str(i+1) '.tif'],fr),5);
    end
    sum_img(:,:,fr) = sum(tmp,3);
end
%%
close
figure
cent_map = cell(1,mov_sz(3));
for fr = 1:mov_sz(3)
    testimg = sum_img(:,:,fr);
    testimg = max(testimg(:))-testimg;
    imagesc(testimg)
    [p, cent_map{fr}] = FastPeakFind(testimg,3000,fspecial('gaussian', 25,15),20);
    hold on
    scatter(p(1:2:end),p(2:2:end))
    pause(1/20)
end
%%
filename = 'centers_proj.tif';
mov_nm = 'E:\Josh\Matlab\cmeAnalysis_movies\mb1_z0.4um_t1s002_good\orig_movies\Section_1_Stack_1.tif';
if exist(filename,'file'), delete(filename); end
for fr = 1:length(imfinfo(mov_nm))
    frame_img = imread([mov_nm(1:end-5) num2str(mid(fr)+1) '.tif'],fr);
%     dots = uint16(conv2(cent_map{fr},ones(3),'same'));
    dots = uint16(cent_map{fr});
    tmp = frame_img - frame_img.*dots + intmax('uint16')*dots;
    imwrite(uint16(tmp),filename,'writemode','append')
end