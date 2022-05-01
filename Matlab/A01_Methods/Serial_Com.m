classdef Serial_Com
    
    properties
        COM_Port;
        BAUDRATE;
        Serial_Port_Object;
    end
    
    methods
        % Konstruktor
        function self = Serial_Com(COM_Port, BAUDRATE)
            self.COM_Port = COM_Port;
            self.BAUDRATE = BAUDRATE;
            self.Serial_Port_Object = serial(self.COM_Port,'BaudRate',self.BAUDRATE,...
                'DataBits', 8, 'Parity', 'none', 'StopBits', 1, 'Terminator', '>');
        end
        
        %{
        Funktion: Öffnet einen Port zum Mikrocontroller
        Eingabe:  -
        Ausgabe:  -
        %}
        function open_Serial_Port(self)
            fopen(self.Serial_Port_Object);
        end
        
        %{
        Funktion: Beendet die Verbindung zum Mikrocontroller
        Eingabe:  -
        Ausgabe:  -
        %}
        function close_Serial_Port(self)
            fclose(self.Serial_Port_Object);
            delete(self.Serial_Port_Object);
        end
        
        %{
        Funktion: Setzt einen Blitz im laufenden Betrieb für eine bestimmte Dauer
        und geht dann wieder zurück auf seinen Ausgangszustand
        Eingabe: Channel - Welcher Kanal, Time - Zeit in ms, PWM zwischen 0 und 1
        Ausgabe: wie bei den anderen Methoden auch
        %}
        function [out, time_gesamt] = set_flash(self, Channel, Time, PWM)
            
            tic
            Array = [Channel, Time, PWM];
            if PWM <=1 && PWM  >=0
                if Channel >= 1 && Channel <= 15
                    
                    Protokoll_flash = '<B,%.0f,%.0f,%.3f';
                    
                    Message_flash = sprintf(Protokoll_flash, Channel, Time, PWM);
                    
                    fprintf(self.Serial_Port_Object, Message_flash);
                    
                    time_matlab = toc;
                    
                    Ausgabe_Serial = fscanf(self.Serial_Port_Object);
                    out_numbers_String = split(Ausgabe_Serial,',');
                    out_numbers_String_2 = regexp(Ausgabe_Serial,'\d*','Match');
                    
                    if isequal(str2double(out_numbers_String(2:4)'), Array)
                        
                        out = 1; % Alles gut gelaufen
                        
                        % Zeit in Millisekunden vom Mikrocontroller
                        time = str2double(out_numbers_String_2(5))/1000;
                        
                        % Umgerechnet in Millisekunden, da in Sekunden vorlag
                        time_matlab = time_matlab*1000;
                        
                        % Zeiten vom Mikrocontroller und Matlab werden addiert
                        time_gesamt = time + time_matlab;
                        
                        fprintf('Status Flash: Ok - Dauer %.2f Millisekunden \n', time_gesamt);
                    else
                        out = 0; % Schlecht. Etwas schief gelaufen
                        disp("Error")
                        
                    end
                end
            else
               disp("Eingabe Fehlerhaft") 
            end           
        end
        
        %{
        Funktion: Setzt den Peal-Strom in der Leuchte durch Veränderung des Wiederstandes
        Eingabe:  15 Stromwerte werden eingetragen zwischen 0 bis 13 als 1D-Array
        Ausgabe:  out: 1 wenn alles gut gelaufen ist
                       0 wenn die Werte nicht stimmen
                  time: Die Zeit die benötigt wurde um den Befehl auszuführen
        %}
        function [out, time_gesamt] = set_Current(self, Current_Array)
            if length(Current_Array) == 15
                tic
                % Checken, ob Zahlen größer 13 vorliegen, ansonsten alles runtersetzen
                Current_Array(Current_Array > 13) = 13;
                Current_Array(Current_Array < 0) = 0;
                
                % Erst mal alle Zahlen checken, ob diese größer sind
                Zwischen_array = Current_Array > 9;
                Zwischen_array([1:6, 12:15]) = 0;
                Current_Array(Zwischen_array) = 9;
                % Checken, ob die Kanäle 7 bis 11 nicht größer sind als
                
                Protokoll_Current = '<S,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f';
                
                Message_Current = sprintf(Protokoll_Current, Current_Array(1), Current_Array(2), Current_Array(3),...
                    Current_Array(4), Current_Array(5), Current_Array(6), Current_Array(7), Current_Array(8),...
                    Current_Array(9), Current_Array(10), Current_Array(11), Current_Array(12), Current_Array(13),...
                    Current_Array(14), Current_Array(15));
                
                fprintf(self.Serial_Port_Object, Message_Current);
                
                time_matlab = toc;
                
                Ausgabe_Serial = fscanf(self.Serial_Port_Object);
                
                out_numbers_String = regexp(Ausgabe_Serial,'\d*','Match');
                
                if isequal(str2double(out_numbers_String(1:15)), Current_Array)
                    out = 1; % Alles gut gelaufen
                    
                    % Zeit in Millisekunden vom Mikrocontroller
                    time = str2double(out_numbers_String(16))/1000;
                    
                    % Umgerechnet in Millisekunden, da in Sekunden vorlag
                    time_matlab = time_matlab*1000;
                    
                    % Zeiten vom Mikrocontroller und Matlab werden addiert
                    time_gesamt = time + time_matlab;
                    
                    fprintf('Status Strom: Ok - Dauer %.2f Millisekunden \n', time_gesamt);
                else
                    out = 0; % Schlecht. Etwas schief gelaufen
                    disp("Error")
                end
                
            else
                disp("Vektorgröße nicht passend!")
            end
        end
        
        %{
        Funktion: Setzt die PWM
        Eingabe:  15 PWM Werte zwischen 0.00 bis 1.0 (float-Werte) als 1D-Array
        Ausgabe:  out: 1 wenn alles gut gelaufen ist
                       0 wenn die Werte nicht stimmen
                  time: Die Zeit die benötigt wurde um den Befehl auszuführen
        %}
        function [out, time_gesamt] = set_PWM(self, PWM_Array)
            if length(PWM_Array) == 15
                tic
                % Checken, ob Zahlen größer 1 vorliegen, ansonsten alles runtersetzen
                PWM_Array(PWM_Array > 1) = 1;
                PWM_Array(PWM_Array < 0) = 0;
                
                Protokoll_PWM = '<P,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f';
                
                Message_PWM = sprintf(Protokoll_PWM, PWM_Array(1), PWM_Array(2), PWM_Array(3), PWM_Array(4),...
                    PWM_Array(5), PWM_Array(6), PWM_Array(7), PWM_Array(8),PWM_Array(9),...
                    PWM_Array(10), PWM_Array(11), PWM_Array(12), PWM_Array(13), PWM_Array(14), PWM_Array(15));
                
                fprintf(self.Serial_Port_Object, Message_PWM);
                time_matlab = toc;
                
                Ausgabe_Serial = fscanf(self.Serial_Port_Object);
                out_numbers_String = split(Ausgabe_Serial,',');
                
                threshold = 1e-5;
                Vergleichsvektor = str2double(out_numbers_String(2:16))';
                if all(abs(Vergleichsvektor(:) - PWM_Array(:))<=threshold)
                    
                    out = 1; % Alles gut gelaufen
                    
                    % Zeit in Millisekunden vom Mikrocontroller
                    time_string = regexp(out_numbers_String(17),'\d*','Match');
                    time_string{1};
                    time = str2double(time_string{1})/1000;
                    
                    % Umgerechnet in Millisekunden, da in Sekunden vorlag
                    time_matlab = time_matlab*1000;
                    
                    % Zeiten vom Mikrocontroller und Matlab werden addiert
                    time_gesamt = time + time_matlab;
                    
                    fprintf('Status PWM: Ok - Dauer %.2f Millisekunden \n', time_gesamt);
                else
                    out = 0; % Schlecht. Etwas schief gelaufen
                    disp("Error")
                end
            else
                disp("Vektorgröße nicht passend")
            end
        end
        
        %{
        Funktion: Soll ein Testprogramm abspielen an der Leuchte, um alle Kanäle zu überprüfen
        Eingabe:  -
        Ausgabe:  -
        %}
        function check_Luminaire(self)
            PWM_up = 1.0;
            Current_up = 13;
            current_down = 4;
            
            for i = 1:15
                PWM_Array = zeros(1,15);
                Current_Array = zeros(1,15);
                
                PWM_Array(i) = PWM_up;
                self.set_PWM(PWM_Array);
                pause(0.5);
                
                Current_Array(i) = Current_up;
                self.set_Current(Current_Array);
                pause(0.5);
                
                Current_Array(i) = current_down;
                self.set_Current(Current_Array);
                pause(0.5);
            end
            self.set_PWM(zeros(1,15));
            self.set_Current(repmat(4,1,15));
        end
    end
    
end