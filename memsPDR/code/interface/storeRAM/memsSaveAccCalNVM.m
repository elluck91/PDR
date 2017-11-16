function memsSaveAccCalNVM(accCal, logging)
%this function is dependended on platform, in embedded platform, it is
%require to implment this in order to save acc cal info
accCalNVM = emptyAccCalNVM;
accCalNVM.infoType = 1; %for saving
accCalNVM.calInfo = accCal.calInfo;
accCalNVM.calTime_s = accCal.calTime_s;
%call save functino here
%saveInNVM(accCalNVM)
%log the message 10251 here
end