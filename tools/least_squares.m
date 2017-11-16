function [ coeff, resid, RSS ] = least_squares(x, y, N)

% This function fits a least-squares polynomial of degree N through
% a set of data where x and y are the coordinates.

% Output: set of coefficients c0, c1,...,cN of the  polynomial 
% PN(x) = c0 + c1*x + c2*x^2 + ...+ cN*x^N

n = size(x,1);
if n == 1
   n = size(x,2);
end

b   = zeros(N + 1,1);
for i = 1:n
   for j = 1:N + 1
      % sums of powers of x multiplied by y's
      b(j) = b(j) + y(i)*x(i)^(j-1);
   end
end

p   = zeros(2*N + 1,1);
for i = 1:n
   for j = 1:2*N + 1
      % sums of powers of x
      p(j) = p(j) + x(i)^(j-1);
   end
end

H   = zeros(N + 1, N + 1);
for i = 1:N + 1
   for j = 1:N + 1
      % distributing the sums of powers of x in a matrix H
      H(i,j) = p(i + j - 1);
   end
end

coeff = H\b;

% Residuals
% Use Horner's method for general case where X is an array.
yf = zeros(size(y));
for i = 1:n
    for j = N + 1:-1:1
        yf(i) = x(i) .* yf(i) + coeff(j);
    end
end

resid   = (yf - y);
RSS     = sum(resid.^2);

% LIMITS CHECK
if mean(x) < strideLengthConsts.freqRun_Hz
    activity = 1;
else
    activity = 2;
end
[ coeff ] = checkForLimits( coeff, activity ); 

