st = 4;
an_win = [st st+1];
omd = fullfile(pwd,'orig_movies');
omdt = dir(fullfile(omd,'*.mat'));
[~,ndt] = natsortfiles({omdt.name});
mat1 = fullfile(omd,omdt(ndt(an_win(1))).name);
mat2 = fullfile(omd,omdt(ndt(an_win(2))).name);
tif1 = [mat1(1:end-4) '.tif'];
tif2 = [mat2(1:end-4) '.tif'];

load(mat1);
st1 = fxyc_to_struct(Threshfxyc,'w4s');
load(mat2);
st2 = fxyc_to_struct(Threshfxyc,'w4s');
ml = max(max(cell2mat({st1.frame}')),max(cell2mat({st2.frame}')));
on = 'tmp.tif';
if exist(on,'file'), delete(on); end
close
figure('units','pixels','position',[1 1 1100 1100])
axes('units','pixels','position',[10 10 1024 1024])
for fr = 1:ml
    if mod(fr,100)==0
        close
        figure('units','pixels','position',[1 1 1100 1100])
        axes('units','pixels','position',[10 10 1024 1024])
    end
    
    img = imread(tif1,fr);
    imagesc(img);
    hold on
    colormap(gray);
    xp = []; yp = []; col = [];
    for i = 1:length(st1)
        if st1(i).lt<3, continue; end
        frind = find(st1(i).frame==fr);
        if isempty(frind), continue; end
        cls = st1(i).class;
        col(end+1,:) = [cls<=6&&cls~=4,...
                        0,...
                        (cls==4||cls==7||cls==8)];
        xp(end+1) = st1(i).xpos(frind);
        yp(end+1) = st1(i).ypos(frind);
    end
    scatter(xp,yp,40,col);
    axis equal
    axis off
    
    F = getframe(gca,[1 1 1024 1024]);
    imwrite(F.cdata,on,'tif','writemode','append')
    hold off
    
    img = imread(tif2,fr);
    imagesc(img);
    hold on
    colormap(gray);
    xp = []; yp = []; col = [];
    for i = 1:length(st2)
        if st2(i).lt<3, continue; end
        frind = find(st2(i).frame==fr);
        if isempty(frind), continue; end
        cls = st2(i).class;
        col(end+1,:) = [cls<=6&&cls~=4,...
                        0,...
                        (cls==4||cls==7||cls==8)];
        xp(end+1) = st2(i).xpos(frind);
        yp(end+1) = st2(i).ypos(frind);
    end
    scatter(xp,yp,40,col);
    axis equal
    axis off
    
    F = getframe(gca,[1 1 1024 1024]);
    imwrite(F.cdata,on,'tif','writemode','append')
    hold off
end
close