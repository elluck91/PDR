function step = memsGetStep(memsState,timestamp)
step = emptyStepOP;
steps = getStep(memsState.moduleState.stepDetection);
step.stepCount = steps.Nsteps;
if(steps.bufferIndex>0)
    step.tLastStep = steps.steps(steps.bufferIndex).time;
    step.step_conf = steps.steps(steps.bufferIndex).conf;
else
    step.tLastStep = steps.Time;
    step.step_conf = 0;
end
end