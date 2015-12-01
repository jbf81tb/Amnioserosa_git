function fxyc = struct_to_fxyc(struct)
    good = ~cellfun(@isempty,{struct.frame});
    maxfr = max(cellfun(@max,{struct(good).frame}));
    fxyc = zeros(maxfr,5,length(struct));
    for tr = 1:length(struct)
        if isempty(struct(tr).frame), continue; end
        for fr = 1:length(struct(tr).frame)
            fxyc(fr,1,tr) = struct(tr).frame(fr);
            fxyc(fr,2,tr) = struct(tr).xpos(fr);
            fxyc(fr,3,tr) = struct(tr).ypos(fr);
            fxyc(fr,4,tr) = struct(tr).class;
            fxyc(fr,5,tr) = struct(tr).int(fr);
        end
    end
end