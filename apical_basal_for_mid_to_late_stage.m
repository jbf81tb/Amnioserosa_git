F = @(A1,x01,s1,A3,A2,x02,s2,x)...
    double(A1<A3|A2<A3)*double((x02-s2)>(x01+s1))*...
    (A1*exp(-(x-x01).^2/(2*s1^2)).*double(x<=(x01+s1))+...
    A3*double(x>(x01+s1)).*double(x<(x02-s2))+...
    A2*exp(-(x-x02).^2/(2*s2^2)).*double(x>=(x02-s2)))+...
    double(A1>A3)*double(A2>A3)*double((x02-s2)>(x01+s1))*...
    (A1*exp(-(x-x01).^2/(2*s1^2)).*double(x<=(x01+s1*sqrt(2*log(A1/A3))))+...
    A3*double(x>(x01+s1*sqrt(2*log(A1/A3)))).*double(x<(x02-s2*sqrt(2*log(A2/A3))))+...
    A2*exp(-(x-x02).^2/(2*s2^2)).*double(x>=(x02-s2*sqrt(2*log(A2/A3)))))+...
    double((x02-s2)<(x01+s1))*...
    (A1*exp(-(x-x01).^2/(2*s1^2))+...
    A2*exp(-(x-x02).^2/(2*s2^2)));
Fgaus = @(A,x0,s,x)(A*exp(-(x-x0).^2/(2*s^2)));
for mov = 1:length(tmpd)
    nsta = cnsta{mov};
    nsta([nsta.lt]<3) = [];
    ml = max(cellfun(@max,{nsta.frame}));
    maxst = max(cellfun(@max,{nsta.st}));
    m1n = 1; m1x = 8;
    sd1n = .5; sd1x = 3;
    m2n = 8; m2x = maxst;
    sd2n = .5; sd2x = 3;
    ngc = 8; %number grid cells
    frwin = floor((ml-1)/2);
    vec = 0.5:(maxst+.5);
    fit_returns = zeros(ngc,ngc,ml-2*frwin,11);
    figure
    cmap = colormap('jet');
    close
%     show = true;
    show = false;
    if show
        fh = figure('units','normalized','position',[0 0 1 1],'color','w');
        ah = tight_subplot(ngc,ngc,.005,[0 .02],.005);
    end
    mask = imread(['E:\Josh\Matlab\cmeAnalysis_movies\new_amneo_movies\movies\'...
        tmpd(mov).name...
        '\Mask.tif']);
%     fname = 'tmp.tif';
%     if exist(fname,'file'), delete(fname); end
%     fprintf('Percent Complete: %3u%%',0);
    for fr = (frwin+1):floor(frwin/2):ml-frwin
        xp = []; yp = []; zp = [];
        for i = 1:length(nsta)
            if ~any(nsta(i).frame==fr), continue; end
            fr_ind = abs(nsta(i).frame-fr)<=frwin;
            if mask(round(mean(nsta(i).ypos(fr_ind))),...
                    round(mean(nsta(i).xpos(fr_ind))))
                continue;
            end
            xp = [xp; nsta(i).xpos(fr_ind)];
            yp = [yp; nsta(i).ypos(fr_ind)];
            zp = [zp; nsta(i).st(fr_ind)];
        end
        gcsz = 512/ngc;
        for i = 1:ngc
            for j = 1:ngc
                cond = yp>(i-1)*gcsz+1 & yp<=i*gcsz&...
                    xp>(j-1)*gcsz+1 & xp<=j*gcsz;
                if show, axes(ah((i-1)*ngc+j)); end
                [hy,tmp] = histcounts(zp(cond),vec);
                hx = (tmp(1:end-1)+tmp(2:end))/2;
                [f, gof] = fit(hx',hy',F,...
                    'startpoint',[max(hy), 5, 1, mean(hy), max(hy)/2, 11, 1],...
                    'lower',[0,m1n,sd1n,0,0,m2n,sd2n],...
                    'upper',[1.5*max(hy),m1x,sd1x,max(hy),1.5*max(hy),m2x,sd2x]);
                tmpval = coeffvalues(f);
                rtvec = [tmpval gof.adjrsquare];
                fit_returns(i,j,fr-frwin,1:length(rtvec)) = rtvec;
                
                c1 = tmpval(2); s1 = tmpval(3);
                start1 = max(1,round(c1-s1)); stop1 = min(length(hx),round(c1+s1));
                y_r1 = Fgaus(tmpval(1),tmpval(2),tmpval(3),start1:stop1);
                rsq1 = 1-SSE(y_r1,hy(start1:stop1))/SST(hy(start1:stop1));
                fit_returns(i,j,fr-frwin,9) = max(rsq1,0);
                
                c2 = tmpval(6); s2 = tmpval(7);
                start2 = max(1,round(c2-s2)); stop2 = min(length(hx),round(c2+s2));
                y_r2 = Fgaus(tmpval(5),tmpval(6),tmpval(7),start2:stop2);
                rsq2 = 1-SSE(y_r2,hy(start2:stop2))/SST(hy(start2:stop2));
                fit_returns(i,j,fr-frwin,10) = max(rsq2,0);
                
                if show
                    hold off
                    plot(hx,hy,'.');
                    tmpc = num2cell(tmpval);
                    tmpx = min(hx):.01:max(hx);
                    hold on
                    plot(tmpx,F(tmpc{:},tmpx));
                    axis off
                    legend off
                    text(.1,.7,sprintf('%2.2f',fit_returns(i,j,fr-frwin,9)),...
                        'Units','normalized','color','r')
                    text(.5,.7,sprintf('%2.2f',fit_returns(i,j,fr-frwin,10)),...
                        'Units','normalized','color','b')
                    if fit_returns(i,j,fr-frwin,10)>.4 && hy(min(ceil(c2),length(hy)))/max(y_r2)>1.1
                        fit_returns(i,j,fr-frwin,11)=1;
                    end
                end
            end
        end
        if show
            set(fh,'name',num2str(fr));
            drawnow;
        end
%         frame = getframe(gcf);
%         imwrite(frame.cdata,fname,'tif','writemode','append')
%         fprintf('\b\b\b\b%3u%%',ceil(100*fr/(ml-frwin)));
    end
%     fprintf('\b\b\b\b%3u%%\n',100);
    close
    basal = false(1,length(nsta));
    apical = false(1,length(nsta));
    for i = 1:length(nsta)
        quadx = ceil(mean(nsta(i).xpos)/gcsz);
        quady = ceil(mean(nsta(i).ypos)/gcsz);
        mnz = mean(nsta(i).st);
        fr = ceil(mean(nsta(i).frame))-frwin;
        if fr<1||fr>(ml-2*frwin), continue; end
        if ~any(nsta(i).frame>frwin & nsta(i).frame<=(ml-frwin)), continue; end
        tmpc = num2cell(reshape(fit_returns(quady,quadx,fr,:),[],1));
        [A1,x01,s1,A3,A2,x02,s2,adjrsq,rsqa,rsqb,othb] = tmpc{:};
        if A1>A3
            if ~mask(round(mean(nsta(i).ypos)),round(mean(nsta(i).xpos)))
                if abs(mnz-x01)<(s1*sqrt(2*log(A1/A3)))
                    if rsqa>.5
                        apical(i) = true;
                    end
                elseif A2>A3 && abs(mnz-x02)<(s2*sqrt(2*log(A2/A3)))
                    if rsqb>.4
                        if rsqb>.5 || othb==1
                            basal(i) = true;
                        end
                    end
                end
            end
        end
    end
    nstac{mov} = nsta;
    apicalc{mov} = apical;
    disp(num2str(mov/15*100));
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