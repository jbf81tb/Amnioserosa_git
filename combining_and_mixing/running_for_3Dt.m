function nsta = running_for_3Dt(exp_name,framegap,thresh,varargin)
if nargin==4
    redo = true;
else
    redo = false;
end

md = fullfile(exp_name,'movies');
mdir = dir(fullfile(md,'*.tif'));
[~,ndx] = natsortfiles({mdir.name});
nm = length(mdir);
cnsta = cell(nm,1);
if isscalar(framegap)
    framegap = framegap*ones(nm,1);
end
if isscalar(thresh)
    thresh = thresh*ones(nm,1);
end
if exist([exp_name filesep 'nsta.mat'],'file')
    load([exp_name filesep 'nsta.mat']);
    start = sum(~cellfun(@isempty,cnsta)) + 1;
else
    start = 1;
end
for mov = start:nm
    mov_fol = fullfile(md,mdir(ndx(mov)).name(1:end-4));
    omd = fullfile(mov_fol,'orig_movies');
    omdt = dir(fullfile(omd,'*.tif'));
    nmat = length(dir(fullfile(omd,'*.mat')));
    sta = cell(nmat,1);
    [~,ndt] = natsortfiles({omdt.name});
    lomdt = length(omdt);
    if lomdt==1, continue; end
    disp('KEEPING FIRST STACK')
    st = 1; i = 1;
    while st <= lomdt
        if ~exist(fullfile(omd,[omdt(ndt(st)).name(1:end-4) '.mat']),'file')
            st = st+1;
            continue;
        end
        load(fullfile(omd,[omdt(ndt(st)).name(1:end-4) '.mat']),'Threshfxyc');
        sta{i} = fxyc_to_struct(Threshfxyc,'w4s');
        st = st+1; i = i+1;
    end
    mp_filename = [mov_fol filesep 'max_proj.tif'];
    if redo || ~exist(mp_filename,'file')
        if exist(mp_filename,'file'), delete(mp_filename); end
        mlps = length(imfinfo(fullfile(omd,omdt(1).name)));
        for fr = 1:mlps
            if fr == 1
                fr_sz = size(imread(fullfile(omd,omdt(1).name)));
            end
            tmp = zeros([fr_sz lomdt],'uint16');
            for zi = 1:lomdt
                tmp(:,:,zi) = imread(fullfile(omd,omdt(ndt(zi)).name),fr);
            end
            img = max(tmp,[],3);
            imwrite(img,mp_filename,'tif','writemode','append')
        end
    end
    mov_sz = [size(imread(mp_filename)) length(imfinfo(mp_filename))];
    cnsta{mov} = combining_and_mixing(sta,mov_sz,framegap(mov),thresh(mov));
    save([exp_name filesep 'nsta.mat'],'cnsta','-v7.3');
end

nsta = cell(sum(~cellfun(@isempty,cnsta)),1);

for i = 1:length(cnsta)
    j = 1;
    while j <= length(cnsta{i})
        if isempty(cnsta{i}{j})
            j = j+1;
            continue;
        end
        nsta{i} = [nsta{i} cnsta{i}{j}];
        j = j+1;
    end
end  

for i = 1:length(nsta)
    tmp = cellfun(@isempty,{nsta{i}.frame});
    nsta{i}(tmp) = [];
    fnames = fieldnames(nsta{i});
    for j = 1:length(nsta{i})
        for k = 1:length(fnames)
            nsta{i}(j).(fnames{k}) = single(nsta{i}(j).(fnames{k}));
        end
    end
end
save([exp_name filesep 'nsta.mat'],'nsta','-v7.3');
end