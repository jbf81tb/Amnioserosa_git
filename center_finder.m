function center_finder(filename, varargin)
%Particle Tracker: Input filename, frames, and window size to get tracking.
%{
filname is the name of the tiff file (with extension) that you want to
analyze.
%}
windowsize = 7;
mask = ones(windowsize);
bigwindowsize = windowsize+4;
%Predefine matrices. J is dynamic, IMG is static.
ss = imread(filename);
s = size(ss);
frames = length(imfinfo(filename));
IMG = zeros(s(1),s(2),frames,'double');
scale = (2^16-1);
for j=1:frames
    IMG(:,:,j) = imread(filename,'Index',j);
end
J = uint16(IMG);

mn_img=mean(J.*uint16(J<(2^16-1)),3);

J = J.*double(J==scale);
    
%Predefine matrix containing binary information of pits.
BW = zeros(s(1),s(2),frames);

for k =1:frames
    BW(:,:,k) = imregionalmax(floor(J(:,:,k)), 8);
end
%Predefine matrices for tracking CCPs. BACK and INT have arbitrary
%predefinition (will usually be too small).
B_sample = bwboundaries(BW(:,:,2),'noholes');
INT = zeros(length(B_sample),frames);

for k=1:frames
    B = bwboundaries(BW(:,:,k),'noholes');
    q=0;
    for m=1:length(B)
        c=cell2mat(B(m));
        q=q+1;
        X(q,k)=mean(c(:,1));
        Y(q,k)=mean(c(:,2));
    end
end

[Boy,~]=size(X);
for j = 1:frames
    for i = 1:Boy
        if X(i,j) == 0, X(i,j) = Inf; end
        if Y(i,j) == 0, Y(i,j) = Inf; end
    end
end
TraceX = zeros(Boy,frames);
TraceY = zeros(Boy,frames);
TraceINT = zeros(Boy,frames);
Diffs = zeros(Boy,Boy,frames-1);

p = 0;    %trace number
dt = 4;   %distance threshold
ft = 5;   %frame threshold (needs statistical definition)

for k=1:frames-1
    for m=1:Boy
        if (X(m,k)>0 && X(m,k)<s(2))
            tracex=zeros(1,frames);
            tracey=zeros(1,frames);
            traceint=zeros(1,frames);
            
            dif=Inf([1,Boy]);
            check_dif=Inf([1,Boy]);
            check=zeros([1,frames],'uint16');
            dum_x = X(m,k);
            dum_y = Y(m,k);
            
            l = k;
            check(l) = m;
            while l <= frames - 1
                %create distance vector to find distance of all particles from
                %X(m,k), with the object of finding the closest
                for n=1:Boy
                    dif(n)=sqrt((dum_x-X(n,l+1))^2+(dum_y-Y(n,l+1))^2);
                end
                Diffs(m,:,k) = dif;
                if min(dif) == 0, l = l+1; continue; end
                if size(find(dif==min(dif)),2) ~=1, l = l+1; continue; end
                check(l+1) = find(dif==min(dif));
                for n=1:Boy
                    check_dif(n)=sqrt((X(check(l+1),l+1)-X(n,l))^2+(Y(check(l+1),l+1)-Y(n,l))^2);
                end
                
                if (find(check_dif==min(check_dif)) ~= check(l) | dif(check(l+1))>dt) %#ok<OR2>
                    check(l+1) = 0;
                else
                    dum_x = X(check(l+1),l+1); dum_y = Y(check(l+1),l+1);
                end
                if (l-k)>ft
                    %sets a frame threshold, where if we recieve no
                    %signal from this area, constrained by the distance
                    %threshold, for ft frames then it could just be a
                    %new particle taking its place in the same region
                    if sum(check(l-ft:l)) == 0, break, end
                end
                l = l+1;
            end
            
            
            
            %Load temporary trace vectors with x, y, and intensity data.
            for l=k:frames
                if check(l) ~= 0;
                    tracex(l)=X(check(l),l);
                    tracey(l)=Y(check(l),l);
                    traceint(l)=INT(check(l),l);
                    %Now that these points have appeared in a trace we
                    %have to make sure they no longer appear in any
                    %further traces, so we set them to infinity.
                    X(check(l),l)=Inf;
                    Y(check(l),l)=Inf;
                end
            end
            
            %Loading a more permanent trace vector, filtering out traces which
            %are too short and that aren't made of consecutive points, also
            %creating a new numbering system.
            pos = [find(tracex) 0];
            num=numel(pos);
            if num>ft
                son=zeros(1,num);
                son(2:num)=pos(1:num-1);
                fark=pos-son;
                if numel(find(fark==1))>=ft
                    p=p+1;
                    TraceX(p,:)=tracex;
                    TraceY(p,:)=tracey;
                    TraceINT(p,:)=traceint;
                end
            end
        end
    end
end
save([filename(1:end-4) '_Tr.mat'], 'TraceINT', 'TraceX', 'TraceY');

figure('units','pixels','outerposition',[50 50 1.2*s]);
axes('units','pixels','position',[1 0 size(mn_img)])
imshow(-mn_img,[]);
axis xy
hold on;
colors='bgycm';
for i=1:size(TraceX,1)
    j=5-mod(i,5);
    plot(TraceX(i,TraceX(i,:)>0), TraceY(i,TraceX(i,:)>0), colors(j), 'linewidth', 2);
end

cent_count = 0;
k = 1;
while k ~= 3
    while(k~=0) %k=0 when mouse is clicked
        k=waitforbuttonpress;
        box_pos = rbbox;
    end
    disp(box_pos);
    tmpx = any(TraceX>box_pos(1)&TraceX<(box_pos(1)+box_pos(3)),2);
    tmpy = any(TraceY>box_pos(2)&TraceY<(box_pos(2)+box_pos(4)),2);
    tmpi = tmpx&tmpy;
    
    tmpx = gap_filler(sum(TraceX(tmpi,:))./sum(TraceX(tmpi,:)>0));
    tmpy = gap_filler(sum(TraceY(tmpi,:))./sum(TraceY(tmpi,:)>0));
    scatter(tmpx,tmpy,10,'r','filled')
    for i = 1:cent_count
        scatter(Centers(i,:,1),Centers(i,:,2),15,'k','filled')
    end
    k = menu('Do you want to keep this?','Yes','No','Yes & Finished'); %in case of misclick
    if k==1 || k==3
        cent_count = cent_count+1;
        Centers(cent_count,:,1) = tmpx;
        Centers(cent_count,:,2) = tmpy;
    end
end
close
save centers.mat Centers;
end

function vec = gap_filler(vec)
bads = isnan(vec);
if ~any(bads), return; end
fg = find(~bads,1,'first');
lg = find(~bads,1,'last');
vec(1:fg-1) = vec(fg);
vec(lg+1:end) = vec(lg);
i = fg;
while i <= lg
    if ~bads(i), i = i+1; continue; end
    start = vec(i-1);
    span = 0;
    j = i;
    while bads(j)
        span = span+1;
        j = j+1;
    end
    fin = vec(j);
    vec(i:j-1) = start + (1:span)*(fin-start)/span;
    i = j;
end
end

function [Window, BigWindow] = make_windows(Px,Py,windowsize,s,IMG)
bigwindowsize = windowsize + 4;
Window = 0; BigWindow = 0;

if (Px-(bigwindowsize+1)/2)<1 && (Py-(bigwindowsize+1)/2)<1
    for i=1:(windowsize-1)/2-Py
        for j=1:(windowsize-1)/2-Px
            Window(i,j)=IMG(i,j);
        end
    end
    
    for i=1:(bigwindowsize-1)/2-Py
        for j=1:(bigwindowsize-1)/2-Px
            BigWindow(i,j)=IMG(i,j);
        end
    end
    
elseif (Px-(bigwindowsize+1)/2)<1 && (Py+(bigwindowsize+1)/2)>s(1)
    for i=(Py-(windowsize-1)/2):s(1)
        for j=1:(windowsize-1)/2-Px
            Window(i+1-(Py-(windowsize-1)/2),j)=IMG(i,j);
        end
    end
    
    for i=(Py-(bigwindowsize-1)/2):s(1)
        for j=1:(bigwindowsize-1)/2-Px
            BigWindow(i+1-(Py-(bigwindowsize-1)/2),j)=IMG(i,j);
        end
    end
    
    
    
elseif (Px+(bigwindowsize+1)/2)>s(2) && (Py-(bigwindowsize+1)/2)<1
    for i=1:(windowsize-1)/2-Py
        for j=(Px-(windowsize-1)/2):s(2)
            Window(i,j+1-(Px-(windowsize-1)/2))=IMG(i,j);
        end
    end
    
    for i=1:(bigwindowsize-1)/2-Py
        for j=(Px-(bigwindowsize-1)/2):s(2)
            BigWindow(i,j+1-(Px-(bigwindowsize-1)/2))=IMG(i,j);
        end
    end
    
elseif (Px+(bigwindowsize+1)/2)>s(2) && (Py+(bigwindowsize+1)/2)>s(1)
    for i=(Py-(windowsize-1)/2):s(1)
        for j=(Px-(windowsize-1)/2):s(2)
            Window(i+1-(Py-(windowsize-1)/2),j+1-(Px-(windowsize-1)/2))=IMG(i,j);
        end
    end
    
    for i=(Py-(bigwindowsize-1)/2):s(1)
        for j=(Px-(bigwindowsize-1)/2):s(2)
            BigWindow(i+1-(Py-(bigwindowsize-1)/2),j+1-(Px-(bigwindowsize-1)/2))=IMG(i,j);
        end
    end
    
elseif (Px-(bigwindowsize+1)/2)<1 && (Py-(bigwindowsize+1)/2)>=1 && (Py+(bigwindowsize+1)/2)<=s(1)
    for i=1:windowsize
        for j=1:(windowsize-1)/2-Px
            Window(i,j)=IMG(Py-(windowsize+1)/2+i,j);
        end
    end
    
    for i=1:bigwindowsize
        for j=1:(bigwindowsize-1)/2-Px
            BigWindow(i,j)=IMG(Py-(bigwindowsize+1)/2+i,j);
        end
    end
    
elseif (Px+(bigwindowsize+1)/2)>s(2) && (Py-(bigwindowsize+1)/2)>=1 && (Py+(bigwindowsize+1)/2)<=s(1)
    for i=1:windowsize
        for j=(Px-(windowsize-1)/2):s(2)
            Window(i,j+1-(Px-(windowsize-1)/2))=IMG(Py-(windowsize+1)/2+i,j);
        end
    end
    
    for i=1:bigwindowsize
        for j=(Px-(bigwindowsize-1)/2):s(2)
            BigWindow(i,j+1-(Px-(bigwindowsize-1)/2))=IMG(Py-(bigwindowsize+1)/2+i,j);
        end
    end
    
elseif (Py-(bigwindowsize+1)/2)<1 && (Px-(bigwindowsize+1)/2)>=1 && (Px+(bigwindowsize+1)/2)<=s(2)
    for i=1:(windowsize-1)/2-Py
        for j=1:windowsize
            Window(i,j)=IMG(i,Px-(windowsize+1)/2+j);
        end
    end
    
    for i=1:(bigwindowsize-1)/2-Py
        for j=1:bigwindowsize
            BigWindow(i,j)=IMG(i,Px-(bigwindowsize+1)/2+j);
        end
    end
    
elseif (Py+(bigwindowsize+1)/2)>s(1) && (Px-(bigwindowsize+1)/2)>=1 && (Px+(bigwindowsize+1)/2)<=s(2)
    for i=(Py-(windowsize-1)/2):s(1)
        for j=1:windowsize
            Window(i+1-(Py-(windowsize-1)/2),j)=IMG(i,Px-(windowsize+1)/2+j);
        end
    end
    
    for i=(Py-(bigwindowsize-1)/2):s(1)
        for j=1:bigwindowsize
            BigWindow(i+1-(Py-(bigwindowsize-1)/2),j)=IMG(i,Px-(bigwindowsize+1)/2+j);
        end
    end
end
end