% Kod do wizualizacji punktu w przestrzeni 3D dla robota RPP

function plotRPPPoint()
    % Funkcja pyta użytkownika o wartości zmiennych złączowych q1, q2, q3

    % Pobranie wartości zmiennych złączowych od użytkownika
    q1_deg = input('Podaj wartość q1 (w stopniach, np. 45): ');
    q1 = deg2rad(q1_deg); % Konwersja na radiany

    q2 = input('Podaj wartość q2 (w jednostkach długości, np. 2): ');
    q3 = input('Podaj wartość q3 (w jednostkach długości, np. 1): ');

    % Stałe DH lub parametry geometryczne robota (w razie potrzeby można rozszerzyć)
    L1 = 1; % Odległość od podstawy do osi pryzmatycznej (stała wysokość, można zmienić)

    % Obliczenie macierzy transformacyjnej na podstawie złącz
    T = [  0, -cos(q1), -sin(q1), cos(q1)*(q3 + 130.85);
           0, -sin(q1),  cos(q1),  sin(q1)*(q3 + 130.85);
          -1,        0,        0,              q2 + 75;
           0,        0,        0,               1];

    % Ekstrakcja pozycji końcowego efektora (punktu w przestrzeni)
    position = T(1:3, 4)
    

    % Wizualizacja punktu w przestrzeni 3D
    figure;
    hold on;
    grid on;
    axis equal;
    view(3); % Wymuszenie widoku 3D
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('Pozycja końcówki robota RPP');

    % Rysowanie punktu końcowego
    plot3(position(1), position(2), position(3), 'ro', 'MarkerSize', 10, 'LineWidth', 2);

    % Opcjonalne: rysowanie podstawy robota i orientacji
    plot3([0, position(1)], [0, position(2)], [0, position(3)], 'b--');
    scatter3(0, 0, 0, 50, 'k', 'filled'); % Podstawa robota

    % Legenda
    legend('Punkt końcowy', 'Ścieżka', 'Podstawa robota');
    
    hold off;
end

% Aby uruchomić, wpisz w terminalu:
% plotRPPPoint;
