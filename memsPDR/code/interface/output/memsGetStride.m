function stride = memsGetStride(memsState,timestamp)
stride = emptyStrideOP;
% steps = getStep(memsState.moduleState.stepDetection);
% 
% for n = 1:nSteps
%     indX = mod(steps.bufferIndex - nSteps + n-1,steps.NHistMax)+1;
%     step = steps.steps(indX);
%     state.pdrOutput.refTag.t = step.time;
%     stride = getStrideLength(state.strideLength, step, logging);
% end

stride.L_cm = 0;
end