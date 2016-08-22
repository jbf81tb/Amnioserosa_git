function structs = combining_and_mixing(structs,mp_filename,frame_length,thresh)
global ord
mov_sz = [size(imread(mp_filename)) length(imfinfo(mp_filename))];
save tmp.mat structs
structs = find_coincidences_ps(structs,mov_sz);
nps = sum(~cellfun(@isempty,structs));
ord = gen_ord(nps);
for o = ord
    fxyc = cell(nps,1);
    for st = 1:nps
        fxyc{st} = structs{st};
    end
    n = 2-mod(find(o==ord),2);
    s = [fieldnames(fxyc{o}(1))';repmat({[]},size(fieldnames(fxyc{o}(1))'))];
    for i = 1:length(fxyc{o})
        if o == ord(end) && length(ord)>2
            comb = gen_comb2(fxyc,i,s);
        else
            comb = gen_comb(fxyc,o,i,n,s);
        end
        if isempty(comb.trace(1).frame), continue; end
        comb = clean_comb(comb);
        structs = mix_n_replace(comb,n,o,s,structs,mov_sz);
    end
end
save tmp.mat structs
fprintf('Fixing self coincidence... ');
structs{ord(end)} = find_and_fix_self_coincidence(structs{ord(end)},mov_sz);
fprintf('complete.\n');
save tmp.mat structs
fprintf('Cleaning structs and finding slopes... ');
for st = 1:nps
    tmpl = cellfun(@isempty,{structs{st}.frame});
    structs{st}(tmpl) = [];
    structs{st} = slope_finding(structs{st},frame_length,thresh);
end
fprintf('complete.\n');
save tmp.mat structs
delete tmp.mat
end