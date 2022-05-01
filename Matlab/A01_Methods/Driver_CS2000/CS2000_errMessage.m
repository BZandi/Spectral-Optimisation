% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



function [tf, errOutput] = CS2000_errMessage(ErrorCheckCode)
tf = strmatch('OK00',ErrorCheckCode);
if tf == 1
    errOutput = ' ';
else
   tf = 0;
end



a = strmatch('ER00',ErrorCheckCode);
if a == 1
    errOutput = 'Invalid command string or number of parameters received.';
end

a = strmatch('ER02',ErrorCheckCode);
if a == 1
    errOutput = 'Measurement error.';
end

a = strmatch('ER05',ErrorCheckCode);
if a == 1
    errOutput = 'No user calibration values.';
end

a = strmatch('ER10',ErrorCheckCode);
if a == 1
    errOutput = 'Over measurement range.';
end

a = strmatch('ER17',ErrorCheckCode);
if a == 1
    errOutput = 'Parameter error.';
end

a = strmatch('ER20',ErrorCheckCode);
if a == 1
    errOutput = 'No data.';
end

a = strmatch('ER51',ErrorCheckCode);
if a == 1
    errOutput = 'CCD Peltier abnormality.';
end

a = strmatch('ER52',ErrorCheckCode);
if a == 1
    errOutput = 'Temperatur count abnormality.';
end

a = strmatch('ER71',ErrorCheckCode);
if a == 1
    errOutput = 'Outside synchronization signal range.';
end

a = strmatch('ER81',ErrorCheckCode);
if a == 1
    errOutput = 'Shutter operation abnormality.';
end

a = strmatch('ER82',ErrorCheckCode);
if a == 1
    errOutput = 'Internal ND filter operation malfunction.';
end

a = strmatch('ER83',ErrorCheckCode);
if a == 1
    errOutput = 'Measurement angle abnormality.';
end

a = strmatch('ER99',ErrorCheckCode);
if a == 1
    errOutput = 'Program abnormality.';
end

end