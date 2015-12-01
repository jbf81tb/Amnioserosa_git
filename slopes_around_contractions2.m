function [inside, outside, inlt, outlt] = slopes_around_contractions2(fxyc_struct,fxyswn,rad)
cent_tr = fxyswn;

frames = {fxyc_struct.frame};
xpos = {fxyc_struct.xpos};
ypos = {fxyc_struct.ypos};
slope = {fxyc_struct.sl};
lts = [fxyc_struct.lt];

% rad = 50;
ml = max(cellfun(@max,frames));

isframe = cell(ml,1);
isframeind = cell(ml,1);
for fr = 1:ml
    for j = 1:length(frames)
        ind = find(frames{j}==fr);
        if ind
            isframe{fr}(end+1) = j;
            isframeind{fr}(end+1) = ind;
        end
        
    end
end
inside = cell(1,length(cent_tr)); outside = cell(1,length(cent_tr));
inlt = cell(1,length(cent_tr)); outlt = cell(1,length(cent_tr));
% window = 30;
secs = 3;
for num = 1:length(cent_tr)
%     secs = ceil(length(cent_tr{num})/window);
    window = ceil(length(cent_tr{num})/secs);
    iter = window*secs-length(cent_tr{num});
    inside{num} = cell(1,secs); outside{num} = cell(1,secs);
    inlt{num} = cell(1,secs); outlt{num} = cell(1,secs);
    for sec = 1:secs
        inside{num}{sec} = zeros(sum([fxyc_struct.lt]),1); outside{num}{sec} = zeros(sum([fxyc_struct.lt]),1);
        was_in = false(length(frames),1); was_out = false(length(frames),1);
        ini = 1; outi = 1; cont = false;
        for j = (1+window*(sec-1)-ceil((sec-1)*iter/(secs-1))):(window*sec-ceil((sec-1)*iter/(secs-1)))
            fr = cent_tr{num}(j,1);
            for i = 1:length(isframe{fr})
                ind = isframe{fr}(i);
                fr_ind = isframeind{fr}(i);
                dist = norm([xpos{ind}(fr_ind) ypos{ind}(fr_ind)] - [cent_tr{num}(j,2) cent_tr{num}(j,3)]);
                if dist<rad
                    inside{num}{sec}(ini) = slope{ind}(fr_ind);
                    ini = ini + 1;
                    cont = true;
                    if ~was_in(ind)
                        inlt{num}{sec}(end+1) = lts(ind);
                        was_in(ind) = true;
                    end
                end
                if cont, cont = false; continue; end
                outside{num}{sec}(outi) = slope{ind}(fr_ind);
                outi = outi + 1;
                if ~was_out(ind)
                    outlt{num}{sec}(end+1) = lts(ind);
                    was_out(ind) = true;
                end
            end
        end
        inside{num}{sec} = nonzeros(inside{num}{sec});
        outside{num}{sec} = nonzeros(outside{num}{sec});
    end
end
end