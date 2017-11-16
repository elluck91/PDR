function [ memsState] = memsSetAttKnobs(memsState, data, timestamp)
%interface function to set knobs
memsState.moduleState.attitude = setSpacePointKnobs(memsState.moduleState.attitude,data, timestamp, memsState.logging);
end