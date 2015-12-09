F = @(A1,x01,s1,A2,x02,s2,x)(A1*exp(-(x-x01).^2/(2*s1^2))+A2*exp(-(x-x02).^2/(2*s2^2)));
fit_returns = zeros(4,4,ml,4);
clear img
zpa = [];
% close
% fh = figure;
for fr = 30%3:ml-2
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
%     set(fh,'name',num2str(fr));
%     drawnow;
%     img(:,:,fr) = Hist2D(yp(cond),zp(cond),200:2:300,0.5:.25:21.5);
end
% close
%%
if exist('tmp','file'), delete('tmp.tif'); end
for fr = 1:ml
    imwrite(uint8(img(:,:,fr)),'tmp.tif','writemode','append')
end