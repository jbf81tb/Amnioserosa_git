F = @(A1,x01,s1,A2,x02,s2,x)(A1*exp(-(x-x01).^2/(2*s1^2))+A2*exp(-(x-x02).^2/(2*s2^2)));
m1n = 3; m1x = 8;
sd1n = .5; sd1x = 2;
m2n = 6; m2x = 25;
sd2n = .5; sd2x = 5;
ngc = 8; %number grid cells

ml = max(cell2mat({nsta.frame}'));
fit_returns = zeros(ngc,ngc,ml,4);
clear img
zpa = [];
close
fh = figure('color','w');
ah = tight_subplot(ngc,ngc,.005,[0 .02],.005);
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
gcsz = 512/ngc;
    for i = 1:ngc
        for j = 1:ngc
            cond = yp>(i-1)*gcsz+1 & yp<=i*gcsz&...
                    xp>(j-1)*gcsz+1 & xp<=j*gcsz;
%             subplot(8,8,(i-1)*8+j)
            axes(ah((i-1)*ngc+j))
            [hy,tmp] = histcounts(zp(cond),0.5:1:21.5); %%%adjust
            hx = (tmp(1:end-1)+tmp(2:end))/2;
            f = fit(hx',hy',F,'startpoint',[max(hy), 4, 1, max(hy)/2, 10, 1],...
                'lower',[0,m1n,sd1n,0,m2n,sd2n],...
                'upper',[1.5*max(hy),m1x,sd1x,1.5*max(hy),m2x,sd2x]);
            tmpval = coeffvalues(f);
            fit_returns(i,j,fr,1) = tmpval(2);
            fit_returns(i,j,fr,2) = tmpval(3);
            fit_returns(i,j,fr,3) = tmpval(5);
            fit_returns(i,j,fr,4) = tmpval(6);
            plot(f,hx,hy)
            legend off
            axis off
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
    quadx = ceil(mean(nsta(i).xpos)/gcsz);
    quady = ceil(mean(nsta(i).ypos)/gcsz);
    mnz = mean(nsta(i).st);
    fr = ceil(mean(nsta(i).frame));
    
    if abs(mnz-fit_returns(quady,quadx,fr,1))<fit_returns(quady,quadx,fr,2)
        if fit_returns(quady,quadx,fr,2) ~= sd1n && fit_returns(quady,quadx,fr,2) ~= sd1x
            if fit_returns(quady,quadx,fr,1) ~= m1n && fit_returns(quady,quadx,fr,2) ~= m1x
                apical(i) = true;
            end
        end
    elseif abs(mnz-fit_returns(quady,quadx,fr,3))<fit_returns(quady,quadx,fr,4)
        if fit_returns(quady,quadx,fr,4) ~= sd2n && fit_returns(quady,quadx,fr,4) ~= sd2x
            if fit_returns(quady,quadx,fr,3) ~= m2n && fit_returns(quady,quadx,fr,3) < 21
                %               if fit_returns(quady,quadx,fr,4)
                basal(i) = true;
            end
        end
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
vec = 0:3:200;
close
figure
% [baly,balx] = histcounts(3*[nsta(basal&~blob).lt],vec);
histogram(3*[nsta(basal&~blob).lt],vec,'normalization','pdf');
% balx = (balx(1:end-1)+balx(2:end))/2;
figure
% [aply,aplx] = histcounts(3*[nsta(apical&~blob).sl],vec);
histogram(3*[nsta(apical&~blob).lt],vec,'normalization','pdf');
% aplx = (aplx(1:end-1)+aplx(2:end))/2;
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