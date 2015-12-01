function Cfxyswn=TrackCenters(fxyswn)  %Takes centers of contraction from fxyswn and tracks them over time to produce a cell array w 1 track per cell

neighborhood=25;  %Max separation to count a patch in a track
minn=5;  %Minimum number of pixels needed to count a patch in a track
[N,~]=size(fxyswn);
frames=max(fxyswn(:,1));
UnusedC=1;
inside=cell(N,1);
for i=1:frames
    contemps=find(fxyswn(:,1)==i);
    contempsF=[];
    for i0=1:3
        contempsF=[contempsF ; find(fxyswn(:,1)==i+i0)];
    end
    for i2=1:length(contemps)
        if isempty(inside{contemps(i2)})
            inside{contemps(i2)}=UnusedC;
            Cfxyswn{UnusedC}=fxyswn(contemps(i2),:);
            UnusedC=UnusedC+1;
        end
        if fxyswn(contemps(i2),6)>=minn %number
            x=fxyswn(contemps(i2),2);
            y=fxyswn(contemps(i2),3);
            for i3=1:length(contempsF)
                xf=fxyswn(contempsF(i3),2);
                yf=fxyswn(contempsF(i3),3);
                dist=sqrt((x-xf)^2+(y-yf)^2);
                if dist<=neighborhood && fxyswn(contempsF(i3),6)>=minn
                    for i4=1:length(inside{contemps(i2)})
                        if ~ismember(fxyswn(contempsF(i3),:),Cfxyswn{inside{contemps(i2)}(i4)},'rows')
                            inside{contempsF(i3)}=[inside{contempsF(i3)} inside{contemps(i2)}(i4)];
                            Cfxyswn{inside{contemps(i2)}(i4)}=[Cfxyswn{inside{contemps(i2)}(i4)} ; fxyswn(contempsF(i3),:)];
                        end
                    end
                end
            end
        end
    end
end
end
