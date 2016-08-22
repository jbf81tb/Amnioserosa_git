mov = 10;
st = nstac{mov}(apicalc{mov});
%%
vec = [-inf -.045:.03:.045 inf];
cond = {'normalization','probability'};
histogram(nonzeros(cell2mat({st.sl}')),vec,cond{:});
%%
% numin = zeros(1,25);
% for d = 10:10:250
mask = ~imread([movnm{mov} filesep 'Mask.tif']);
% imagesc(mask); 
B = bwboundaries(mask);
B = B{1};
B(B(:,1)==1,:) = [];
B(B(:,1)==512,:) = [];
B(B(:,2)==1,:) = [];
B(B(:,2)==512,:) = [];
B(:,[1,2]) = B(:,[2,1]);
edge = false(1,length(st));
for i = 1:length(st)
    op = repmat([mean(st(i).xpos),mean(st(i).ypos)],size(B));
    dmin = sqrt((op(:,1)-B(:,1)).^2 + (op(:,2)-B(:,2)).^2);
    if any(dmin<100)
        edge(i) = true;
    end
%     disp(num2str(100*i/length(st)))
end
numin = sum(edge);
% end
%%
vec = [-inf -.045:.03:.045 inf];
cond = {'normalization','probability'};
figure
histogram(nonzeros(cell2mat({st(edge).sl}')),vec,cond{:});
title('edge')
xlim([-.075 .075])
figure
histogram(nonzeros(cell2mat({st(~edge).sl}')),vec,cond{:});
title('middle')
xlim([-.075 .075])
%%
[ye,~]=histcounts(nonzeros(cell2mat({st(edge).sl}')),vec,cond{:});
[ym,~]=histcounts(nonzeros(cell2mat({st(~edge).sl}')),vec,cond{:});
bar([ye',ym'],1)
legend(sprintf('edge N=%u',numin),sprintf('middle N=%u',length(st)-numin))
%%
figure
axes
hold on
imagesc(mask)
xp = []; yp = [];
for i = 1:length(st)
   if ~edge(i),continue; end
   xp = [xp mean(st(i).xpos)];
   yp = [yp mean(st(i).ypos)];
end
scatter(xp,yp);
axis equal
axis ij
%%
%%
vec = [-inf -.045:.03:.045 inf];
cond = {'normalization','probability'};
dg = 2;
ds = dg:dg:40;
ye = zeros(5,length(ds));
ym = zeros(5,length(ds));
numin = zeros(1,length(ds));
for d = ds
mask = ~imread('Mask.tif');
% imagesc(mask); 
B = bwboundaries(mask);
B = B{1};
B(B(:,1)==1,:) = [];
B(B(:,1)==512,:) = [];
B(B(:,2)==1,:) = [];
B(B(:,2)==512,:) = [];
B(:,[1,2]) = B(:,[2,1]);
edge = false(1,length(st));
for i = 1:length(st)
    op = repmat([mean(st(i).xpos),mean(st(i).ypos)],size(B));
    dmin = min(sqrt((op(:,1)-B(:,1)).^2 + (op(:,2)-B(:,2)).^2));
    if dmin<d %&& dmin>(d-dg)
        edge(i) = true;
    end
%     disp(num2str(100*i/length(st)))
end
[ye(:,d/dg),~]=histcounts(nonzeros(cell2mat({st(edge).sl}')),vec,cond{:});
[ym(:,d/dg),~]=histcounts(nonzeros(cell2mat({st(~edge).sl}')),vec,cond{:});
numin(d/dg) = sum(edge);
end
tmp = [];
for i = 1:length(ds)
    tmp = [tmp ye(:,i) ym(:,i)];
end
% bar(tmp,1)
subplot(1,2,1)
bar(ye)
title(num2str(numin))
subplot(1,2,2)
bar(ym)
title(num2str(length(st)-numin))