function structs = combining_and_mixing(structs,mov_sz,frame_length,thresh)
global ord
nps = length(structs);
if exist('.\tmp.mat','file')
    load('.\tmp.mat')
else
    structs = find_coincidences(structs,mov_sz);
    save .\tmp.mat structs
    save .\coin.mat structs
end
ord = gen_ord(nps);
comb = cell(1,nps);
for o = ord
    fprintf('Stack %i is... ',o);
    n = 2-mod(find(o==ord),2);
    s = [fieldnames(structs{o}(1))';repmat({[]},size(fieldnames(structs{o}(1))'))];
    comb{o} = cell(1,length(structs{o}));
    for i = 1:length(structs{o})
        if (o == ord(end) && length(ord)>2) || length(ord)==2
            comb{o}{i} = gen_comb2(structs,i,s);
        else
            comb{o}{i} = gen_comb(structs,o,i,n,s);
        end
        if isempty(comb{o}{i}.trace(1).frame)
            structs{o}(i) = struct(s{:});
            continue; 
        end
%         comb{o}{i} = clean_comb(comb{o}{i});
        structs = mix_n_replace(comb{o}{i},n,o,s,structs,mov_sz);
    end
    fprintf('mixed.\n');
end
save .\comb.mat comb
save .\tmp.mat structs
fprintf('Fixing self coincidence... ');
structs{ord(end)} = find_and_fix_self_coincidence(structs{ord(end)},mov_sz);
fprintf('complete.\n');
save .\tmp.mat structs
fprintf('Finding slopes... ');
for st = 1:nps
    structs{st} = slope_finding(structs{st},frame_length,thresh);
end
fprintf('complete.\n');
delete .\tmp.mat
end