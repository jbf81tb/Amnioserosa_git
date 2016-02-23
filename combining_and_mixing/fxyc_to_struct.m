function fxyc_struct = fxyc_to_struct(fxyc,varargin)
%FXYC_TO_STRUCT Converts Threshfxyc to a structure.
%   also does gap filling and removes empty traces
if nargin==1
    no4s=true;
elseif nargin==2
    if ischar(varargin{1})
        if strcmpi(varargin{1},'no4s')
            no4s = true;
        elseif strcmpi(varargin{1},'w4s')
            no4s = false;
        end
    elseif islogical(varargin{1})
        no4s = varargin{1};
    else
        no4s=true;
        fprintf('Invalid input. Proceeding with removal of 4''s');
    end
end
fxyc_struct = struct('frame',[],'xpos',[],'ypos',[],'class',[],'int',[]);
if isempty(fxyc), return; end
i = 0;
for j = 1:size(fxyc,3)
    during = squeeze(fxyc(:,1,j)>0);
    if isempty(during), continue; end
    if no4s && fxyc(1,4,j)==4,continue; end
    i = i+1;
    fxyc_struct(i).frame = fxyc(during,1,j);
    fxyc_struct(i).xpos = fxyc(during,2,j);
    fxyc_struct(i).ypos = fxyc(during,3,j);
    fxyc_struct(i).class = fxyc(1,4,j);
    fxyc_struct(i).int = fxyc(during,5,j);
    if any(fxyc_struct(i).int==0)
        fixed = fxyc_struct(i).int~=0;
        fxyc_struct(i).frame = fxyc_struct(i).frame(fixed);
        fxyc_struct(i).xpos = fxyc_struct(i).xpos(fixed);
        fxyc_struct(i).ypos = fxyc_struct(i).ypos(fixed);
        fxyc_struct(i).int = fxyc_struct(i).int(fixed);
    end
    if isempty(fxyc_struct(i).frame)
        fxyc_struct(i) = [];
        i = i-1;
        continue;
    end
    fxyc_struct(i).lt = fxyc_struct(i).frame(end)-fxyc_struct(i).frame(1)+1;
    if fxyc_struct(i).lt == length(fxyc_struct(i).frame), continue; end
    gf_frame = zeros(fxyc_struct(i).lt,1);
    gf_int = zeros(fxyc_struct(i).lt,1);
    gf_xpos = zeros(fxyc_struct(i).lt,1);
    gf_ypos = zeros(fxyc_struct(i).lt,1);
    fo = fxyc_struct(i).frame-fxyc_struct(i).frame(1)+1;
    m = 1;
    for k = 1:length(fxyc_struct(i).frame)-1
        for count = 0:(fo(k+1)-fo(k)-1)
            gf_frame(m) =fxyc_struct(i).frame(k)+count;
            gf_int(m) = fxyc_struct(i).int(k) + ...
                (fxyc_struct(i).int(k+1)-fxyc_struct(i).int(k))...
                *(count)/(fo(k+1)-fo(k));
            gf_xpos(m) = fxyc_struct(i).xpos(k) + ...
                (fxyc_struct(i).xpos(k+1)-fxyc_struct(i).xpos(k))...
                *(count)/(fo(k+1)-fo(k));
            gf_ypos(m) = fxyc_struct(i).ypos(k) + ...
                (fxyc_struct(i).ypos(k+1)-fxyc_struct(i).ypos(k))...
                *(count)/(fo(k+1)-fo(k));
            m = m+1;
        end
        if m == length(gf_frame)
            gf_frame(m) =fxyc_struct(i).frame(end);
            gf_int(m) = fxyc_struct(i).int(end);
            gf_xpos(m) = fxyc_struct(i).xpos(end);
            gf_ypos(m) = fxyc_struct(i).ypos(end);
        end
    end
    fxyc_struct(i).frame = gf_frame;
    fxyc_struct(i).xpos = gf_xpos;
    fxyc_struct(i).ypos = gf_ypos;
    fxyc_struct(i).int = gf_int;
end
end