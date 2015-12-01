function ord = gen_ord(num)
tmp = 1:num;
ord = zeros(1,num);
whch = 1;
i = 1;
while ~isempty(tmp)
    ord(i) = tmp(whch);
    tmp(whch) = [];
    if whch == 1
        whch = length(tmp);
    else
        whch = 1;
    end
    i = i+1;
end
end