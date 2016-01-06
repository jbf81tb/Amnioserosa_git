function nsta = running_for_3Dt(exp_name,framegap,thresh)
md = fullfile(exp_name,'movies');
mdir = dir(fullfile(md,'*.tif'));
[~,ndx] = natsortfiles({mdir.name});
nm = length(mdir);
for mov = 1:nm
    mov_fol = fullfile(md,mdir(ndx(mov)).name(1:end-4));
    omd = fullfile(mov_fol,'orig_movies');
    omdt = dir(fullfile(omd,'*.tif'));
    [~,ndt] = natsortfiles({omdt.name});
    lomdt = length(omdt);
    omdm = dir(fullfile(omd,'*.mat'));
    mlps = length(imfinfo(fullfile(omd,omdt(1).name)));
    if mov == 1, sta = cell(nm,lomdt); end %not perfect, mov 1 might not have all the zstacks
    
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
%     fprintf('%s\n',mdir(ndx(mov)).name)
    for st = 1:length(omdm)
        if ~exist(fullfile(omd,omdm(ndt(st)).name),'file'), continue; end
        load(fullfile(omd,omdm(ndt(st)).name),'Threshfxyc');
        sta{mov,st} = fxyc_to_struct(Threshfxyc);
%         fprintf('%s\n',omdm(ndt(st)).name)
%         names{mov,st} = sprintf('%s, %s',mdir(ndx(mov)).name(end-8:end-4),omdm(ndt(st)).name);
    end
end
nsta = combining_and_mixing(sta,mp_filename,framegap,thresh);
end