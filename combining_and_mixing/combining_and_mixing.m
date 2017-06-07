function structs = combining_and_mixing(structs,mov_sz,frame_length,thresh)
global ord
nps = length(structs);
if exist('.\tmp.mat','file')
    load('.\tmp.mat')
else
    structs = find_coincidences(structs,mov_sz);
    save .\tmp.mat structs
end
ord = gen_ord(nps);
for o = ord
    fprintf('Stack %i is... ',o);
    n = 2-mod(find(o==ord),2);
    s = [fieldnames(structs{o}(1))';repmat({[]},size(fieldnames(structs{o}(1))'))];
    for i = 1:length(structs{o})
        if (o == ord(end) && length(ord)>2) || length(ord)==2
            comb = gen_comb2(structs,i,s);
        else
            comb = gen_comb(structs,o,i,n,s);
        end
        if isempty(comb.trace(1).frame)
            structs{o}(i) = struct(s{:});
            continue; 
        end
        comb = clean_comb(comb);
        structs = mix_n_replace(comb,n,o,s,structs,mov_sz);
    end
    fprintf('mixed.\n');
end
save .\tmp.mat structs
fprintf('Fixing self coincidence... ');
structs{ord(end)} = find_and_fix_self_coincidence(structs{ord(end)},mov_sz);
fprintf('complete.\n');
save .\tmp.mat structs
fprintf('Cleaning structs and finding slopes... ');
for st = 1:nps
    structs{st} = slope_finding(structs{st},frame_length,thresh);
end
fprintf('complete.\n');
delete .\tmp.mat
end