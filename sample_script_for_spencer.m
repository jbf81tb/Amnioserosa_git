%% Make structure array
structs = cell(1,4);
for i = 1:4
    load(['20151005_hela plaques cell 7_z' num2str(i+1) '.mat'],'Threshfxyc');
    structs{i} = fxyc_to_struct(Threshfxyc);
end
%% removing bad things. modify this to your liking.
for i = 1:4
    structs{i}([structs{i}.lt]<=2) = [];
end
%% check positions
for i = 1:4
    st = structs{i};
    movnm = ['E:\MATLAB\Josh\ran_movies\Hela_movie\orig_movies\20151005_hela plaques cell 7_z' num2str(i+1) '.tif'];
    close
    figure
    ml = length(imfinfo(movnm));
    for fr = 1:ml
        img = imread(movnm,fr);
        imagesc(img);%-medfilt2(img,[20 20]))
        hold on
        x = []; y = [];
        for j = 1:length(st)
            if st(j).lt<=2, continue; end
            fr_ind = find(st(j).frame==fr);
            if isempty(fr_ind), continue; end
            x = [x st(j).xpos(fr_ind)];
            y = [y st(j).ypos(fr_ind)];
        end
        scatter(x,y,6,'r','filled')
        xlim([125 345])
        ylim([85 335])
        pause(1/20)
    end
end
close
%% concatenate structure
nsta = [];
for i = 1:4
    nsta = [nsta nst{i}];
end