function [DVSMap]=DistVelStrianMap(fxyc_struct) %Density Map structure: (x,y,t,D/V/S/V_angle (1/2/3/4))

n = 40;

fprintf('Percent complete:   0%%');
lst=length(fxyc_struct);

xmax=ceil(max(cellfun(@max,{fxyc_struct.xpos})));
ymax=ceil(max(cellfun(@max,{fxyc_struct.ypos})));
frames=max(cellfun(@max,{fxyc_struct.frame}));
DVSMap=cell(frames,2);
isframe = cell(frames,1);
for i = 1:frames
    isframe{i} = [];
    for j = 1:lst
        if sum(fxyc_struct(j).frame==i)
            isframe{i} = [isframe{i} j];
        end
    end
end
for t=1:frames
    DVSMap(t,:) = repmat({zeros(xmax,ymax)},[1 2]);
    if isempty(isframe{t}), continue; end
    Cs=zeros(length(isframe{t}),2);
    Ds=zeros(length(isframe{t}),2);
    for i=1:length(isframe{t})
        ind = find(fxyc_struct(isframe{t}(i)).frame==t);
        Cs(i,1)=fxyc_struct(isframe{t}(i)).xpos(ind);
        Cs(i,2)=fxyc_struct(isframe{t}(i)).ypos(ind);
        Ds(i,:)=FindVel(fxyc_struct(isframe{t}(i)),ind);
    end
    for x=1:xmax
        for y=1:ymax
            [Vel, Strn] = CalcDVSofNearn(Cs, Ds, x, y, n);
            DVSMap{t,1}(x,y) = Vel;
            DVSMap{t,2}(x,y) = Strn;
        end
    end
    fprintf('\b\b\b\b%3u%%',ceil(100*t/frames))
end
fprintf('\b\b\b\b100%%\n')
end