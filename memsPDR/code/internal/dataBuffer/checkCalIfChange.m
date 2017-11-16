function isChange = checkCalIfChange(cal, data, biasTol, sfTol)

isChange = 1;

biasTol = biasTol/data.info.SF;
for n = 1:3
    if(abs(cal.bias(n)- data.cal.bias(n)) > biasTol)
        return;
    end
end

for n = 1:3
    if(abs(cal.SF(n,n)- data.cal.SF(n,n)) > sfTol)
        return;
    end
end
if(cal.calStatus ~= data.cal.calStatus)
    return;
end
isChange = 0;
end