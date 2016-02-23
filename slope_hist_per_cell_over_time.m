for cellnum = [2,3,4,12,14,16,22]
frwin = 5;
slopes = cell(1,ml-2*frwin);
slope_hists = zeros(5,ml-2*frwin);
vec = [-inf -.045:.03:.045 inf];
for fr = (frwin+1):(ml-frwin)
    for i = 1:length(nsta)
%         if apical(i)&&good_orig(i,cellnum)&&~blob(i)
        if good_orig(i,cellnum)&&blob(i)
            fr_ind = abs(nsta(i).frame-fr)<=frwin;
            if ~any(fr_ind), continue; end
            slopes{fr-frwin} = [slopes{fr-frwin}; nsta(i).sl(fr_ind)];
        end
    end
    slope_hists(:,fr-frwin) = histcounts(nonzeros(slopes{fr-frwin}),vec,'normalization','probability');
end
for fr = (frwin+1):(ml-frwin)
    
end

lsl = length(slopes);
close
figure
axes
hold on
bar(0*(lsl+30)+(1:lsl),slope_hists(1,:),1,'facecolor',[.5 0 .5],'edgecolor','none')
bar(1*(lsl+30)+(1:lsl),slope_hists(2,:),1,'facecolor',[0 0 .8],'edgecolor','none')
bar(2*(lsl+30)+(1:lsl),slope_hists(3,:),1,'facecolor',[0 .5 0],'edgecolor','none')
bar(3*(lsl+30)+(1:lsl),slope_hists(4,:),1,'facecolor',[1 .5 0],'edgecolor','none')
bar(4*(lsl+30)+(1:lsl),slope_hists(5,:),1,'facecolor',[1 0 0],'edgecolor','none')
set(gca,'xtick',[])
ylim([0 .75])
title(num2str(cellnum))
frame = getframe(gcf);
imwrite(frame.cdata,[num2str(cellnum) 'blob.tif'],'tif');
close
end