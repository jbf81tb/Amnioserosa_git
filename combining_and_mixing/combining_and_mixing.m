function structs = combining_and_mixing(structs,mp_filename,frame_length,thresh)
global ord sec
mov_sz = [size(imread(mp_filename)) length(imfinfo(mp_filename))];
sst = size(structs);
if ~isstruct(structs{1,1})
    fprintf('Making structs... ');
    for sec = 1:sst(1)
        for st = 1:sst(2)
            structs{sec,st} = fxyc_to_struct(structs{sec,st},'w4s');
        end
    end
    fprintf('complete.\n');
end
save tmp.mat structs
for sec = 1:sst(1)
    structs(sec,:) = find_coincidences_ps(structs(sec,:),mov_sz);
    nps = sum(~cellfun(@isempty,structs(sec,:)));
    ord = gen_ord(nps);
    for o = ord
    fprintf('Section %i, Stack %i is... ',sec,o);
        fxyc = cell(nps,1);
        for st = 1:nps
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
    save tmp.mat structs
    fprintf('Fixing self coincidence... ');
    structs{sec, ord(end)} = find_and_fix_self_coincidence(structs{sec, ord(end)},mov_sz);
    fprintf('complete.\n');
    save tmp.mat structs
    fprintf('Cleaning structs and finding slopes... ');
    for st = 1:nps
        tmpl = cellfun(@isempty,{structs{sec,st}.frame});
        structs{sec,st}(tmpl) = [];
        structs{sec,st} = slope_finding(structs{sec,st},frame_length(sec),thresh(sec));
    end
    fprintf('complete.\n');
    save tmp.mat structs
end
delete tmp.mat
end