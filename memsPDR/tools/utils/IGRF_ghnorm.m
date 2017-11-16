function IGRF_ghnorm(fname)
%function to normalize g,h,dg,dh coefficient to minimze the computation in
%real code - this file is reading the coeffieint (source from
%http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html) and stored normalized
%coeffcient in igrfSgh.txt file, please update emptyIGRFmodel.m file with
%this coeff in case of update or after 2020
% // pre-calculate the ratio between gauss-normalized and schmidt quasi-normalized
% // associated Legendre functions as they depend only on the degree of the model.
if(nargin < 1)
    disp('default input file');
    fname = 'IGRF12coeffs.csv';
end

fid = fopen(fname);
if(fid<0)
    error('Not able to open input file')
end
gh = []; n=0; m =0;val =0; sv=0; 
tline = fgetl(fid);
tline = fgetl(fid);
nL = 0;
while(1)
    tline = fgetl(fid);
    if(~ischar(tline) | tline == -1)
        break;
    end
    d = textscan(tline, '%c,%f,%f,%f,%f');
    if(~isempty(d))
        nL = nL+1;
        gh = strvcat(gh, d{1,1});
        %gh(nL) = d{1,1};
        n(nL,1) = d{1,2};
        m(nL,1) = d{1,3};
        val(nL,1) = d{1,4};
        sv(nL,1) = d{1,5};
    end
end
fclose(fid);

N=max(n);
g=zeros(N,N+1);
h=zeros(N,N+1);
hsv=zeros(N,N+1);
gsv=zeros(N,N+1);
for x=1:length(gh)
    if strcmp(gh(x),'g')
        g(n(x),m(x)+1) = val(x);
        gsv(n(x),m(x)+1) = sv(x);
    else
        h(n(x),m(x)+1) = val(x);
        hsv(n(x),m(x)+1) = sv(x);
    end
end
count=1;
S = zeros(N,N+1);
nMax = N*(N+1)/2+N;
gS = zeros(nMax,6);
for n=1:N
    for m=0:n
        if m>1
            S(n,m+1) = S(n,m)*((n-m+1)/(n+m))^0.5;
        elseif m>0
            S(n,m+1) = S(n,m)*(2*(n-m+1)/(n+m))^0.5;
        elseif n==1
            S(n,1) = 1;
        else
            S(n,1) = S(n-1,1)*(2*n-1)/(n);
        end
        gS(count,1) = n; gS(count,2)=m;
        gS(count,3)=g(n,m+1)*S(n,m+1); 
        gS(count,5)=gsv(n,m+1)*S(n,m+1);
        gS(count,4)=h(n,m+1)*S(n,m+1); 
        gS(count,6)=hsv(n,m+1)*S(n,m+1);
        count=count+1;
    end
end
disp('Writing igrfSgh.txt file')
dlmwrite('igrfSgh.txt',gS,'\t')
end