function nn = look(n,o)
global ord
if o == ord(end)
    nn = o;
else
    nn = o+3-2*n;
end
end