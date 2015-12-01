function Ds=FindVel(trace,ind1)

t1 = max(1,ind1-4);
x1 = trace.xpos(t1);
y1 = trace.ypos(t1);

t2 = min(ind1+4,length(trace.xpos));
x2 = trace.xpos(t2);
y2 = trace.ypos(t2);

if t1==t2
    Ds=[NaN, NaN];
    return
end
Ds(1)=(x2-x1)/(t2-t1);
Ds(2)=(y2-y1)/(t2-t1);
