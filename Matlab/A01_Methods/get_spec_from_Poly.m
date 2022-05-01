% This method is used to interpolate the spectral data
% Eingabe einer Kanal_Zahl und einer PWM, dann wird das Spektrum ausgegeben
function [ Spektrum ] = get_spec_from_Poly(PWM_Zahl, Datensatz, Poly)
Current_CH = Datensatz;
Step_max = height(Current_CH);
% Empty Table für die Werte
Wavelength = (380:780)';
Strahldichte =  repmat(0,1,length(Wavelength))';
Spektrum = table(Wavelength, Strahldichte);
% Erzeugen eines leeren Arrays, um die Strahldichten hinzuzufügen
Strahldichte_Vektor = zeros(Step_max, size(PWM_Zahl, 2));
% Das sind die PWM Schritte aus dem Header rausgezogen
x = str2double(extractAfter(Current_CH.Properties.VariableNames(2:end),"PWM_"))/1000;
% Schleife, da fuer jede Wellenlaenge ein Wert benötigt wird
for Step = 1:Step_max    
    % Variable ist definiert als pro Wellenlänge über alle gemessenen PWM Schritte
    y = Current_CH{Step, 2:end};    
    % Bestimmen der Variable für den gewollten PWM-Wert
    % Durch 1000 geteilt, da die Methode nur X-Werte zwischen 0 und 1 aktzeptiert
    [Polyfit_Model] = polyfit(x, y, Poly);
    [~,gof] = fit(x',y',['poly',num2str(Poly)]);
    if(gof.rsquare > 0.99)      
        % Achtung bei der genauen Interpolation muss hier 1000
        PWM_Wert = polyval(Polyfit_Model, PWM_Zahl);      
        if(PWM_Wert > 0)          
            %Einsetzen der Werte in die leere Tabelle
            Strahldichte_Vektor(Step,:) = PWM_Wert;
        end       
    end   
end
Spektrum = [Spektrum, array2table(Strahldichte_Vektor)];
Spektrum.Properties.VariableNames(2:end) = sprintfc('PWM_%d', [0, round(PWM_Zahl*1000, 1)]);
end



