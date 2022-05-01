% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.

function [message, s] = CS2000_initConnection( comPort )
% Initiates connection to the instrument.
% 
% Input: comPort = port where the instrument is connected via USB. See 
%                  hardware information on your pc or type in "instrfind"
%                  in your command window.
% Output: message = string with information about success or error.

global s

if nargin == 0
    comPort = 'COM4';
end

a = exist([path, '/Temp'], 'dir');
if a ~= 7
    [success, mess, messid] = mkdir('Temp');
    if success == 0    
        disp(mess);
        disp('not connected');  
    end
end

% if length(instrfind) > 0 
%     fclose(instrfind);
%     delete(instrfind);
% end
   
try
    s = serial(comPort);
    
    s.Terminator = 'LF'; 
    s.InputBufferSize = 1024;
    s.BytesAvailableFcnMode = 'terminator'; 
    s.BytesAvailableFcn = @instrcallback;
    s.Timeout = 240;

    fopen(s);
    fprintf(s,'RMTS,1');
    ErrorCheckCode = fscanf(s);                   
    [tf, errOutput] = CS2000_errMessage(ErrorCheckCode); 

    if tf == 1
        message = 'connected';    
    else
        message = errOutput;   
    end
    disp(message);
    
catch err
    disp(err.message)
    message = 'Sorry, no connection.';
    disp('Please choose another COM or make sure that instrument is connected.');    
end
   
    

     

end
  











