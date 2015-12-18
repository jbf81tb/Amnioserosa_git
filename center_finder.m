function center_finder(filename)
%Particle Tracker: Input filename, frames, and window size to get tracking.
%{
filname is the name of the tiff file (with extension) that you want to
analyze.
%}
%Predefine matrices. J is dynamic, IMG is static.
simg = size(imread(filename));
frames = length(imfinfo(filename));
IMG = zeros([simg,frames],'double');
scale = (2^16-1);
for j=1:frames
    IMG(:,:,j) = imread(filename,'Index',j);
end
J = uint16(IMG);

mn_img=mean(J.*uint16(J<(2^16-1)),3);

J = J.*uint16(J==scale);

%Predefine matrix containing binary information of pits.
BW = zeros([simg,frames]);

for k =1:frames
    BW(:,:,k) = imregionalmax(floor(J(:,:,k)), 8);
end
%Predefine matrices for tracking CCPs. BACK and INT have arbitrary
%predefinition (will usually be too small).
B_sample = bwboundaries(BW(:,:,2),'noholes');
X = zeros(length(B_sample),frames);
Y = zeros(length(B_sample),frames);
INT = zeros(length(B_sample),frames);

for k=1:frames
    B = bwboundaries(BW(:,:,k),'noholes');
    q=0;
    for m=1:length(B)
        c=cell2mat(B(m));
        q=q+1;
        X(q,k)=mean(c(:,2));
        Y(q,k)=mean(c(:,1));
        INT(q,k) = IMG(Y(q,k),X(q,k),k);
    end
end
X(X==0)=Inf;
Y(Y==0)=Inf;
Boy=size(X,1);
TraceX = zeros(Boy,frames);
TraceY = zeros(Boy,frames);
TraceINT = zeros(Boy,frames);

p = 0;    %trace number
dt = 4;   %distance threshold
ft = 5;   %frame threshold (needs statistical definition)
fprintf('Percent Complete: %3u%%',0);
for k=1:frames-1
    for m=1:Boy
        if isinf(X(m,k)), continue; end
        tracex=zeros(1,frames);
        tracey=zeros(1,frames);
        traceint=zeros(1,frames);
        check=zeros(1,frames,'uint16');
        dum_x = X(m,k);
        dum_y = Y(m,k);
        
        l = k;
        check(l) = m;
        while l <= frames - 1
            %create distance vector to find distance of all particles from
            %X(m,k), with the object of finding the closest
            dif=sqrt((dum_x-X(:,l+1)).^2+(dum_y-Y(:,l+1)).^2);
            if min(dif)>dt, l=l+1; continue; end %needs to be close enough
            check(l+1) = find(dif==min(dif),1);
            %now run it backwards to see if they are mutually closest
            check_dif=sqrt((X(check(l+1),l+1)-X(:,l)).^2+(Y(check(l+1),l+1)-Y(:,l)).^2);
            if find(check_dif==min(check_dif),1) == check(l)
                dum_x = X(check(l+1),l+1); dum_y = Y(check(l+1),l+1);
            else
                check(l+1) = 0;
            end
            % if by ft more frames we can't find anything close enough,
            % we give up
            if (l-k)>ft && sum(check(l-ft:l)) == 0
                break;
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
        if sum(diff(find(tracex))==1)>=ft-1
            p=p+1;
            TraceX(p,:)=tracex;
            TraceY(p,:)=tracey;
            TraceINT(p,:)=traceint;
        end
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*k/(frames-1)));
end
fprintf('\b\b\b\b%3u%%\n',100);
save([filename(1:end-4) '_Tr.mat'], 'TraceINT', 'TraceX', 'TraceY');

figure('units','pixels','outerposition',[50 50 1.2*simg]);
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
%     disp(box_pos);
    tmpx = any(TraceX>box_pos(1)&TraceX<(box_pos(1)+box_pos(3)),2);
    tmpy = any(TraceY>box_pos(2)&TraceY<(box_pos(2)+box_pos(4)),2);
    tmpi = tmpx&tmpy;
    
    tmpx = gap_filler(sum(TraceX(tmpi,:),1)./sum(TraceX(tmpi,:)>0,1));
    tmpy = gap_filler(sum(TraceY(tmpi,:),1)./sum(TraceY(tmpi,:)>0,1));
    scatter(tmpx,tmpy,10,'r','filled')
    if cent_count > 0
        scatter(Centers(:,1,cent_count),Centers(:,2,cent_count),15,'k','filled')
    end
    k = menu('Do you want to keep this?','Yes','No','Yes & Finished'); %in case of misclick
    if k==1 || k==3
        cent_count = cent_count+1;
        Centers(:,1,cent_count) = tmpx;
        Centers(:,2,cent_count) = tmpy;
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
