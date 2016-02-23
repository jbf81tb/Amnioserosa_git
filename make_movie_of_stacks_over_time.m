exp_name = 'E:\Josh\Matlab\cmeAnalysis_movies\160125_amnioseroa_mm';
zlps = 22;
mlps = 11;
md = fullfile(exp_name,'movies');
mdir = dir(fullfile(md,'*.tif'));
for st = 1:zlps
    fname = fullfile(exp_name,['Stack_' num2str(st) '.tif']);
    if exist(fname,'file'), delete(fname); end
    for mov = 1:length(mdir)
        tmpfr = zeros(512,512,mlps);
        for fr = 1:mlps
            tmpfr = imread(fullfile(md,mdir(mov).name),(fr-1)*zlps+st);
        end
        frame = mean(tmpfr,3);
        imwrite(frame,fullfile(exp_name,['Stack_' num2str(st) '.tif']),'tif','writemode','append');
    end
end