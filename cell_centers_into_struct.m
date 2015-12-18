for i = 1:length(c)
    c{i}(end+1) = c{i}(1);
end
%%
% fprintf('Percent Complete: %3u%%',0);
cfs = cell(1,length(nsta));
parfor i = 1:length(nsta)
    incell = [];
    for fr = 1:nsta(i).lt
        v = V{nsta(i).frame(fr)};
        c = C{nsta(i).frame(fr)};
        for j = 1:length(c)
            if any(c{j}==1), continue; end
            inc = inpolygon(nsta(i).xpos,nsta(i).ypos,v(c{j},1),v(c{j},2));
            inb = inpolygon(nsta(i).xpos,nsta(i).ypos,tb(:,1),tb(:,2));
            if any(inc&inb)
                incell = [incell j];
            end
        end
    end
    cfs{i} = unique(incell);
%     fprintf('\b\b\b\b%3u%%',ceil(100*i/length(nsta)));
end
% fprintf('\b\b\b\b%3u%%\n',100);
%%
for i = 1:length(nsta);
    nsta(i).cell = cfs{i};
end
%%
for fr = 1:86
close
figure
axes
hold on
scatter(squeeze(Centers(:,fr,1)),squeeze(Centers(:,fr,2)))
% text(squeeze(Centers(:,fr,1)),squeeze(Centers(:,fr,2)),
axis equal
axis ij
for k = 1:length(C{fr})
    if ~any(C{fr}{k}==1)
        plot(V{fr}(C{fr}{k},1),V{fr}(C{fr}{k},2))
    end
% pause
end
plot(tb(:,1),tb(:,2))
xlim([0 512])
ylim([0 512])
pause   
end