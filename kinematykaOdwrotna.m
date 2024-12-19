function kinematykaOdwrotna()
clear;
clc;
close all;

% Definicja punktów startowego i końcowego w przestrzeni (x,y,z)
startPoint = dynamicWorkspaceInput("Punkt początkowy", 130.85, 0, 75);
endPoint   = dynamicWorkspaceInput("Punkt końcowy", -930.85, 0, 1975);

% Wywołanie rysowania przestrzeni roboczej robota 
przestrzen_robocza;

% Włączenie "hold on" aby dodać nowe elementy do istniejącego wykresu
hold on;

% Rysowanie punktów startowego (zielony punkt) i końcowego (niebieski punkt)
scatter3(startPoint(1), startPoint(2), startPoint(3), 50, 'g', 'filled'); 
scatter3(endPoint(1), endPoint(2), endPoint(3), 50, 'b', 'filled');

% Opcjonalne: dodanie legendy, opisów osi
xlabel('X'); ylabel('Y'); zlabel('Z');
legend('Przestrzeń robocza', 'Punkt startowy', 'Punkt końcowy', 'Location', 'best');

% Wyznaczenie punktów kontrolnych dla pełnej trasy
controlPoints = zeros(8, 3); % 8 punktów kontrolnych: 2 dla prostych, 6 dla krzywej Béziera

% Punkty prostych
controlPoints(1, :) = startPoint; % Punkt początkowy (start prostej początkowej)
controlPoints(2, :) = limitToWorkspace([(startPoint(1) + 200), startPoint(2), startPoint(3) + 100], 130.85, 930.85, 75, 1975); % Koniec prostej początkowej
controlPoints(7, :) = limitToWorkspace([endPoint(1) - 200, endPoint(2), endPoint(3) - 100], 130.85, 930.85, 75, 1975); % Początek prostej końcowej
controlPoints(8, :) = endPoint; % Punkt końcowy (koniec prostej końcowej)

% Punkty krzywej Béziera
controlPoints(3, :) = limitToWorkspace([(controlPoints(2, 1) + 100), controlPoints(2, 2) - 100, controlPoints(2, 3) + 300], 130.85, 930.85, 75, 1975); % Pierwszy punkt krzywej
controlPoints(4, :) = limitToWorkspace((startPoint + endPoint) / 2 + [200, -200, 500], 130.85, 930.85, 75, 1975); % Środkowy punkt krzywej
controlPoints(5, :) = limitToWorkspace((startPoint + endPoint) / 2 - [200, 200, 500], 130.85, 930.85, 75, 1975); % Środkowy punkt krzywej
controlPoints(6, :) = limitToWorkspace([(controlPoints(7, 1) - 100), controlPoints(7, 2) + 100, controlPoints(7, 3) - 300], 130.85, 930.85, 75, 1975); % Ostatni punkt krzywej

% Generowanie parametrów t od 0 do 1 dla krzywej Béziera
t = linspace(0, 1, 100); % 100 punktów na krzywej

% Obliczenie krzywej Béziera
bezierCurve = zeros(length(t), 5);
n = 5; % Stopień krzywej Béziera (5. stopnia, bo używamy 6 punktów kontrolnych)
for i = 1:length(t)
    bezierCurve(i, :) = zeros(1, 5); % Punkt na krzywej
    for k = 0:n
        % Współczynnik dwumianowy
        coeff = nchoosek(n, k) * (t(i)^k) * ((1 - t(i))^(n - k));
        bezierCurve(i, :) = bezierCurve(i, :) + coeff * controlPoints(k + 1, :); % Używamy punktów 3-6 (krzywa)
    end
end

% Dodanie prostych na początku i końcu trasy
% Prosta początkowa
startLine = [linspace(startPoint(1), controlPoints(2, 1), 50)', ...
             linspace(startPoint(2), controlPoints(2, 2), 50)', ...
             linspace(startPoint(3), controlPoints(2, 3), 50)'];

% Prosta końcowa
endLine = [linspace(controlPoints(7, 1), endPoint(1), 50)', ...
           linspace(controlPoints(7, 2), endPoint(2), 50)', ...
           linspace(controlPoints(7, 3), endPoint(3), 50)'];

% Rysowanie trasy
hold on;
plot3(startLine(:, 1), startLine(:, 2), startLine(:, 3), 'g-', 'LineWidth', 2); % Prosta początkowa
plot3(bezierCurve(:, 1), bezierCurve(:, 2), bezierCurve(:, 3), 'b-', 'LineWidth', 2); % Krzywa Béziera
plot3(endLine(:, 1), endLine(:, 2), endLine(:, 3), 'r-', 'LineWidth', 2); % Prosta końcowa

% Rysowanie punktów kontrolnych
plot3(controlPoints(:, 1), controlPoints(:, 2), controlPoints(:, 3), 'ro-', 'LineWidth', 1.5);
scatter3(controlPoints(:, 1), controlPoints(:, 2), controlPoints(:, 3), 50, 'r', 'filled');

% Ustawienia wykresu
title('Trajektoria robota: Prosta - Krzywa - Prosta');
legend({'Przestrzeń robocza', 'Punkt startowy', 'Punkt końcowy', ...
        'Prosta początkowa', 'Krzywa Béziera', 'Prosta końcowa', ...
        'Punkty kontrolne'}, 'Location', 'Best');
axis equal;

% Funkcja ograniczająca punkty kontrolne do przestrzeni roboczej
function correctedPoint = limitToWorkspace(point, promien_wew, promien_zew, start_z, wysokosc_z)
    % Oblicz promień w płaszczyźnie XY
    r = sqrt(point(1)^2 + point(2)^2);

    % Ograniczenie promienia do przestrzeni roboczej
    if r < promien_wew
        point(1:2) = point(1:2) * (promien_wew / r); % Skalowanie do wewnętrznego promienia
    elseif r > promien_zew
        point(1:2) = point(1:2) * (promien_zew / r); % Skalowanie do zewnętrznego promienia
    end

    % Ograniczenie wysokości Z
    point(3) = max(start_z, min(point(3), wysokosc_z));

    correctedPoint = point;
end

end



function output = dynamicWorkspaceInput(text,defx,defy,defz)
% Parametry przestrzeni roboczej
promien_zew = 930.85;  % Zewnętrzny promień walca
promien_wew = 130.85;  % Wewnętrzny promień walca
start_z = 75;          % Minimalna wysokość Z
wysokosc = 1900;       % Maksymalna wysokość Z

% Tworzenie okna interfejsu
fig = uifigure('Name', 'Wprowadzenie punktu', 'Position', [100, 100, 800, 400]);

% Tworzenie panelu do wprowadzania danych
inputPanel = uipanel(fig, 'Title', text, 'Position', [10, 130, 350, 250]);

% Pola tekstowe i edycyjne dla X, Y, Z
uilabel(inputPanel, 'Text', 'Wprowadź współrzędną X:', 'Position', [10, 180, 200, 20]);
xField = uieditfield(inputPanel, 'numeric', 'Position', [200, 180, 100, 20], 'Value', defx, ...
    'ValueChangedFcn', @(src, event) updateWorkspace());

xRangeLabel = uilabel(inputPanel, 'Text', '', 'Position', [10, 160, 300, 20], 'FontColor', [0.7,0,0]);

uilabel(inputPanel, 'Text', 'Wprowadź współrzędną Y:', 'Position', [10, 130, 200, 20]);
yField = uieditfield(inputPanel, 'numeric', 'Position', [200, 130, 100, 20], 'Value', defy, ...
    'ValueChangedFcn', @(src, event) updateWorkspace());

yRangeLabel = uilabel(inputPanel, 'Text', '', 'Position', [10, 110, 300, 20], 'FontColor', [0.7,0,0]);

uilabel(inputPanel, 'Text', 'Wprowadź współrzędną Z:', 'Position', [10, 80, 200, 20]);
zField = uieditfield(inputPanel, 'numeric', 'Position', [200, 80, 100, 20], 'Value', defz, ...
    'ValueChangedFcn', @(src, event) updateWorkspace());

zRangeLabel = uilabel(inputPanel, 'Text', 'Zakres Z: 75 ÷ 1975', ...
    'Position', [10, 60, 300, 20], 'FontColor', [0.7,0,0]);

% Textbox na komunikaty
textbox = uitextarea(fig, 'Position', [10, 140, 350, 30], 'Editable', 'off');
textbox.FontWeight = 'bold';
textbox.FontSize = 14;

% Tworzenie przycisku
button = uibutton(fig, 'push', ...   % Typ przycisku 'push'
    'Text', 'Akceptuj punkt', ...    % Tekst na przycisku
    'Position', [110, 40, 140, 50], ... % Pozycja i rozmiar [x, y, szerokość, wysokość]
    'ButtonPushedFcn', @(btn, event) onButtonClick()); % Funkcja obsługująca kliknięcie

% Dynamiczny widok z góry (axes)
viewPanel = uipanel(fig, 'Title', 'Widok z góry', 'Position', [400, 30, 350, 350]);
ax = uiaxes(viewPanel, 'Position', [10, 10, 330, 330]);
hold(ax, 'on');




    
    
    updateWorkspace();
        function onButtonClick()
            if updateWorkspace(); % sprawdzanie czy punkt jest ok
                output = [xField.Value,yField.Value,zField.Value];
                uiresume(fig)
                close(fig)
                return
            end
    
        end
    
    
    % Funkcja aktualizująca dynamicznie wykres i zakresy
        function pointStatus = updateWorkspace()
            % Pobranie wartości z pól
            x = xField.Value;
            y = yField.Value;
            z = zField.Value;
    
            % Obliczenie zakresów dla X i Y
            maxY = sqrt(promien_zew^2 - x^2);
            minY = -sqrt(promien_zew^2 - x^2);
            rmaxY = sqrt(promien_wew^2 - x^2);
            rminY = -sqrt(promien_wew^2 - x^2);
    
    
            maxX = sqrt(promien_zew^2 - y^2);
            minX = -sqrt(promien_zew^2 - y^2);
            rmaxX = sqrt(promien_wew^2 - y^2);
            rminX = -sqrt(promien_wew^2 - y^2);
    
            if abs(x) < promien_wew
                 yRangeLabel.Text = sprintf('Zakres Y: (%.2f ÷ %.2f) oraz (%.2f ÷ %.2f)', ceil(minY*100)/100,ceil(rminY*100)/100 ,ceil(rmaxY*100)/100 ,ceil(maxY*100)/100);
            else
                yRangeLabel.Text = sprintf('Zakres Y: (%.2f ÷ %.2f)', ceil(minY*100)/100, ceil(maxY*100)/100);
            end
            
    
            if abs(y) < promien_wew
                xRangeLabel.Text = sprintf('Zakres X: (%.2f ÷ %.2f) oraz (%.2f ÷ %.2f)', ...
                    ceil(minX*100)/100, ceil(rminX*100)/100, ceil(rmaxX*100)/100, ceil(maxX*100)/100);
            else
                xRangeLabel.Text = sprintf('Zakres X: (%.2f ÷ %.2f)', ceil(minX*100)/100, ceil(maxX*100)/100);
            end
    
            % Sprawdzenie, czy punkt mieści się w przestrzeni roboczej
            r = sqrt(x^2 + y^2); % Promień w płaszczyźnie XY
            pointOK = (r >= promien_wew && r <= promien_zew) && (z >= start_z && z <= start_z + wysokosc);
    
            % Ustawienie komunikatu w textboxie
            if ~pointOK
                textbox.FontColor = [1, 0, 0]; % RGB dla czerwonego koloru
                if r < promien_wew || r > promien_zew
                    textbox.Value = 'Punkt poza przestrzenią roboczą';
                elseif x < minX || x > maxX
                    textbox.Value = 'Wartość X poza zakresem';
                elseif y < minY || y > maxY
                    textbox.Value = 'Wartość Y poza zakresem';
                elseif z < start_z || z > start_z + wysokosc
                    textbox.Value = 'Wartość Z poza zakresem';
                end
                kolor = 'r-';
            else
                textbox.FontColor = [0, 0.5,0]; % RGB dla czerwonego koloru
                textbox.Value = 'Punkt wewnątrz przestrzeni roboczej';
                kolor = 'g-';
            end
    
            % Aktualizacja wykresu
            cla(ax); % Czyszczenie poprzedniego rysunku
    
    
    
            % Rysowanie przestrzeni roboczej (widok z góry)
            theta = linspace(0, 2*pi, 100);
            
            % Współrzędne dużego okręgu (zewnętrzny promień)
            x_outer = promien_zew * cos(theta);
            y_outer = promien_zew * sin(theta);
            
            % Współrzędne małego okręgu (wewnętrzny promień)
            x_inner = promien_wew * cos(theta);
            y_inner = promien_wew * sin(theta);
            
            % Rysowanie wypełnienia między okręgami
            fill(ax, [x_outer, fliplr(x_inner)], [y_outer, fliplr(y_inner)], 'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none'); 
            
            % Rysowanie wewnętrznego okręgu (kontur czarny)
            plot(ax, x_inner, y_inner, 'b', 'LineWidth', 0.5); % Czarny kontur dla wewnętrznego okręgu
            
            % Rysowanie zewnętrznego okręgu (kontur niebieski)
            plot(ax, x_outer, y_outer, 'b', 'LineWidth', 0.5); % Niebieski kontur dla zewnętrznego okręgu
    
    
    
    
    
    
            % Rysowanie dynamicznych osi (ciągłe, czerwone)
            plot(ax, [-promien_zew, promien_zew], [x, x], kolor, 'LineWidth', 1.5); % Oś pozioma X
            plot(ax, [y, y], [-promien_zew, promien_zew], kolor, 'LineWidth', 1.5); % Oś pionowa Y
    
            xlabel(ax, 'Y'); % Ustawienie oznaczeń osi
            ylabel(ax, 'X');
            ax.XDir = 'reverse'; % Odwrócenie osi Y
            axis(ax, 'equal');
            grid(ax, 'on');
    
            pointStatus = pointOK;

    
        end
        % Zatrzymanie kodu do momentu naciśnięcia przycisku
    uiwait(fig);
end