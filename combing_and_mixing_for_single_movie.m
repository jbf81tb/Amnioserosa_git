%% Variable management
% You should only need to change anything on this line
framegap = 1;
thresh = 400;
exclude = false; %true if first and second stack are the same
%% Folder management
mov_fol = pwd; %make sure you are in directory containing orig_movies
omd = fullfile(mov_fol,'orig_movies');
omdt = dir(fullfile(omd,'*.tif'));
[~,ndt] = natsortfiles({omdt.name});
lomdt = length(omdt);
omdm = dir(fullfile(omd,'*.mat'));
mlps = length(imfinfo(fullfile(omd,omdt(1).name)));

mp_filename = [mov_fol filesep 'max_proj.tif'];
if exist(mp_filename,'file'), delete(mp_filename); end
for fr = 1:mlps
    if fr == 1
        mov_sz = size(imread(fullfile(omd,omdt(1).name)));
    end
    tmp = zeros([mov_sz lomdt],'uint16');
    for zi = 1:lomdt
        tmp(:,:,zi) = imread(fullfile(omd,omdt(ndt(zi)).name),fr);
    end
    img = max(tmp,[],3);
    imwrite(img,mp_filename,'tif','writemode','append')
end
if exclude
    sta = cell(1,length(omdm)-1);
    for st = 1:length(omdm)-1
        if ~exist(fullfile(omd,omdm(ndt(st+1)).name),'file'), continue; end
        load(fullfile(omd,omdm(ndt(st+1)).name),'Threshfxyc');
        sta{st} = fxyc_to_struct(Threshfxyc,'w4s');
        sta{st}([sta{st}.lt]<3) = [];
    end
else
    sta = cell(1,length(omdm));
    for st = 1:length(omdm)
        if ~exist(fullfile(omd,omdm(ndt(st)).name),'file'), continue; end
        load(fullfile(omd,omdm(ndt(st)).name),'Threshfxyc');
        sta{st} = fxyc_to_struct(Threshfxyc,'w4s');
        sta{st}([sta{st}.lt]<3) = [];
    end
end
%% Main function
nstac = combining_and_mixing(sta,mp_filename,framegap,thresh);
%% Combine everything into a single structure and make every field a single
cnsta = [];
for j = 1:length(nstac);
    cnsta = [cnsta, nstac{j}];
end

fnames = fieldnames(cnsta);
for j = 1:length(cnsta)
    for k = 1:length(fnames)
        cnsta(j).(fnames{k}) = single(cnsta(j).(fnames{k}));
    end
end

save cnsta.mat cnsta