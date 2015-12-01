function structs = combining_and_mixing(structs,mov_sz)
global ord sec
sst = size(structs);
if ~isstruct(structs{1,1})
    fprintf('Making structs... ');
    for sec = 1:sst(1)
        for st = 1:sst(2)
            structs{sec,st} = fxyc_to_struct(structs{sec,st});
        end
    end
    fprintf('complete.\n');
end
structs = find_coincidences(structs,mov_sz);
for sec = 1:sst(1)
    ord = gen_ord(sst(2));
    for o = ord
    fprintf('Section %i, Stack %i is... ',sec,o);
        fxyc = cell(sst(2),1);
        for st = 1:sst(2)
            fxyc{st} = structs{sec,st};
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
        fprintf('mixed.\n');
    end
    fprintf('Fixing self coincidence... ');
    structs{sec, ord(end)} = find_and_fix_self_coincidence(structs{sec, ord(end)},mov_sz);
    fprintf('complete.\n');
    fprintf('Cleaning structs and finding slopes... %3i%%',0);
    for st = 1:sst(2)
        tmpl = cellfun(@isempty,{structs{sec,st}.frame});
        structs{sec,st}(tmpl) = [];
        structs{sec,st} = slope_finding(structs{sec,st});
        fprintf('\b\b\b\b%3i%%',ceil(100*st/sst(2)));
    end
    fprintf('\b\b\b\bcomplete.\n');
end
end