function memsSaveMagCalNVM(magCal, timestamp, logging)
%this function is dependended on platform, in embedded platform, it is
%require to implment this in order to save mag cal info
magCalNVM = emptyMagCalNVM;
magCalNVM.infoType = 1; %for saving
magCalNVM.calInfo = magCal.calInfo;
magCalNVM.calTime_s = magCal.calTime_s;
magCalNVM.calHist = magCal.calHist;

%call save functino here
%saveInNVM(magCalNVM)
%log the message 10253 here
end