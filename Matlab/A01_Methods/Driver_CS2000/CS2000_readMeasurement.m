% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.

function [measuredData, colorimetricNames] = CS2000_readMeasurement()
%
%Reads measurement data from instrument. Reads all 4 blocks of spectral 
%data and any set of colorimetric data. 
    
global s

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

spectralData = cell2mat(spectralData);


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


%create CS2000Measurement object:
measuredData = CS2000Measurement(clock, spectralData, colorimetricData);
colorimetricNames = properties(measuredData.colorimetricData);


%-----------------------Plot all spectral data:---------------------------
plot(measuredData);

%-----------------------Read aperture:------------------------------------
measuredData.aperture = CS2000_readApertureStop;

end