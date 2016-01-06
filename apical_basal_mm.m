F = @(A1,x01,s1,A2,x02,s2,x)(A1*exp(-(x-x01).^2/(2*s1^2))+A2*exp(-(x-x02).^2/(2*s2^2)));
ml = 11;
fit_returns = zeros(4,4,ml,4,length(cnsta));
for sec = 1:length(cnsta)
    clear img
    zpa = [];
    close
    fh = figure;
    for fr = 3:ml-2
        xp = []; yp = []; zp = [];
        for i = 1:length(cnsta{sec})
            if ~any(cnsta{sec}(i).frame==fr), continue; end
            fr_ind = abs(cnsta{sec}(i).frame-fr)<=2;
            xp = [xp; cnsta{sec}(i).xpos(fr_ind)];
            yp = [yp; cnsta{sec}(i).ypos(fr_ind)];
            zp = [zp; cnsta{sec}(i).st(fr_ind)];
        end
        %     rp = sqrt(x{sec}p.^2 + y{sec}p.^2);
        %     tp = atan(y{sec}p./x{sec}p);
        %     zpa = [zpa, zp(cond)];
        for i = 1:4
            for j = 1:4
                cond = yp>(i-1)*128+1 & yp<=i*128&...
                    xp>(j-1)*128+1 & xp<=j*128;
                subplot(4,4,(i-1)*4+j)
                [hy,tmp] = histcounts(zp(cond),0:1:21);
                hx = (tmp(1:end-1)+tmp(2:end))/2;
                f = fit(hx',hy',F,'startpoint',[max(hy), 4, 1, max(hy)/2, 10, 1]);
                tmpval = coeffvalues(f);
                fit_returns(i,j,fr,1,sec) = tmpval(2);
                fit_returns(i,j,fr,2,sec) = tmpval(3);
                fit_returns(i,j,fr,3,sec) = tmpval(5);
                fit_returns(i,j,fr,4,sec) = tmpval(6);
                plot(f,hx,hy)
            end
        end
        set(fh,'name',num2str(fr));
        drawnow;
        %     img(:,:,fr) = Hist2D(y{sec}p(cond),zp(cond),200:2:300,0.5:.25:21.5);
    end
end
close

%%
if exist('tmp','file'), delete('tmp.tif'); end
for fr = 1:ml
    imwrite(uint8(img(:,:,fr)),'tmp.tif','writemode','append')
end
%%
basal = cell(1,17); apical = cell(1,17);
for sec = 1:17
    basal{sec} = false(1,length(cnsta{sec}));
    apical{sec} = false(1,length(cnsta{sec}));
    for i = 1:length(cnsta{sec})
        quadx = ceil(mean(cnsta{sec}(i).xpos)/128);
        quady = ceil(mean(cnsta{sec}(i).ypos)/128);
        mnz = mean(cnsta{sec}(i).st);
        fr = ceil(mean(cnsta{sec}(i).frame));
        if abs(mnz-fit_returns(quady,quadx,fr,1,sec))<fit_returns(quady,quadx,fr,2,sec)
            apical{sec}(i) = true;
        elseif abs(mnz-fit_returns(quady,quadx,fr,3,sec))<2*fit_returns(quady,quadx,fr,2,sec)
            %         if fit_returns(quady,quadx,fr,4)
            basal{sec}(i) = true;
        end
    end
end
%%
bax = cell(1,length(cnsta)); bay = cell(1,length(cnsta)); %basal (no blobs)
apx = cell(1,length(cnsta)); apy = cell(1,length(cnsta)); %apical (no blobs)
ox = cell(1,length(cnsta)); oy = cell(1,length(cnsta));   %everything but apical, basal, and blob
bx = cell(1,length(cnsta)); by = cell(1,length(cnsta));   %blobs
nbx = cell(1,length(cnsta)); nby = cell(1,length(cnsta)); %everything but blobs
ax = cell(1,length(cnsta)); ay = cell(1,length(cnsta));   %everything
vec = -.15:.01:.15;
for sec = 1:length(cnsta)
    [bay{sec},bax{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}(basal{sec}&~blob{sec}).sl}')),vec);
    bax{sec} = (bax{sec}(1:end-1)+bax{sec}(2:end))/2;
    [apy{sec},apx{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}(apical{sec}&~blob{sec}).sl}')),vec);
    apx{sec} = (apx{sec}(1:end-1)+apx{sec}(2:end))/2;
    [oy{sec},ox{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}(~basal{sec}&~apical{sec}&~blob{sec}).sl}')),vec);
    ox{sec} = (ox{sec}(1:end-1)+ox{sec}(2:end))/2;
    [by{sec},bx{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}(blob{sec}).sl}')),vec);
    bx{sec} = (bx{sec}(1:end-1)+bx{sec}(2:end))/2;
    [nby{sec},nbx{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}(~blob{sec}).sl}')),vec);
    nbx{sec} = (nbx{sec}(1:end-1)+nbx{sec}(2:end))/2;
    [ay{sec},ax{sec}] = histcounts(nonzeros(cell2mat({cnsta{sec}.sl}')),vec);
    ax{sec} = (ax{sec}(1:end-1)+ax{sec}(2:end))/2;
end
%%
for sec = 1:length(cnsta)
    close
    figure
    plot(bax{sec},bay{sec}/sum(bay{sec}),'b',apx{sec},apy{sec}/sum(apy{sec}),'r',nbx{sec},nby{sec}/sum(nby{sec}),'k')%,bx{sec},by{sec}/sum(by{sec}),'g')
    title('blue = basal | red = apical | green = blobs | black = everything')
    pause
end
close
%% basal over time
close
figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(bax{sec},bay{sec}/sum(bay{sec}),'color',cmap(ceil(sec/17*64),:))
    hold on
end
%% apical over time
close
figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(apx{sec},apy{sec}/sum(apy{sec}),'color',cmap(ceil(sec/17*64),:))
    hold on
end
%% blobs over time
close
figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(bx{sec},by{sec}/sum(by{sec}),'color',cmap(ceil(sec/17*64),:))
    hold on
end
%% not blobs over time
close
figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(nbx{sec},nby{sec}/sum(nby{sec}),'color',cmap(ceil(sec/17*64),:))
    hold on
end
%%
close
figure('position',[0 0 1 1])
ah = tight_subplot(4,4,.04,[.03 .02],[.02 .01]);
for sec = 1:16
    axes(ah(sec))
    hold on
    plot(apx{sec},apy{sec}/sum(apy{sec}),'r')
    plot(bax{sec},bay{sec}/sum(bay{sec}),'b')
    plot(bx{sec},by{sec}/sum(by{sec}),'g')
    title([num2str(3*(sec-1)) ' min'])
end
%%
for sec = 1:length(cnsta)
    close
    figure
    plot(bx{sec},by{sec}/sum(by{sec}),'k',nbx{sec},nby{sec}/sum(nby{sec}),'r')
    title('black = blobs | red = not blobs')
    pause
end
close
%%
close
figure
% ax{sec}es
for i = 1:4
    for j = 1:4
        subplot(4,4,(i-1)*4+j)
        hold on
        plot(squeeze(fit_returns(i,j,:,1)),'b')
        plot(squeeze(fit_returns(i,j,:,1))+squeeze(fit_returns(i,j,:,2)),'b--')
        plot(squeeze(fit_returns(i,j,:,1))-squeeze(fit_returns(i,j,:,2)),'b--')
        plot(squeeze(fit_returns(i,j,:,3)),'r')
        plot(squeeze(fit_returns(i,j,:,3))+squeeze(fit_returns(i,j,:,4)),'r--')
        plot(squeeze(fit_returns(i,j,:,3))-squeeze(fit_returns(i,j,:,4)),'r--')
        title('blue = apical{sec} | red = basal{sec}')
        ylim([1,21])
    end
end