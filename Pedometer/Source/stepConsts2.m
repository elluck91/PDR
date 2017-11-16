classdef stepConsts2
    % all the constants used but not internal/local ones
    properties (Constant)
       

        aFiltDefault = (round(stepConsts.aFiltDefault*10^stepConsts.N)/10^stepConsts.N);
        bFiltDefault = (round(stepConsts.bFiltDefault*10^stepConsts.N)/10^stepConsts.N);
        
        aFiltA = (round(stepConsts.aFiltA*10^stepConsts.N)/10^stepConsts.N);
        bFiltA = (round(stepConsts.bFiltA*10^stepConsts.N)/10^stepConsts.N);

        aFiltB = (round(stepConsts.aFiltB*10^stepConsts.N)/10^stepConsts.N);
        bFiltB = (round(stepConsts.bFiltB*10^stepConsts.N)/10^stepConsts.N);

        aFiltC = (round(stepConsts.aFiltC*10^stepConsts.N)/10^stepConsts.N);
        bFiltC = (round(stepConsts.bFiltC*10^stepConsts.N)/10^stepConsts.N);
   
        aFiltD = (round(stepConsts.aFiltD*10^stepConsts.N)/10^stepConsts.N);
        bFiltD = (round(stepConsts.bFiltD*10^stepConsts.N)/10^stepConsts.N);
        
        
    end
end