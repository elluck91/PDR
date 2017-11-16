function uH = memsGetUserHeading(memsState,timestamp)
uH = emptyUserHeadingOP;
uH.t = memsState.moduleState.pdrOutput.heading.t;
uH.valid = memsState.moduleState.pdrOutput.heading.valid;
uH.heading = memsState.moduleState.pdrOutput.heading.heading;
uH.heading_conf = memsState.moduleState.pdrOutput.heading.heading_conf;
end