% This function can be used to measure the base spectra of the 15-channel
% LED luminaire, usefull to develop an offline model of the luminaire for
% spectral optimisation tasks.

% ARGUMENTS:
% com_spectro: is the COM-PORT of the CS2000 spectroradiometer. Example 'COM5'
% com_Leuchte: is the COM-PORT of the luminaire. Example 'COM3'
% Array_PWM_Steps: Steps of the PWM. Example [0:0.05:1]
% Array_Current_Steps: Steps of the current. Example 1 or 1:1:13
% Array_Channels: Steps of channels. Example [1:15]

% EXAMPLE:
% LumCharacterization('COM5', 'COM3', [0:0.05:1], 1, [1:15])

% OUTPUT;
% The result will be saved -> save(['A00_Data/Luminaire_RawData/Characterization_',date,'.mat'],'data');

function [outputArg1,outputArg2] = LumCharacterization(com_spectro,...
    com_Leuchte,...
    Array_PWM_Steps,...
    Array_Current_Steps,...
    Array_Channels)

% Add folder to path ------------------
addpath("A00_Data")
addpath("A01_Methods")
addpath("A01_Methods/Driver_CS2000")
% -------------------------------------

%--------------------------------------------------------------------------
%com_spectro='COM5'; %COM port of CS2000 Spectrometer
%com_Leuchte='COM3'; %COM port of 15 Chanel
%Array_PWM_Steps = [0:0.05:1];
%Array_Current_Steps = 1;
%Array_Channels=[1:15];
pausetime=3; %burn in time
date=[datestr(now,'dd-mm-yyyy-HHMM') 'UHR'];
%--------------------------------------------------------------------------

sz = [length(Array_Current_Steps) length(Array_PWM_Steps)+1];
varTypes(1)={'double'};
varTypes(2:length(Array_PWM_Steps)+1)={'cell'};
varNames={'Current'};
for i=1:length(Array_PWM_Steps)
    varName=['PWM_',num2str(Array_PWM_Steps(i)*1000)];
    varNames(i+1:length(Array_PWM_Steps)+1)={varName};
end
data_table_0=table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
data_table_0.Current=Array_Current_Steps';

data=struct;

Serial_Object = Serial_Com(com_Leuchte, 115200);

try
    Serial_Object.open_Serial_Port();
    [Ausgabe_Strom, Zeit_Strom] = Serial_Object.set_Current(ones(1,15));
    
    %addpath('CS2000');
    disp('Connect to Spectrometer...')
    message = CS2000_initConnection(com_spectro);
    %
    if Ausgabe_Strom == 1
        if ~(strcmp( message, 'Sorry, no connection.'))
            disp('Spectrometer connected')
            pause(1)
            
            %
            for channel_index=1:length(Array_Channels)
                
                data_table=data_table_0;
                data_table2=data_table_0;
                
                for current_index=1:length(Array_Current_Steps)
                    [Ausgabe_Strom, Zeit_Strom] = Serial_Object.set_Current(repmat(Array_Current_Steps(current_index),1,15));
                    %
                    PWM_Array_0 = zeros(1,15);
                    
                    for PWM_index = 1:length(Array_PWM_Steps)
                        
                        PWM_Array = PWM_Array_0;
                        PWM_Array(channel_index)=(Array_PWM_Steps(PWM_index));
                        
                        name_Channel=['Channel_',num2str(channel_index)];
                        name_Current = ['Current_', num2str(Array_Current_Steps(current_index))];
                        name_PWM = varNames(PWM_index+1);
                        
                        disp({[name_Channel ' ' name_Current ' ' name_PWM{1}]});
                        
                        % Leuchte einstellen
                        [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(PWM_Array);
                        %
                        if Ausgabe_PWM == 1 && Ausgabe_Strom == 1
                            if PWM_index==1
                                spectralData=zeros(1,401);
                                colorimetricData=zeros(1,24);
                            else
                                %burn in time
                                pause(pausetime);
                                %CS2000 Measurement
                                i=0;
                                message1 = 'NOT';
                                while ~strcmp(message1,'Measurement has been completed.')
                                    [message1, message2, spectralData, colorimetricData] = CS2000_measure();
                                    i=i+1;
                                    if i>=5
                                        %Reconnect CS2000
                                        disp('Error, reconnect to Spectrometer...')
                                        message = CS2000_initConnection( com_spectro );
                                        %Check if CS2000 is connected
                                        if ~(strcmp( message, 'Sorry, no connection.'))
                                            disp('Spectrometer reconnected')
                                            pause(1)
                                        else
                                            error('Could not reconnect to spetrometer');
                                        end
                                    end
                                end
                            end
                            disp('Messung erfolgreich')
                            
                            data_table.(cell2mat(name_PWM))(current_index) = {spectralData};
                            data_table2.(cell2mat(name_PWM))(current_index) = {colorimetricData};
                            %data.(name).colorimetricData=colorimetricData;
                        else
                            disp("ACHTUNG PWM KONNTE NICHT EINGESTELLT WERDEN!!!-------")
                            disp(name_Channel)
                            disp(name_PWM)
                            disp('-------------------------------------------------------')
                            break
                        end
                    end
                end
                data.(name_Channel)=data_table;
                data.([name_Channel,'_colorimetricData'])=data_table2;
                
                save(['A00_Data/Luminaire_RawData/Characterization_',date,'.mat'],'data');
                
            end
            disp('Messung erfolgreich beendet')
            PWM_Array = PWM_Array_0;
            [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(PWM_Array);
            
        end
    else
        disp("Mikrocontroller antwortet beim Strom nicht")
    end
catch
    disp('Error!')
    try
        PWM_Array = PWM_Array_0;
        [Ausgabe_PWM, Zeit_PWM] = Serial_Object.set_PWM(PWM_Array);
    catch
    end
end

if length(instrfind) > 0
    fclose(instrfind);
    delete(instrfind);
end

end

