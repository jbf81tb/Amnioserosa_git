conv = .160;
st = nsta;
rmsdbl = cell(length(st),1);
for i = 1:length(st)
    if ~blob(i), continue; end
    lt = st(i).lt;
    rmsdbl{i} = zeros(1,lt-1);
    for n = 1:lt-1
        sd = zeros(1,lt-n);
        for j = 1:(lt-n)
            k = j+n;
            sd(j) = (st(i).xpos(j)-st(i).xpos(k))^2+...
                    (st(i).ypos(j)-st(i).ypos(k))^2;
        end
        rmsdbl{i}(n) = sqrt((conv^2)*sum(sd)/(lt-n));
    end
end
%%
close 
figure
axes
hold on
for i = 1:length(rmsd)
    if isempty(rmsd{i}), continue; end
    plot(3*(1:length(rmsd{i})),rmsd{i})
end
xlim([0 300])
ylim([0 7])
title('Amnioserosa (basal)')
ylabel('RMS (\mum)')
xlabel('Delay (s)')
%%
tmpd = dir('*mat');
astro = cell(1,length(tmpd));
for i = 1:length(tmpd)
    load(tmpd(i).name)
    astro{i} = fxyc_to_struct(Threshfxyc);
end
%%
conv = .107;
rmsda = cell(1,length(astro));
for mov = 1:length(astro)
    st = astro{mov};
    rmsda{mov} = cell(length(st),1);
    for i = 1:length(st)
        lt = st(i).lt;
        rmsda{mov}{i} = zeros(1,lt-1);
        for n = 1:lt-1
            sd = zeros(1,lt-n);
            for j = 1:(lt-n)
                k = j+n;
                sd(j) = (st(i).xpos(j)-st(i).xpos(k))^2+...
                        (st(i).ypos(j)-st(i).ypos(k))^2;
            end
            rmsda{mov}{i}(n) = sqrt((conv^2)*sum(sd)/(lt-n));
        end
    end
end
%%
for mov = 4%:length(astro)
    figure
    axes
    hold on
    for i = 1:length(rmsda{mov})
        if isempty(rmsda{mov}(i)), continue; end
        plot(3*(1:length(rmsda{mov}{i})),rmsda{mov}{i});
    end
end
xlim([0 300])
ylim([0 7])
title('Astrocyte (4)')
ylabel('RMS (\mum)')
xlabel('Delay (s)')
%% APICAL
maxl = max(cellfun(@length,rmsdap));
rmsdaplist = cell(maxl,1);

for i = 1:length(rmsdap)
    if isempty(rmsdap{i}), continue; end
    for j = 1:length(rmsdap{i})
        rmsdaplist{j} = [rmsdaplist{j} rmsdap{i}(j)];
    end
end
mnrmsdap = cellfun(@mean,rmsdaplist);
stdrmsdap = cellfun(@std,rmsdaplist);
%% BASAL
maxl = max(cellfun(@length,rmsdba));
rmsdbalist = cell(maxl,1);

for i = 1:length(rmsdba)
    if isempty(rmsdba{i}), continue; end
    for j = 1:length(rmsdba{i})
        rmsdbalist{j} = [rmsdbalist{j} rmsdba{i}(j)];
    end
end
mnrmsdba = cellfun(@mean,rmsdbalist);
stdrmsdba = cellfun(@std,rmsdbalist);
%% BLOB
maxl = max(cellfun(@length,rmsdbl));
rmsdbllist = cell(maxl,1);

for i = 1:length(rmsdbl)
    if isempty(rmsdbl{i}), continue; end
    for j = 1:length(rmsdbl{i})
        rmsdbllist{j} = [rmsdbllist{j} rmsdbl{i}(j)];
    end
end
mnrmsdbl = cellfun(@mean,rmsdbllist);
stdrmsdbl = cellfun(@std,rmsdbllist);
%% ASTRO
maxl = max(cellfun(@length,crmsda));
crmsdalist = cell(maxl,1);

for i = 1:length(crmsda)
    if isempty(crmsda{i}), continue; end
    for j = 1:length(crmsda{i})
        crmsdalist{j} = [crmsdalist{j} crmsda{i}(j)];
    end
end
mncrmsda = cellfun(@mean,crmsdalist);
stdcrmsda = cellfun(@std,crmsdalist);
%%
close
figure
axes
hold on
xba = 3*(1:length(mnrmsdba));
xap = 3*(1:length(mnrmsdap));
xbl = 3*(1:length(mnrmsdbl));
xca = 3*(1:length(mncrmsda));
% plot(xba,mnrmsdba,'r')
% plot(xap,mnrmsdap,'b')
shadedErrorBar(xba,mnrmsdba,stdrmsdba,{'r','linewidth',4},1)
shadedErrorBar(xap,mnrmsdap,stdrmsdap,{'b','linewidth',4},1)
shadedErrorBar(xbl,mnrmsdbl,stdrmsdbl,{'k','linewidth',4},1)
shadedErrorBar(xca,mncrmsda,stdcrmsda,{'color',[0 .4 0],'linewidth',4},1)
ylim([0 4])
xlim([0 200])
ylabel('RMSD (\mum)')
xlabel('Delay (s)')