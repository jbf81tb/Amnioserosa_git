function [Excorr]=LookForTraceCorrespondencesNEWF(fxyc1,fxyc2)
maxdist=sqrt(2);
neighborhood=20;
[~,~,a13]=size(fxyc1);
[~,~,a23]=size(fxyc2);
% frames=max(max(fxyc1(:,1,:)));
fprintf('\nPercent complete: %3i%%',0);
Excorr=cell(1,a23);
index=1;
for i1=1:a13
    used1=find(fxyc1(:,1,i1));
    if isempty(used1), continue; end
    span1=fxyc1(used1,1,i1);
    for i2=1:a23 %go through all pairs of traces, one from each plane and find corresponding parts
        used2=find(fxyc2(:,1,i2));
        if isempty(used2), continue; end
        span2=fxyc2(used2,1,i2);
        if min(span1)<=max(span2) || min(span2)<=max(span1)
            if isempty(intersect(span1,span2)), continue; end
            Ax1=fxyc1(used1(1),2,i1);
            Ay1=fxyc1(used1(1),3,i1);
            Ax2=fxyc2(used2(1),2,i2);
            Ay2=fxyc2(used2(1),3,i2);
            ApproxDist=sqrt((Ax1-Ax2)^2+(Ay1-Ay2)^2);
            if ApproxDist>neighborhood, continue; end
            foundframes=[];
            for i3=1:length(used1) %Look for a correspondece for the point at fxyc1(used(i3),:,i1)
                match=find(fxyc2(:,1,i2)==fxyc1(used1(i3),1,i1));
                if isempty(match), continue; end
                dist=sqrt((fxyc1(used1(i3),2,i1)-fxyc2(match(1),2,i2))^2+(fxyc1(used1(i3),3,i1)-fxyc2(match(1),3,i2))^2);
                if dist<=maxdist
                    foundframes=[foundframes fxyc1(used1(i3),1,i1)];
                end
            end
            if ~isempty(foundframes)
                Excorr{index}=[i1 i2 foundframes];
                index=index+1;
            end
        end
    end
fprintf('\b\b\b\b%3i%%', ceil(100*i1/a13));
end
fprintf('\b\b\b\b%3i%%\n',100);
end