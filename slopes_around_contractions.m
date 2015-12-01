function [inside, outside] = slopes_around_contractions(fxyc_struct,fxyswn,rad)
good_cent = cellfun(@size,fxyswn,repmat({1},[1 length(fxyswn)]))>1;
cent_tr = fxyswn(good_cent);
cent_tr_mat = cell2mat(cent_tr');
cframes = cent_tr_mat(:,1);
cxpos = cent_tr_mat(:,2);
cypos = cent_tr_mat(:,3);

frames = {fxyc_struct.frame};
xpos = {fxyc_struct.xpos};
ypos = {fxyc_struct.ypos};
slope = {fxyc_struct.sl};

% rad = 50;
ml = 100;

isframe = cell(ml,1);
isframeind = cell(ml,1);
for fr = 1:ml
    for j = 1:length(frames)
        ind = find(frames{j}==fr);
        if ind
            isframe{fr} = [isframe{fr} j];
            isframeind{fr} = [isframeind{fr} ind];
        end
        
    end
end

inside = zeros(sum([fxyc_struct.lt]),1); outside = zeros(sum([fxyc_struct.lt]),1);
ini = 1; outi = 1; cont = false;
for fr = 1:ml
    cfr = find(cframes==fr);
%     lcfr = length(cfr);
    for i = 1:length(isframe{fr})
        ind = isframe{fr}(i);
        fr_ind = isframeind{fr}(i);
        for ci = cfr'
            dist = norm([xpos{ind}(fr_ind) ypos{ind}(fr_ind)] - [cxpos(ci) cypos(ci)]);
            if dist<rad
                inside(ini) = slope{ind}(fr_ind);
                ini = ini + 1;
                cont = true;
            end
        end
        if cont, cont = false; continue; end
        outside(outi) = slope{ind}(fr_ind);
        outi = outi + 1;
    end
end
inside = nonzeros(inside);
outside = nonzeros(outside);
end