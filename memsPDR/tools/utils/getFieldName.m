function fieldName = getFieldName(id)
fieldName = '';
msgIds = properties(memsIDs);
for n = 1:length(msgIds)
    eval(['thisId = memsIDs.' msgIds{n} ';']);
    if(id==thisId)
        fieldName = msgIds{n};
        break;
    end
end
end