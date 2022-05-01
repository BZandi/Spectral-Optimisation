% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.

function [message1, message2, spectralData, colorimetricData] =  CS2000_measure()
%First, the function performs only measurement (measurement data are not 
%output). A pre-measurement is taken to determine the required measurment 
%time and then the actual measurement begins automatically. 
%Second, the function reads measurement data from instrument. Reads all 
%4 blocks of spectral data and any set of colorimetric.
%
%Output: message1 = String containing information of success or error.
%        message2 = String containing pre-measurement time
%        measuredData = object of class CS2000Measurement containing time,
%                       spectral data and colorimetric data
%        colorimetricNames = object of class CS2000Measurement


global s
if exist( [pwd, '/Temp'], 'dir' ) ~= 7
    [ a, mess, messid ] = mkdir( [pwd, '/Temp'] )
    disp('Created Temp folder');
end
ERROR_OCCURRED = 0; % flag is set when error occured  

message1 = '';
message2 = '';

% ------------------------start measurement-------------------------------
fprintf(s,'MEAS,1');
answer = fscanf(s);                 


fid = fopen('Temp\answers.tmp', 'w');
fprintf(fid, answer);
fclose(fid);

[ErrorCheckCode, PreMeasTime] = textread('Temp\answers.tmp','%s %d','delimiter',',');
[tf, errOutput] = CS2000_errMessage(ErrorCheckCode);

if tf == 1
    message1 = 'Pre-Measurement has been completed.';
    message2 = sprintf( 'Pre-Measurement time was: %s seconds.', num2str(PreMeasTime) );
    ErrorCheckCode = fscanf(s,'%s');
    [tf, errOutput] = CS2000_errMessage(ErrorCheckCode);

    if tf == 1
        message1 = 'Measurement has been completed.';
    else
        message1 = errOutput;
    end
disp(message1);
disp(message2);
else
    message1 = errOutput;
    disp(message1);

end



%---------------read spectral data 380...780nm from instrument------------
p = 1;
for n = 1:4

    fprintf(s,['MEDR,1,0,', num2str(n)]);

    %Get instrument answer into file:
    answer = fscanf(s);

    fid = fopen('Temp\answers.tmp', 'w');
    fprintf(fid, answer);
    fclose(fid);

    %Get instrument error-check code:
    fid = fopen('Temp\answers.tmp','r');
    ErrorCheckCode = fscanf(fid,'%c',4);
    [tf, errOutput] = CS2000_errMessage(ErrorCheckCode);
    if tf ~= 1
        spectralData = errOutput;
        disp(errOutput);    
   %Get spectral data:
   elseif tf == 1
       if n == 4
           l = 101;
       else
          l = 100;
       end
       for m = p:((p+l)-1)
            garbage = fscanf(fid,'%c',1);
            spectralData{m} = fscanf(fid,'%e',8);
       end
    end    
    fclose(fid);   

    p = p+100;
end

if ( ~ischar( spectralData ) )
    spectralData = cell2mat( spectralData );
else
    ERROR_OCCURRED = 1;
    disp( sprintf( 'error reading spectral data: %s', spectralData ) );
end


%------------------------Read Colorimetric data:----------------------------

fprintf(s,'MEDR,2,0,00'); %00 = read all colometric data

%Get instrument answer into file:
answer = fscanf(s);

fid = fopen('Temp\answers.tmp', 'w');
fprintf(fid, answer);
fclose(fid);

%Get instrument error-check code:
fid = fopen('Temp\answers.tmp','r');
ErrorCheckCode = fscanf(fid,'%c',4);
for k = 1:24
    garbage = fscanf(fid,'%c',1);
    colorData{k} = fscanf(fid,'%e');
end
fclose(fid);

%Get colorimetric data:
[tf, errOutput] = CS2000_errMessage(ErrorCheckCode);
if tf == 1
    for p = 1:24        
        colorimetricData{p} = colorData{p};
    end
else
    colorimetricData = errOutput;
end

% 
% %create CS2000Measurement object:
% if ( ~ERROR_OCCURRED )
%     measuredData = CS2000Measurement(clock, spectralData, colorimetricData);
%     colorimetricNames = properties(measuredData.colorimetricData);
% else
%     measuredData = CS2000Measurement();
%     colorimetricNames = [];
% end


%-----------------------Plot all spectral data:---------------------------
%plot(measuredData);


end


