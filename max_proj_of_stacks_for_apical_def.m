file = 'orig_movies\Stack_';
maxpfol = 'max_projs';
if exist(maxpfol,'dir'), rmdir(maxpfol,'s'); end
mkdir(maxpfol)
tmpd = dir([file '*.tif']);
maxst = length(tmpd)-1;
for st = 1:maxst
    movie = [file num2str(st+1) '.tif'];
    ml = length(imfinfo(movie));
    s = size(imread(movie));
    img = zeros([s ml],'uint16');
    for fr = 1:ml
        img(:,:,fr) = imread(movie,fr);
    end
    imwrite(max(img,[],3),[maxpfol '\maxStack_' num2str(st) '.tif'],'tif');
end