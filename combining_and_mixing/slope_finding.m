function fxyc_struct = slope_finding(fxyc_struct,frame_rate,bkgrd)
ints = {fxyc_struct.int};
prange = 12/frame_rate;
forwardp = .5;
front = floor(forwardp*(prange-1));
rear = ceil((1-forwardp)*(prange-1));
% fprintf('Percent Complete: %3i%%',0);
% mess_up = false;
% if frame_rate == 2, frame_rate = 4; mess_up = true; end
for i = 1:length(ints)
    int = ints{i};
%     if mess_up, int = int(1:2:end); end
    lint = length(int);
    intdif = zeros(lint,1);
    if lint<=prange
        fxyc_struct(i).sl = intdif;
        continue;
    end
    for j = (rear+1):lint
        sub = (max(1,j-rear):min(lint,(j+front)));
        curmax = max(int)-bkgrd; %%%%%%%%%%%%%%% check
        tmp = (int(sub)-bkgrd)/curmax;
        tmpx = sub*frame_rate;
        tmpy = tmp';
        nume = length(tmpx)*sum(tmpx.*tmpy)-sum(tmpx)*sum(tmpy);
        denom = length(tmpx)*sum(tmpx.^2)-sum(tmpx)^2;
        intdif(j) = nume/denom;
    end
    fxyc_struct(i).sl = intdif;
%     fprintf('\b\b\b\b%3i%%',ceil(100*i/length(ints)));
end
% fprintf('\b\b\b\b%3i%%\n',100);
end