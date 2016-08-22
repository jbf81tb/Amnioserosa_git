dname = 'E:\Josh\Matlab\cmeAnalysis_movies\new_amneo_movies\movies\slope_hists';
if ~exist(dname, 'dir'), mkdir(dname); end
%%
clear ys xs
for i = 1:length(apicalc)
%     fh = figure;
    [ys{i},~] = histcounts(nonzeros(cell2mat({nstac{i}(apicalc{i}).sl}')),[-inf -.045:.03:.045 inf],'normalization','probability');
    xs{i} = -.06:.03:.06;
%     title(tmpd(i).name,'interpreter','none')
%     F = getframe(fh);
%     imwrite(F.cdata,fullfile(dname,[tmpd(i).name '_slopes.tif']),'tif')
%     close(fh)
end
sort_ys = zeros(5,length(apicalc));
sort_num = zeros(length(apicalc),1);
il = 1;
for lst = [stg('early'),stg('middle'),stg('late')]
    sort_ys(:,il) = ys{lst};
    sort_num(il) = sum(apicalc{lst});
    il = il + 1;
end
ne = length(stg('early'));
nm = length(stg('middle'));
% nl = length(stg('late'));

bh = bar(sort_ys);
for i = 1:ne;
bh(i).FaceColor = 'g';
bh(i).EdgeColor = 'g';
end
for i = ne:(ne+nm)
bh(i).FaceColor = 'b';
bh(i).EdgeColor = 'b';
end

for i = (ne+nm):length(apicalc)
bh(i).FaceColor = 'r';
bh(i).EdgeColor = 'r';
end
%%
stg = @(type) find(...
                   ~cellfun(@isempty,...
                            cellfun(@strfind,...
                                    movnms,repmat({type},size(movnms)),...
                                    'uniformoutput',false...
                                    )...
                           )...
                  );
clear ys xs
stages = {stg('early'),stg('middle'),stg('late')};
for i = 1:length(stages)
    tmpsl = [];
    for j = stages{i}
        tmpsl = [tmpsl nonzeros(cell2mat({nstac{j}(apicalc{j}).sl}'))'];
    end
    [ys{i},~] = histcounts(tmpsl,[-inf -.045:.03:.045 inf],'normalization','probability');
    xs{i} = -.06:.03:.06;
end
bh = bar(cell2mat(ys')');
for i = 1
bh(i).FaceColor = 'g';
bh(i).EdgeColor = 'g';
end
for i = 2
bh(i).FaceColor = 'b';
bh(i).EdgeColor = 'b';
end

for i = 3
bh(i).FaceColor = 'r';
bh(i).EdgeColor = 'r';
end