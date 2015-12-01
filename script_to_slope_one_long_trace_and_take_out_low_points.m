lh = length(hs);
abthresh = 12500;
c1 = hs<abthresh;
c2 = 2*(hs<2*abthresh);
c3 = c2+c1;
for i = 1:length(hs)
    left = 0; right = 0;
    if c3(i)==2
        j=i;
        while j>1 && c3(j)==2
            j = j-1;
            left = c3(j);
        end
        j=i;
        while j<length(hs) && c3(j)==2
            j = j+1;
            right = c3(j);
        end
    end
    if left==3 && right==3
        c3(i) = 3;
    elseif left==2 || right==2
        c3(i) = 0;
    end
end
c3=double(c3==3);
for i = 2:length(hs)-1
    left = 0; right = 0;
    if c3(i)
        left = c3(i-1);
        right = c3(i+1);
    end
    if (left==1 && right==0) || (left==0 && right==1)
        c3(i) = 2;
    end
end
c3(c3==2)=false;
c3 = logical(c3);
plot(1:lh,hs,find(c3),hs(c3),'o')
%%
frame_rate = 3; bkgrd = 12500;
prange = 12/frame_rate;
forwardp = .5;
front = floor(forwardp*(prange));
rear = ceil((1-forwardp)*(prange));
int = hs;
int(c3)=NaN;
lint = length(int);
intdif = NaN(lint,1);
for j = (rear+1):lint-front-1
    sub = (max(1,j-rear):min(lint,(j+front)));
    curmax = max(int)-bkgrd; %%%%%%%%%%%%%%% check
    tmp = (int(sub)-bkgrd)/curmax;
    tmpx = sub*frame_rate;
    tmpy = tmp';
    nume = length(tmpx)*sum(tmpx.*tmpy)-sum(tmpx)*sum(tmpy);
    denom = length(tmpx)*sum(tmpx.^2)-sum(tmpx)^2;
    intdif(j) = nume/denom;
end