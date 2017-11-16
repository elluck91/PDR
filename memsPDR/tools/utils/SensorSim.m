function [dataOut]=SensorSim(dataIn,Ts,Sensor,RANDOM_SEED)
% DESCRIPTION
%   Corrupts clean Sensor data with noise, according to a bias, scale, and random walk model.
%   The bias and scale factors vary slowly over time.
%
% ARGUMENTS
%    daatIn = clean sensor signal, either accel in (3-by-n) (meters/sec^2),
%    or gyro in rad/s
%    Ts = sampling period (1-by-1) (sec)
%    Sensor = structure produced by custom function SensorModel(), pass
%    either Sensor.Accel or Sensor.Gyro
%    RANDOM_SEED = define 0 or non negative number to use random number each time of run or  same random
%    number.
%
% RETURN
%   dataOut = noisy accelerometer/gyro output signal (meters/sec^2)/
%   (rad/sec)
%

if isempty(RANDOM_SEED)
    RANDOM_SEED = 0;
end

if RANDOM_SEED
    randn('seed',RANDOM_SEED);
end

if(isfield(Sensor, 'Gyro') || isfield(Sensor, 'Accel'))
    error('Please pass 3rd parameter either Sensor.Accel or Sensor.Gyr0 ');
end
%call the noise simulator for each sensor axis
[m,n]=size(dataIn);
if(m>n)
    dataIn = dataIn';
    [m,n]=size(dataIn);
    disp('Reshaping input data by trans since dimension is not right');
end
dataOut=zeros(m,n);
for i=1:m
    dataOut(i,:)=BSRsim(dataIn(i,:),Ts,Sensor);
end

return


%subfunction to implement the noise model
function Y=BSRsim(X,Ts,Sensor)
v = ver;
isContolToolbox = any(strcmp('control', {v.Name}));
N=size(X,2);

%bias model
TurnOn=Sensor.Bias.TurnOn;
Tau=Sensor.Bias.Tau;
InRunDriver=Sensor.Bias.InRun*sqrt(2/Tau/Ts-(1/Tau)^2);
if Tau<Ts
    warning('Sensor bias time constant should be longer than one time step');
end
BIAS=TurnOn*randn;
if(isContolToolbox)
    BIAS  = BIAS + lsim(ss(1-Ts/Tau,Ts*InRunDriver,1,0,Ts),randn(1,N))';
else
    a = 1-Ts/Tau;
    b = Ts*InRunDriver;
    c = 1;
    d = 0;
    xRand = zeros(1,N); f = randn(1,N); f1 = randn(1,N);
    for i = 1:N-1
        xRand(i+1) = a*xRand(i) + b*f(i)/sqrt(Ts);
        xRand(i+1) = c*xRand(i+1) + d*f1(i)/sqrt(Ts);
    end
    BIAS = BIAS + xRand;
end
%or d(x(n)) = a*x(n-1) + b*u; y = c*x(n)+ D*u; ss will create this
%structure
%(a,b,c,d) ; f = ss(a,b,c,d, Ts) , this will return structure wit f.a = a;
%f.b = b .... f.sample_time = Ts;
%lsim will replace u with rand(1,N)
%scale model
TurnOn=Sensor.Scale.TurnOn;
Tau=Sensor.Scale.Tau;
InRunDriver=Sensor.Scale.InRun*sqrt(2/Tau/Ts-(1/Tau)^2);
if Tau<Ts
    warning('Sensor scale factor time constant should be longer than one time step');
end
SCALE=TurnOn*randn;
if(isContolToolbox)
    SCALE = SCALE + lsim(ss(1-Ts/Tau,Ts*InRunDriver,1,0,Ts),randn(1,N))';
else
    disp('Control toolbox not found; using local function');
    a = 1-Ts/Tau;
    b = Ts*InRunDriver;
    c = 1;
    d = 0;
    xRand = zeros(1,N); f = randn(1,N); f1 = randn(1,N);
    for i = 1:N-1
        xRand(i+1) = a*xRand(i) + b*f(i)/sqrt(Ts);
        xRand(i+1) = c*xRand(i+1) + d*f1(i)/sqrt(Ts);
    end
    SCALE = SCALE + xRand;
end

%random walk
RandomWalk=Sensor.RandomWalk;
RANDOM=RandomWalk/sqrt(Ts)*randn(1,N);

%combined output
Y = X + BIAS + SCALE.*X + RANDOM;

return