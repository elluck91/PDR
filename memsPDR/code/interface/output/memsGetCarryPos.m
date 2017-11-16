function carryPos = memsGetCarryPos(memsState,timestamp)
carryPos = emptyCarryPosOP;
x = getCarryPosition(memsState.moduleState.carryPos);
carryPos.carryPos = x.carryPosition;
carryPos.conf_val = x.conf;
end