function fxyswn=LocateCenters(CMAP)  %Collapses all nonzero regions into a center point with an average strain and a width (average distance to center) and a number of points

mask = 5*ones(5);
mask = mask/sum(mask(:));
F = length(CMAP);
fxyswn=[];
for i=1:F
    spots = double(abs(CMAP{i})>0);
    if  sum(spots(:))==0, continue; end
    groups = conv2(spots,mask,'same');
    group_vals = conv2(CMAP{i},mask,'same');
    [B,L] = bwboundaries(groups,4);
    tmps = regionprops(L,'Centroid','EquivDiameter');
    centroids = cat(1, tmps.Centroid);
    widths = [tmps.EquivDiameter]/2;
    %Then find xyswn values
    for i2=1:length(B)
        n = sum(sum(groups.*double(L==i2)));
        fxyswn=[fxyswn ; [i,... 
                          centroids(i2,2),...
                          centroids(i2,1),...
                          sum(sum(group_vals.*double(L==i2)))/n,...
                          widths(i2),...
                          n]];
    end
end
end