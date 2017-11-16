function memsSaveGyrCalNVM(gyrCal, timestamp, logging)
%this function is dependended on platform, in embedded platform, it is
%require to implment this in order to save mag cal info
gyrCalNVM = emptyGyrCalNVM;
gyrCalNVM.infoType = 1; %for saving
gyrCalNVM.calTime_s = round(timestamp*0.001);
gyrCalNVM.calInfo = gyrCal;
%call save functino here
%saveInNVM(gyrCalNVM)
%log the message 10252 here
end