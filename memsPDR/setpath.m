% setpath()
% file to set the path in Matlab/Octave, run this file before using this tool
close all

global MAIN_DIR

MAIN_DIR = pwd;
addpath(MAIN_DIR);
addpath(genpath([MAIN_DIR,'/code/']));
addpath(genpath([MAIN_DIR,'/tools/']));
