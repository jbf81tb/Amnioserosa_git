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
ml = 11;
maxst = max(cellfun(@max,{cnsta{1}.st}));
m1n = 1; m1x = 8;
sd1n = .5; sd1x = 3;
m2n = 6; m2x = maxst-5;
sd2n = .5; sd2x = 3;
ngc = 8; %number grid cells
frwin = 5;
vec = 0.5:(maxst+.5);
fit_returns = zeros(ngc,ngc,ml-2*frwin,11,length(cnsta));
show = true;
guess2 = []; actual = [];
fname = 'tmp2.tif';
if exist(fname,'file'), delete(fname); end
fprintf('Percent Complete: %3u%%',0);
for sec = 1:length(cnsta)
    close
    if show
        fh = figure('units','normalized','outerposition',[0 0 1 1],'color','w');
        ah = tight_subplot(ngc,ngc,.005,[0 .02],.005);
    end
    for fr = (frwin+1):ml-frwin
        xp = []; yp = []; zp = [];
        for i = 1:length(cnsta{sec})
            if ~any(cnsta{sec}(i).frame==fr), continue; end
            fr_ind = abs(cnsta{sec}(i).frame-fr)<=frwin;
            %             if masks{sec}(round(mean(cnsta{sec}(i).xpos(fr_ind))),...
            %                           round(mean(cnsta{sec}(i).ypos(fr_ind))))
            %                       continue;
            %             end
            xp = [xp; cnsta{sec}(i).xpos(fr_ind)];
            yp = [yp; cnsta{sec}(i).ypos(fr_ind)];
            zp = [zp; cnsta{sec}(i).st(fr_ind)];
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
                fit_returns(i,j,fr-frwin,1:length(rtvec),sec) = rtvec;
                
                c1 = tmpval(2); s1 = tmpval(3);
                start1 = max(1,floor(c1-s1)); stop1 = min(length(hx),ceil(c1+s1));
                y_r1 = Fgaus(tmpval(1),tmpval(2),tmpval(3),start1:stop1);
                rsq1 = 1-SSE(y_r1,hy(start1:stop1))/SST(hy(start1:stop1));
                fit_returns(i,j,fr-frwin,9,sec) = rsq1;
                
                c2 = tmpval(6); s2 = tmpval(7);
                start2 = max(1,floor(c2-s2)); stop2 = min(length(hx),ceil(c2+s2));
                y_r2 = Fgaus(tmpval(5),tmpval(6),tmpval(7),start2:stop2);
                rsq2 = 1-SSE(y_r2,hy(start2:stop2))/SST(hy(start2:stop2));
                fit_returns(i,j,fr-frwin,10,sec) = rsq2;
                
                if show
                    hold off
                    plot(hx,hy,'.');
                    tmpc = num2cell(tmpval);
                    tmpx = min(hx):.01:max(hx);
                    hold on
                    plot(tmpx,F(tmpc{:},tmpx));
                    axis off
                    legend off
                    if fit_returns(i,j,fr-frwin,9,sec)>.5
                        text(.1,.7,'GOOD','Units','normalized','color','r')
                    end
                    if fit_returns(i,j,fr-frwin,10,sec)>.5
                        text(.5,.7,'GOOD','Units','normalized','color','b')
                    end
                    if fit_returns(i,j,fr-frwin,10,sec)>.4 && hy(min(ceil(c2),length(hy)))/max(y_r2)>1.1
                        text(.5,.7,'GOOD','Units','normalized','color','b')
                        fit_returns(i,j,fr-frwin,11,sec)=1;
                    end
                end
            end
        end
        if show
            set(fh,'name',num2str(fr));
            drawnow;
            frame = getframe(gcf);
            imwrite(frame.cdata,fname,'tif','writemode','append')
        end
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*sec/length(cnsta)));
end
fprintf('\b\b\b\b%3u%%\n',100);
close

%%
if exist('tmp','file'), delete('tmp.tif'); end
for fr = 1:ml
    imwrite(uint8(img(:,:,fr)),'tmp.tif','writemode','append')
end
%%
basal = cell(1,length(cnsta)); apical = cell(1,length(cnsta));
for sec = 1:length(cnsta)
    basal{sec} = false(1,length(cnsta{sec}));
    apical{sec} = false(1,length(cnsta{sec}));
    for i = 1:length(cnsta{sec})
        quadx = ceil(mean(cnsta{sec}(i).xpos)/gcsz);
        quady = ceil(mean(cnsta{sec}(i).ypos)/gcsz);
        mnz = mean(cnsta{sec}(i).st);
        fr = 1;
        if ~any((cnsta{sec}(i).frame==6)), continue; end
        tmpc = num2cell(reshape(fit_returns(quady,quadx,fr,:,sec),[],1));
        [A1,x01,s1,A3,A2,x02,s2,adjrsq,rsqa,rsqb,othb] = tmpc{:};
        if A1>A3
            if abs(mnz-x01)<(s1*sqrt(2*log(A1/A3)))
                if rsqa>.5
                    apical{sec}(i) = true;
                end
            elseif A2>A3 && abs(mnz-x02)<(s2*sqrt(2*log(A2/A3)))
                if rsqb>.4
                    if rsqb>.5 || othb==1
                        basal{sec}(i) = true;
                    end
                end
            end
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
vec = -.155:.01:.155;
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
% close all
figure
cmap = colormap('hot');
for sec = 1:length(cnsta)
    plot(bax{sec},bay{sec}/sum(bay{sec}),'color',cmap(ceil(sec/length(cnsta)*64),:))
    hold on
end
%% apical over time
% close
figure
cmap = colormap('cool');
for sec = 1:length(cnsta)
    plot(apx{sec},apy{sec}/sum(apy{sec}),'color',cmap(ceil(sec/length(cnsta)*64),:))
    hold on
end
%% blobs over time
% close
% figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(bx{sec},by{sec}/sum(by{sec}),'color','k')%cmap(ceil(sec/length(cnsta)*64),:))
    hold on
end
%% not blobs over time
close
figure
cmap = colormap('parula');
for sec = 1:length(cnsta)
    plot(nbx{sec},nby{sec}/sum(nby{sec}),'color',cmap(ceil(sec/length(cnsta)*64),:))
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