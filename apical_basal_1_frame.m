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
ml = max(cellfun(@max,{nsta.frame}));
maxst = max(cellfun(@max,{nsta.st}));
m1n = 1; m1x = 10;
sd1n = .5; sd1x = 3;
m2n = 10; m2x = maxst;
sd2n = .5; sd2x = 3;
ngc = 8; %number grid cells
frwin = floor((ml-1)/2);
vec = 0.5:(maxst+.5);
fit_returns = zeros(ngc,ngc,11);
fh = figure('units','normalized','position',[0 0 1 1],'color','w');
ah = tight_subplot(ngc,ngc,.005,[0 .02],.005);
mask = imread('Mask.tif');
fname = 'tmp.tif';
if exist(fname,'file'), delete(fname); end

xp = zeros(1,length(nsta));
yp = zeros(1,length(nsta));
zp = zeros(1,length(nsta));
for i = 1:length(nsta)
    if mask(round(mean(nsta(i).ypos)),...
            round(mean(nsta(i).xpos)))
        continue;
    end
    xp(i) = mean(nsta(i).xpos);
    yp(i) = mean(nsta(i).ypos);
    zp(i) = mean(nsta(i).st);
end
gcsz = 512/ngc;
for i = 1:ngc
    for j = 1:ngc
        cond = yp>(i-1)*gcsz+1 & yp<=i*gcsz&...
            xp>(j-1)*gcsz+1 & xp<=j*gcsz;
        axes(ah((i-1)*ngc+j)); %#ok<LAXES>
        [hy,tmp] = histcounts(zp(cond),vec);
        hx = (tmp(1:end-1)+tmp(2:end))/2;
        hx = double(hx);
        hy = double(hy);
        [f, gof] = fit(hx',hy',F,...
            'startpoint',[max(hy), 5, 1, mean(hy), max(hy)/2, 11, 1],...
            'lower',[0,m1n,sd1n,0,0,m2n,sd2n],...
            'upper',[1.5*max(hy),m1x,sd1x,max(hy),1.5*max(hy),m2x,sd2x]);
        tmpval = coeffvalues(f);
        tmpc = num2cell(tmpval);
        [A1,x01,s1,A3,A2,x02,s2] = tmpc{:};
        rtvec = [tmpval gof.adjrsquare];
        fit_returns(i,j,1:length(rtvec)) = rtvec;
        
%         start1 = max(1,round(c1-s1)); 
        start1 = 1;
        stop1 = min(length(hx),round(x01+s1*sqrt(2*log(A1/A3))));
        y_r1 = Fgaus(A1,x01,s1,start1:stop1);
        rsq1 = 1-SSE(y_r1,hy(start1:stop1))/SST(hy(start1:stop1));
        fit_returns(i,j,9) = max(rsq1,0);
        
        start2 = max(1,round(x02-s2*sqrt(2*log(A2/A3)))); 
%         stop2 = min(length(hx),round(x02+s2));
        stop2 = length(hx);
        y_r2 = Fgaus(A2,x02,s2,start2:stop2);
        rsq2 = 1-SSE(y_r2,hy(start2:stop2))/SST(hy(start2:stop2));
        fit_returns(i,j,10) = max(rsq2,0);
        
        
        hold off
        plot(hx,hy,'.');
        tmpx = min(hx):.01:max(hx);
        hold on
        plot(tmpx,F(tmpc{:},tmpx));
        axis off
        legend off
        text(.1,.7,sprintf('%2.2f',fit_returns(i,j,9)),...
            'Units','normalized','color','r')
        text(.5,.7,sprintf('%2.2f',fit_returns(i,j,10)),...
            'Units','normalized','color','b')
        if fit_returns(i,j,10)>.4 && hy(min(ceil(x02),length(hy)))/max(y_r2)>1.1
            fit_returns(i,j,11)=1;
        end
        
    end
end
drawnow;
frame = getframe(gcf);
imwrite(frame.cdata,fname,'tif')
pause(1);
close;

basal = false(1,length(nsta));
apical = false(1,length(nsta));
for i = 1:length(nsta)
    quadx = ceil(mean(nsta(i).xpos)/gcsz);
    quady = ceil(mean(nsta(i).ypos)/gcsz);
    mnz = mean(nsta(i).st);
    tmpc = num2cell(reshape(fit_returns(quady,quadx,:),[],1));
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
    else
        if ~mask(round(mean(nsta(i).ypos)),round(mean(nsta(i).xpos)))
            if abs(mnz-x01)<s1
                if rsqa>.5
                    apical(i) = true;
                end
            elseif A2>A3 && abs(mnz-x02)<s2
                if rsqb>.4
                    if rsqb>.5 || othb==1
                        basal(i) = true;
                    end
                end
            end
        end
    end
end
