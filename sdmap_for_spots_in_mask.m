mx = cellfun(@mean,{tmpst.xpos});
my = cellfun(@mean,{tmpst.ypos});

% mask = ~imread('Mask.tif');
stripe = ~imread('stripe.tif');
% amni = mask(sub2ind(size(mask),ceil(my),ceil(mx)));

%%

spc = 5;
rad = 50;
ss = [512,512];
[sdmap,dens] = deal(zeros(ss));
for ix = 1:spc:ss(2)
    for iy = 1:spc:ss(1)
        tmp = zeros(1,100000);
        k = 0;
        ct = 0;
        for i = 1:length(mx)
            if stripe(round(my(i)),round(mx(i))), continue; end
            if sqrt((mx(i)-ix)^2+(my(i)-iy)^2)<rad
                lsti = length(tmpst(i).sl);
                tmp(k+1:k+lsti) =  tmpst(i).sl;
                k = k+lsti;
                ct = ct+1;
            end
        end
        tmp = nonzeros(tmp);
        if length(tmp)<50, continue; end
        for j = 0:spc-1
            for k = 0:spc-1
                sdmap(iy+j,ix+k) = std(tmp);
                dens(iy+j,ix+k) = ct;
            end
        end
    end
    disp(100*ix/ss(2))
end

save sdmaps.mat sdmap dens
%%
close
figure('color','w')
colormap('gray')
ah = tight_subplot(1,2,.001,[.001 .04],.001);

    axes(ah(1))
    dens(dens==0)=min(nonzeros(dens(:)));
    imagesc(dens)
    axis equal
    axis off
    title('Density')
    axes(ah(2))
    sdmap(sdmap==0)=min(nonzeros(sdmap(:)));
    imagesc(sdmap)
    axis equal
    axis off
    title('Standard Deviation')
    F = getframe(gcf);
    imwrite(F.cdata,'sdmap.tif')
