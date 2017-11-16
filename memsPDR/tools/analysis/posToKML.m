function posToKML(posFix, varargin)

topdir  = './';
fname   = 'pos.kml';
color   = 'b';
lineWidth = 4;
plotConf = 0;

% http://kml4earth.appspot.com/icons.html?_sm_au_=iVVrrMQ7KQN9r5qF
for n = 1:2:nargin-1
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            %to set top dir where file is stores
        case 'topdir'
            topdir = varargin{n+1};
        case 'color'
            color = varargin{n+1};
            %to set color
        case 'lineWidth'
            lineWidth = varargin{n+1};
        case 'plotConf'
            plotConf = varargin{n+1};
        otherwise
            error(['unknown arg: ' varargin{n}])
    end
end

topdir = strtrim(topdir);
if(~exist(topdir,'dir'))
    error([topdir ' directory not found:exit']);
end

if (topdir(end) ~= '/' && topdir(end) ~= '\')
    topdir = [topdir '/'];
end

fileID = fopen([topdir fname],'w');

if(fileID==-1)
    error([fname ' file not able to open:exit']);
end

fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?> \n');
fprintf(fileID,' <kml xmlns="http://earth.google.com/kml/2.0">  \n');
fprintf(fileID,' <Document> \n');
%icon
fprintf(fileID,'<Style id="red"><IconStyle><color>ff0000ff</color><scale>.75</scale></IconStyle></Style> \n');
fprintf(fileID,'<Style id="blue"><IconStyle><color>ffff0000</color><scale>.75</scale></IconStyle></Style> \n');
fprintf(fileID,'<Style id="green"><IconStyle><color>ff00ff00</color><scale>.75</scale></IconStyle></Style> \n');
%line
fprintf(fileID, ...
    ['<Style id="RedHalfOpLine"><LineStyle><color>7f0000ff</color><width>4</width>' ...
    '<gx:labelVisibility>0</gx:labelVisibility></LineStyle></Style> \n']);
fprintf(fileID, ...
    ['<Style id="LineHalfOpLine"><LineStyle><color>50F0FF14</color><width>2</width>' ...
    '<gx:labelVisibility>0</gx:labelVisibility></LineStyle></Style> \n']);

% labelVisibility - to display the test
% width - wifht of line
% <color>ff007db3</color> opaque, BGR
% ff- full opaque (0-255)
% scale - scale of icon
locScale = 360/2^32;
for i = 1:length(posFix)
    if posFix(i).valid
        fprintf(fileID,'<Placemark> \n');
        fprintf(fileID,' <TimeSpan> \n');
        fprintf(fileID,['<begin>2015-09-19T08:' '%02d' ':' '%02d' 'Z</begin> \n'], floor(i/60), mod(i,60));
        fprintf(fileID,['<end>2015-09-19T08:' '%02d' ':' '%02d' 'Z</end> \n'], floor((i+1)/60), mod(i+1,60));
        fprintf(fileID,' </TimeSpan> \n');
        fprintf(fileID,' <styleUrl>%s</styleUrl> ',color);
        fprintf(fileID,' <description>Epoch = %d </description>',i);
        fprintf(fileID,'<Point><coordinates> %f, %f, 0 </coordinates></Point> \n', posFix(i).lonCir*locScale, posFix(i).latCir*locScale);
        fprintf(fileID,' </Placemark> \n');
        if(plotConf)
            addEllipse(fileID, posFix(i));
        end
    end
end

fprintf(fileID,'<Placemark> \n');
fprintf(fileID,'<styleUrl>#RedHalfOpLine</styleUrl> \n');
fprintf(fileID,'<LineString> \n');
fprintf(fileID,'<extrude>1</extrude> \n');
fprintf(fileID,'<tessellate>1</tessellate> \n');
fprintf(fileID,'<coordinates>');
for i = 1:length(posFix)
    if posFix(i).valid
        fprintf(fileID,'%f,%f,0 \n',posFix(i).lonCir*locScale, posFix(i).latCir*locScale);
    end
end
fprintf(fileID,'</coordinates> \n');
fprintf(fileID,'</LineString> \n');
fprintf(fileID,'</Placemark> \n');
fprintf(fileID,'<styleUrl>red</styleUrl> ');
fprintf(fileID,'<description>Trajectory</description>');


% prepare the footer of the KML file
fprintf(fileID,'  </Document> \n');
fprintf(fileID,'  </kml> \n');

%close the file
fclose(fileID);
end

function addEllipse(fileID, pos)
totalPt = 25;
heading = 30*pi/180;
major_cm = 70;
minor_cm = 30;
U = 0;
yaw = linspace(0, 2*pi, totalPt);

locScale = 360/2^32;
lla     = emptyLLA;
lla.lat = pos.latCir*locScale;
lla.lon = pos.lonCir*locScale;
lla.alt = pos.alt_cm/100;

major_cm = pos.posConf.major_cm;
minor_cm = pos.posConf.minor_cm;
heading  = pos.posConf.ang_deg*pi/180;
major_cm = max(major_cm,1);

fprintf(fileID,'<Placemark> \n');
%fprintf(fileID,' <name>unextruded</name> \n');
fprintf(fileID,'<styleUrl>#LineHalfOpLine</styleUrl> \n');
fprintf(fileID,' <LineString> \n');
fprintf(fileID,'  <extrude>1</extrude> \n');
fprintf(fileID,'  <tessellate>1</tessellate> \n');
fprintf(fileID,'<coordinates>');

for n = 1:totalPt
    x = major_cm*cos(yaw(n))/100;
    y = minor_cm*sin(yaw(n))/100;
    N = x*cos(heading) - y*sin(heading);
    E = x*sin(heading) + y*cos(heading);
    ltln = denuTodllh(E,N,U,lla);
    fprintf(fileID,'%f,%f,0 ', ltln.lon, ltln.lat);
end
fprintf(fileID,'</coordinates> \n');
fprintf(fileID,'  </LineString> \n');
fprintf(fileID,' </Placemark> \n');
end