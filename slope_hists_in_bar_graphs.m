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
%%
bay = zeros(5,length(cnsta)); %basal (no blobs)
apy = zeros(5,length(cnsta)); %apical (no blobs)
by = zeros(5,length(cnsta));   %blobs
vec = [-inf -.045:.03:.045 inf];
x = -.06:.03:.06;
for sec = 1:length(cnsta)
    [bay(:,sec),~] = histcounts(nonzeros(cell2mat({cnsta{sec}(basal{sec}&~blob{sec}).sl}')),vec,'normalization','probability');
    [apy(:,sec),~] = histcounts(nonzeros(cell2mat({cnsta{sec}(apical{sec}&~blob{sec}).sl}')),vec,'normalization','probability');
    [by(:,sec),~] = histcounts(nonzeros(cell2mat({cnsta{sec}(blob{sec}).sl}')),vec,'normalization','probability');
end
%% BASAL
lsl = length(cnsta);
close
figure('units','normalized','outerposition',[0 0 1 1])
axes
hold on
bar(0*(lsl+10)+(1:lsl)+5,bay(1,:),.6,'facecolor',[.5 0 .5],'edgecolor','none')
bar(1*(lsl+10)+(1:lsl)+5,bay(2,:),.6,'facecolor',[0 0 .8],'edgecolor','none')
bar(2*(lsl+10)+(1:lsl)+5,bay(3,:),.6,'facecolor',[0 .5 0],'edgecolor','none')
bar(3*(lsl+10)+(1:lsl)+5,bay(4,:),.6,'facecolor',[1 .5 0],'edgecolor','none')
bar(4*(lsl+10)+(1:lsl)+5,bay(5,:),.6,'facecolor',[1 0 0],'edgecolor','none')
set(gca,'xtick',[],'ytick',[.25 .5])
ylim([0 .5])
xlim([1  5*(lsl+10)]);
title('basal')
frame = getframe(gcf);
imwrite(frame.cdata,'basal_hist_over_time.tif');
close
%% APICAL
lsl = length(cnsta);
close
figure('units','normalized','outerposition',[0 0 1 1])
axes
hold on
bar(0*(lsl+10)+(1:lsl)+5,apy(1,:),.6,'facecolor',[.5 0 .5],'edgecolor','none')
bar(1*(lsl+10)+(1:lsl)+5,apy(2,:),.6,'facecolor',[0 0 .8],'edgecolor','none')
bar(2*(lsl+10)+(1:lsl)+5,apy(3,:),.6,'facecolor',[0 .5 0],'edgecolor','none')
bar(3*(lsl+10)+(1:lsl)+5,apy(4,:),.6,'facecolor',[1 .5 0],'edgecolor','none')
bar(4*(lsl+10)+(1:lsl)+5,apy(5,:),.6,'facecolor',[1 0 0],'edgecolor','none')
set(gca,'xtick',[],'ytick',[.25 .5])
ylim([0 .5])
xlim([1  5*(lsl+10)]);
title('apical')
frame = getframe(gcf);
imwrite(frame.cdata,'apical_hist_over_time.tif');
close
%% BLOB
lsl = length(cnsta);
close
figure('units','normalized','outerposition',[0 0 1 1])
axes
hold on
bar(0*(lsl+10)+(1:lsl)+5,by(1,:),.6,'facecolor',[.5 0 .5],'edgecolor','none')
bar(1*(lsl+10)+(1:lsl)+5,by(2,:),.6,'facecolor',[0 0 .8],'edgecolor','none')
bar(2*(lsl+10)+(1:lsl)+5,by(3,:),.6,'facecolor',[0 .5 0],'edgecolor','none')
bar(3*(lsl+10)+(1:lsl)+5,by(4,:),.6,'facecolor',[1 .5 0],'edgecolor','none')
bar(4*(lsl+10)+(1:lsl)+5,by(5,:),.6,'facecolor',[1 0 0],'edgecolor','none')
set(gca,'xtick',[],'ytick',[.25 .5])
ylim([0 .75])
xlim([1  5*(lsl+10)]);
title('blob')
frame = getframe(gcf);
imwrite(frame.cdata,'blob_hist_over_time.tif');
close