function Sensor = SensorModel(model)
% DESCRIPTION
%   Implements a lookup table for inertial sensor noise parameters.
%   Different model is defined randomly but close to real sensors.
%
% ARGUMENT
%   model = Sensor type or model number ('Ideal', 'RandownWalk''Sensor1','Sensor2','Sensor3','Sensor4')
%
% RETURN
%   Sensor = structure containing model parameters
%
switch model
    
    case 'Ideal'
        Gyro.Bias.TurnOn=0; %radian/sec
        Gyro.Bias.InRun=0; %radian/sec
        Gyro.Bias.Tau=Inf; %sec
        Gyro.Scale.TurnOn=0; %parts
        Gyro.Scale.InRun=0; %part
        Gyro.Scale.Tau=Inf; %sec
        Gyro.RandomWalk=0; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=0; %meters/sec^2
        Accel.Bias.InRun=0; %meters/sec^2
        Accel.Bias.Tau=Inf; %sec
        Accel.Scale.TurnOn=0; %parts
        Accel.Scale.InRun=0; %parts
        Accel.Scale.Tau=Inf; %sec
        Accel.RandomWalk=0; %meters/sec/sqrt(sec)
        
    case 'RandomWalk'
        Gyro.Bias.TurnOn=0; %radian/sec
        Gyro.Bias.InRun=0; %radian/sec
        Gyro.Bias.Tau=Inf; %sec
        Gyro.Scale.TurnOn=0; %parts
        Gyro.Scale.InRun=0; %part
        Gyro.Scale.Tau=Inf; %sec
        Gyro.RandomWalk=1E-3; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=0; %meters/sec^2
        Accel.Bias.InRun=0; %meters/sec^2
        Accel.Bias.Tau=Inf; %sec
        Accel.Scale.TurnOn=0; %parts
        Accel.Scale.InRun=0; %parts
        Accel.Scale.Tau=Inf; %sec
        Accel.RandomWalk=1E-2; %meters/sec/sqrt(sec)
        
    case 'Sensor1'
        Gyro.Bias.TurnOn=(pi/180/3600)*3; %radian/sec
        Gyro.Bias.InRun=(pi/180/3600)*5; %radian/sec
        Gyro.Bias.Tau=100; %sec
        Gyro.Scale.TurnOn=(1E-6)*70; %parts
        Gyro.Scale.InRun=(1E-6)*100; %parts
        Gyro.Scale.Tau=100; %sec
        Gyro.RandomWalk=(pi/180/sqrt(3600))*0.05; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=(9.8E-3)*2; %meters/sec^2
        Accel.Bias.InRun=(9.8E-3)*1; %meters/sec^2
        Accel.Bias.Tau=60; %sec
        Accel.Scale.TurnOn=(1E-6)*125; %parts
        Accel.Scale.InRun=(1E-6)*600; %parts
        Accel.Scale.Tau=60; %sec
        Accel.RandomWalk=(1/sqrt(3600))*0.02; %meters/sec/sqrt(sec)
        
    case 'Sensor2'
        Gyro.Bias.TurnOn=(pi/180/3600)*1; %radian/sec
        Gyro.Bias.InRun=(pi/180/3600)*0.35; %radian/sec
        Gyro.Bias.Tau=100; %sec
        Gyro.Scale.TurnOn=(1E-6)*100; %parts
        Gyro.Scale.InRun=0; %parts
        Gyro.Scale.Tau=Inf; %sec
        Gyro.RandomWalk=(pi/180/sqrt(3600))*0.07; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=(9.8E-3)*0.2; %meters/sec^2
        Accel.Bias.InRun=(9.8E-3)*0.05; %meters/sec^2
        Accel.Bias.Tau=60; %sec
        Accel.Scale.TurnOn=(1E-6)*300; %parts
        Accel.Scale.InRun=0; %parts
        Accel.Scale.Tau=Inf; %sec
        Accel.RandomWalk=(1/sqrt(3600))*0.03; %meters/sec/sqrt(sec)
        
    case 'Sensor3'
        Gyro.Bias.TurnOn=(pi/180/3600)*0.003; %radian/sec
        Gyro.Bias.InRun=(pi/180/3600)*0.003; %radian/sec
        Gyro.Bias.Tau=100; %sec
        Gyro.Scale.TurnOn=(1E-6)*5; %parts
        Gyro.Scale.InRun=0; %parts
        Gyro.Scale.Tau=Inf; %sec
        Gyro.RandomWalk=(pi/180/sqrt(3600))*0.001; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=(9.8E-3)*0.025; %meters/sec^2
        Accel.Bias.InRun=(9.8E-3)*0.01; %meters/sec^2
        Accel.Bias.Tau=60; %sec
        Accel.Scale.TurnOn=(1E-6)*5; %parts
        Accel.Scale.InRun=0; %parts
        Accel.Scale.Tau=Inf; %sec
        Accel.RandomWalk=(1/sqrt(3600))*0.003; %meters/sec/sqrt(sec)
        
    case 'Sensor4'
        Gyro.Bias.TurnOn=(pi/180/3600)*200; %radian/sec
        Gyro.Bias.InRun=(pi/180/3600)*200; %radian/sec
        Gyro.Bias.Tau=100; %sec
        Gyro.Scale.TurnOn=(1E-6)*1000; %parts
        Gyro.Scale.InRun=(1E-6)*1000; %parts
        Gyro.Scale.Tau=100; %sec
        Gyro.RandomWalk=(pi/180/sqrt(3600))*3; %radians/sqrt(sec)
        
        Accel.Bias.TurnOn=(9.8E-3)*25; %meters/sec^2
        Accel.Bias.InRun=(9.8E-3)*3.3; %meters/sec^2
        Accel.Bias.Tau=60; %sec
        Accel.Scale.TurnOn=(1E-6)*3000; %parts
        Accel.Scale.InRun=(1E-6)*3000; %parts
        Accel.Scale.Tau=60; %sec
        Accel.RandomWalk=(1/sqrt(3600))*0.09; %meters/sec/sqrt(sec)
        
    otherwise
        error('invalid Sensor model name');
end

%store component statistics in the Sensor structure
Sensor.Gyro=Gyro;
Sensor.Accel=Accel;

return