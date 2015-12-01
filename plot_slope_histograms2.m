
CenterMap=CentersofExp(DVSMap_full_all);
fxyswn=LocateCenters(CenterMap);
cfxa=TrackCenters(fxyswn);
%%
cfx=cfxa;
q = []; f = [];
for i = 1:length(cfx)
    q = [q; cfx{i}(:,6)]; 
    f = [f; cfx{i}(:,1)]; 
end
%%
sq = sort(q);
lim = sq(ceil(end/2));
keep = true(1,length(cfx));
for i = 1:length(cfx)
    if mean(cfx{i}(:,6))<lim
        keep(i) = false;
    end
end
%%
% st = nsta;
ml = max(cellfun(@max,{nsta.frame}));
win = 60;
% goods = [58 132 85 101 106 152 149];
cent_tr = cfxp(keep);
% bads = [117 80 137 32];
% cent_tr = Cfxyswn(bads);
len = length(cent_tr);
for i = 1:len
    mat = cent_tr{i};
    st = max(1,mat(1,1)-win); en = min(ml,mat(end,1)+win);
%     if i==4, st = 130; en = 200; end
    tmp = zeros(en-st+1,3);
    k = 1;
    for j = st:en
        tmp(k,1) = j;
        if j<mat(1,1)
            tmp(k,2) = mat(1,2);%+sign(rand-.5)*30*rand;
            tmp(k,3) = mat(1,3);%+sign(rand-.5)*30*rand;
        elseif j>mat(end,1)
            tmp(k,2) = mat(end,2);%+sign(rand-.5)*30*rand;
            tmp(k,3) = mat(end,3);%+sign(rand-.5)*30*rand;
        else
            tmp(k,2) = mean(mat(abs(mat(:,1)-j)<3,2));%+sign(rand-.5)*30*rand;
            tmp(k,3) = mean(mat(abs(mat(:,1)-j)<3,3));%+sign(rand-.5)*30*rand;
        end
        k = k+1;
    end
    cent_tr{i} = tmp;
end
%%
rad = 15;
[inn, out, inlt, outlt] = slopes_around_contractions2(nsta,cent_tr,rad);
%%
yo = cell(1,length(in)); yi = cell(1,length(in));
cyo = cell(1,length(in)); cyi = cell(1,length(in));
for num = 1:length(in)
    yo{num} = cell(1,length(in{num})); yi{num} = cell(1,length(in{num}));
    cyo{num} = cell(1,length(in{num})); cyi{num} = cell(1,length(in{num}));
%     close all
%     figure('units','normalized','outerposition',[0 0 1 1]);
    cmap1 = colormap('winter');
    cmap2 = colormap('autumn');
    
    vec = -.1:.05:.1;
    for sec = 1:length(in{num})
        col = ceil(length(cmap1)*sec/length(in{num}));
        [yo{num}{sec}, xo] = hist(inp{num}{sec},vec);
        [yi{num}{sec}, xi] = hist(inn{num}{sec},vec);
        yi{num}{sec} = yi{num}{sec}/sum(yi{num}{sec}); yo{num}{sec} = yo{num}{sec}/sum(yo{num}{sec});
        cyi{num}{sec} = zeros(length(yi{num}{sec}),1);
        for i = 1:length(yi{num}{sec})
            cyi{num}{sec}(i) = sum(yi{num}{sec}(1:i));
        end
        cyo{num}{sec} = zeros(length(yo{num}{sec}),1);
        for i = 1:length(yo{num}{sec})
            cyo{num}{sec}(i) = sum(yo{num}{sec}(1:i));
        end
        %     subplot(1,2,1)
        plot(xo,yo{num}{sec},'bx')%,'color',cmap1(col,:))
        hold on
        %     title('outside')
        %     subplot(1,2,2)
%         if sec~=2, continue; end
        plot(xi,yi{num}{sec},'x','color',cmap2(col,:))
        %     hold on
        %     title('inside')
        
    end
%     title(num2str(goods(num)))
%     pause
end
% close
%%
syin = cell(1,3);
for sec = 1:3
%     syin{sec} = zeros(1,length(xi));
    for num = 1:len
        syin{sec} = [syin{sec};  yi{num}{sec}];
%         syin{sec} = syin{sec} + yi{num}{sec};
    end
end
syout = cell(1,3);
for sec = 1:3
%     syout{sec} = zeros(1,length(xo));
    for num = 1:len
        syout{sec} = [syout{sec}; yo{num}{sec}];
%         syout{sec} = syout{sec} + yo{num}{sec};
    end
end
%%
c1 = 'rbk';
c2 = 'mcg';
figure
for i = 1:3
    plot(xo,syout{i}/len,c1(i),xi,syin{i}/len,c2(i))
    hold on
end
%     legend('out','in')
%%
%%
%%
vec = 0:5:200;
[yolt, xolt] = hist(outlt,vec);
[yilt, xilt] = hist(inlt,vec);
sub=sub+1;
% close all
figure(1)
subplot(2,2,sub)
plot(xi,yi/sum(yi))
hold on
plot(xo,yo/sum(yo))
legend(sprintf('in, n=%i',length(in)),sprintf('out, n=%i',length(out)));
title(sprintf('%i',i));
figure(2)
subplot(2,2,sub)
plot(xilt,yilt/sum(yilt))
hold on
plot(xolt,yolt/sum(yolt))
legend(sprintf('in, n=%i',length(inlt)),sprintf('out, n=%i',length(outlt)));
title(sprintf('%i',i));
