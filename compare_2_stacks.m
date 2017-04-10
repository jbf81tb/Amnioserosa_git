an_win = 3:4;
omd = fullfile(pwd,'orig_movies');
omdt = dir(fullfile(omd,'*.tif'));
[~,ndt] = natsortfiles({omdt.name});
mp_filename = 'proj.tif';
if exist(mp_filename,'file'), delete(mp_filename); end

ml = max(cellfun(@max,{nsta.frame}));
for fr = 1:ml
    if fr == 1
        mov_sz = size(imread(fullfile(omd,omdt(1).name)));
    end
    tmp = zeros([mov_sz length(an_win)],'uint16');
    for zi = an_win
        tmp(:,:,zi) = imread(fullfile(omd,omdt(ndt(zi+1)).name),fr);
    end
    img = max(tmp,[],3);
    imwrite(img,mp_filename,'tif','writemode','append')
end

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
    img = imread(mp_filename,fr);
    imagesc(img);
    hold on
    colormap(gray);
    xp = []; yp = []; col = [];
    for i = 1:length(nsta)
        if nsta(i).lt<3, continue; end
        frind = find(nsta(i).frame==fr);
        if isempty(frind), continue; end
        zst = nsta(i).st(frind);
        if zst<an_win(1) || zst>an_win(end), continue; end
        col(end+1,:) = [an_win(2)-zst,...
                        zst-an_win(1),...
                        (nsta(i).class==4||nsta(i).class==7)];
        xp(end+1) = nsta(i).xpos(frind);
        yp(end+1) = nsta(i).ypos(frind);
    end
    scatter(xp,yp,40,col);
    axis equal
    axis off
    F = getframe(gca,[1 1 1024 1024]);
    imwrite(F.cdata,on,'tif','writemode','append')
    hold off
end
close