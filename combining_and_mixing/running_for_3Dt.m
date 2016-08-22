function cnsta = running_for_3Dt(exp_name,framegap,thresh)
md = fullfile(exp_name,'movies');
mdir = dir(fullfile(md,'*.tif'));
[~,ndx] = natsortfiles({mdir.name});
nm = length(mdir);
if length(framegap) == 1
    framegap = framegap*ones(1,nm);
end
if length(thresh) == 1
    thresh = thresh*ones(1,nm);
end
nstac = cell(nm,1);
for mov = 1:nm
    mov_fol = fullfile(md,mdir(ndx(mov)).name(1:end-4));
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
    sta = cell(1,length(omdm)-1);
    for st = 1:length(omdm)-1
        if ~exist(fullfile(omd,omdm(ndt(st+1)).name),'file'), continue; end
        load(fullfile(omd,omdm(ndt(st+1)).name),'Threshfxyc');
        sta{st} = fxyc_to_struct(Threshfxyc,'w4s');
    end
    nstac{mov} = combining_and_mixing(sta,mp_filename,framegap(mov),thresh(mov));
end

cnsta = cell(1,nm);
for i = 1:nm
    for j = 1:length(nstac{i});
        cnsta{i} = [cnsta{i}, nstac{i}{j}];
    end
end
for i = 1:length(cnsta)
    fnames = fieldnames(cnsta{i});
    for j = 1:length(cnsta{i})
        for k = 1:length(fnames)
            cnsta{i}(j).(fnames{k}) = single(cnsta{i}(j).(fnames{k}));
        end
    end
end
save cnsta.mat cnsta
end