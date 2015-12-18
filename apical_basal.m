F = @(A1,x01,s1,A2,x02,s2,x)(A1*exp(-(x-x01).^2/(2*s1^2))+A2*exp(-(x-x02).^2/(2*s2^2)));
fit_returns = zeros(4,4,ml,4);
clear img
zpa = [];
close
fh = figure;
for fr = 3:ml-2
    xp = []; yp = []; zp = [];
    for i = 1:length(nsta)
        if ~any(nsta(i).frame==fr), continue; end
        fr_ind = abs(nsta(i).frame-fr)<=2;
        xp = [xp; nsta(i).xpos(fr_ind)];
        yp = [yp; nsta(i).ypos(fr_ind)];
        zp = [zp; nsta(i).st(fr_ind)];
    end
%     rp = sqrt(xp.^2 + yp.^2);
%     tp = atan(yp./xp);
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
            fit_returns(i,j,fr,1) = tmpval(2); 
            fit_returns(i,j,fr,2) = tmpval(3);
            fit_returns(i,j,fr,3) = tmpval(5);
            fit_returns(i,j,fr,4) = tmpval(6);
            plot(f,hx,hy)
        end
    end
    set(fh,'name',num2str(fr));
    drawnow;
%     img(:,:,fr) = Hist2D(yp(cond),zp(cond),200:2:300,0.5:.25:21.5);
end
close
%%
if exist('tmp','file'), delete('tmp.tif'); end
for fr = 1:ml
    imwrite(uint8(img(:,:,fr)),'tmp.tif','writemode','append')
end
%%
basal = false(1,length(nsta));
apical = false(1,length(nsta));
for i = 1:length(nsta)
    quadx = ceil(mean(nsta(i).xpos)/128);
    quady = ceil(mean(nsta(i).ypos)/128);
    mnz = mean(nsta(i).st);
    fr = ceil(nsta(i).frame);
    if abs(mnz-fit_returns(quady,quadx,fr,1))<fit_returns(quady,quadx,fr,2)
        apical(i) = true;
    elseif abs(mnz-fit_returns(quady,quadx,fr,3))<2*fit_returns(quady,quadx,fr,2)
%         if fit_returns(quady,quadx,fr,4)
        basal(i) = true;
    end
end
%%
vec = -.15:.01:.15;
[bay,bax] = histcounts(nonzeros(cell2mat({nsta(basal&~blob).sl}')),vec);
bax = (bax(1:end-1)+bax(2:end))/2;
[apy,apx] = histcounts(nonzeros(cell2mat({nsta(apical&~blob).sl}')),vec);
apx = (apx(1:end-1)+apx(2:end))/2;
[oy,ox] = histcounts(nonzeros(cell2mat({nsta(~basal&~apical&~blob).sl}')),vec);
ox = (ox(1:end-1)+ox(2:end))/2;
[by,bx] = histcounts(nonzeros(cell2mat({nsta(blob).sl}')),vec);
bx = (bx(1:end-1)+bx(2:end))/2;
[nby,nbx] = histcounts(nonzeros(cell2mat({nsta(~blob).sl}')),vec);
nbx = (nbx(1:end-1)+nbx(2:end))/2;
[ay,ax] = histcounts(nonzeros(cell2mat({nsta.sl}')),vec);
ax = (ax(1:end-1)+ax(2:end))/2;
%%
close
figure
plot(bax,bay/sum(bay),'b',apx,apy/sum(apy),'r',nbx,nby/sum(nby),'k')%,bx,by/sum(by),'g')
title('blue = basal | red = apical | green = blobs | black = everything')
%%
close
figure
plot(bx,by/sum(by),'k',nbx,nby/sum(nby),'r')
title('black = blobs | red = not blobs')
%%
close
figure
% axes
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
        title('blue = apical | red = basal')
        ylim([1,21])
    end
end