function [Spektrum_Table] = measure_CS2000(com_spectro, wdh_Messung)
addpath('A01_Methods')
addpath('A01_Methods/Driver_CS2000')
for j = 1:wdh_Messung
    i = 0;
    message1 = '';
    disp('Connect to Spectrometer...')
    [message, serial_spec] = CS2000_initConnection(com_spectro);
    
    if ~(strcmp( message, 'Sorry, no connection.'))
        disp('Spectrometer connected')
        pause(1)
        while ~strcmp(message1,'Measurement has been completed.')
            [message1, message2, Gesamtspektrum_mess, colorimetricData] = CS2000_measure();
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
        Gesamtspektrum(:, j) = Gesamtspektrum_mess';
        fclose(serial_spec);
        disp(['Messung '  num2str(j) ' erfolgreich'])
    end
end
fclose(serial_spec);
Wavelength = (380:780)';
Spektrum_Table = table(Wavelength, Gesamtspektrum);

if j > 1
    Spektrum_Table = splitvars(Spektrum_Table);
end

end
