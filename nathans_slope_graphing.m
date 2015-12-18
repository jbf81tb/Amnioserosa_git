function [nathan, near] = nathans_slope_graphing(fxyc_struct,varargin)
if nargin==1
    good = true(1,length(fxyc_struct));
else
    good = varargin{1};
end
xpos = {fxyc_struct(good).xpos};
ypos = {fxyc_struct(good).ypos};
frames = {fxyc_struct(good).frame};
slopes = {fxyc_struct(good).sl};
mnslp = min(cellfun(@min,slopes));
for i = 1:length(slopes)
    slopes{i} = slopes{i} - mnslp;
end
% slopes = cellfun(@times,{fxyc_struct(good).sl},cellfun(@lt,{fxyc_struct(good).sl},repmat({0},[1 length({fxyc_struct.sl})]),'uniformoutput',false),'uniformoutput',false);
% nzslp = cellfun(@nonzeros,slopes,'uniformoutput',false);
% nzslpv = vertcat(nzslp{:});
% medsl = median(nzslpv);
ml = 86;
nn = 10;
exp_val = 1.1;
[ymax, xmax] = size(imread('max_proj.tif'));
nathan = cell(ml,1);
near = cell(ml,1);

isframe = cell(ml,1);
for i = 1:ml
    for j = 1:length(frames)
        if sum(frames{j}==i)
            isframe{i} = [isframe{i} j];
        end
    end
end
fprintf('Percent Complete: %3i%%',0);
for fr = 1:ml
    nathan{fr} = zeros(ymax,xmax);
    near{fr} = zeros(ymax,xmax);
    lisfr = length(isframe{fr});
    xy = zeros(lisfr,2);
    slp = zeros(lisfr,1);
    for j = 1:lisfr
        ind = isframe{fr}(j);
        fr_ind = find(frames{ind}==fr);
        xy(j,1) = xpos{ind}(fr_ind);
        xy(j,2) = ypos{ind}(fr_ind);
        slp(j) = slopes{ind}(fr_ind);
    end
    for x = 1:xmax
        for y = 1:ymax
            dist_ar = xy - repmat([x y],[lisfr 1]);
            dist = sqrt(dist_ar(:,1).^2 + dist_ar(:,2).^2);
            [sd, sdi] = sort(dist,'ascend');
%             if sd(1) == 0 &&  slp(sdi(1)) ~= 0
%                 nathan{fr}(y,x) = 2*medsl - slp(sdi(1));
%             else
%                 while sd(1) == 0 
%                     sd(1) = []; 
%                     sdi(1) = []; 
%                 end
                tmpsl = slp(sdi);
                cond = tmpsl~=0;
%                 tmpsl(cond) = 2*medsl - tmpsl(cond);
                nathan{fr}(y,x) = sum(tmpsl(cond)./(exp_val.^(sd(cond))))/sum(1./exp_val.^(sd(cond)));
%             end
            guess = 1; tot = 0; good = 1;
            while good <= nn && guess < length(sdi)
                if sd(guess)>30, break; end
                ind = sdi(guess);
                guess = guess + 1;
                if slp(ind)
                    tot = tot + slp(ind);%(2*medsl - slp(ind));
                    good = good + 1;
                end
            end
            near{fr}(y,x) = tot/good;
        end
    end
    fprintf('\b\b\b\b%3i%%',ceil(100*fr/ml));
end
fprintf('\b\b\b\b%3i%%\n',100);
end