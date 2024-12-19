function przestrzen_robocza()
    % Funkcja generująca przestrzeń roboczą ograniczoną do powierzchni wydrążonego walca w 3D

    % Parametry przestrzeni roboczej
    promien_zew = 930.85;  % Zewnętrzny promień walca
    promien_wew = 130.85;  % Wewnętrzny promień walca
    wysokosc = 1900;       % Wysokość walca
    start_z = 75;          % Wysokość podstawy walca od osi Z

    % Parametry wizualizacji
    default_color = [0, 0.4470, 0.7410]; % Domyślny kolor MATLAB
    marker_size = 2; % Rozmiar punktów
    gestosc = 0.7; % Gęstość punktów

    % Modyfikacja liczby punktów na podstawie gęstości
    num_theta = round(100 * gestosc); % Liczba punktów wzdłuż kąta
    num_z = round(50 * gestosc);      % Liczba punktów wzdłuż osi Z
    num_r = round(50 * gestosc);      % Liczba punktów na dysku

    % Siatka punktów dla powierzchni bocznej (promień maksymalny i minimalny)
    theta = linspace(0, 2*pi, num_theta); % Kąt obrotu (0-360 stopni)
    z = linspace(start_z, start_z + wysokosc, num_z); % Wysokości (Z)

    % Powierzchnia boczna dla promienia zewnętrznego
    [Theta1, Z1] = meshgrid(theta, z);
    X1 = promien_zew * cos(Theta1);
    Y1 = promien_zew * sin(Theta1);

    % Powierzchnia boczna dla promienia wewnętrznego
    [Theta2, Z2] = meshgrid(theta, z);
    X2 = promien_wew * cos(Theta2);
    Y2 = promien_wew * sin(Theta2);

    % Dyski górny i dolny (na górze i dole cylindra)
    r_disk = linspace(promien_wew, promien_zew, num_r); % Promienie dysku
    theta_disk = linspace(0, 2*pi, num_theta); % Kąt obrotu
    [R_top, Theta_top] = meshgrid(r_disk, theta_disk);

    % Górny dysk (na wysokości start_z + wysokosc)
    X_top = R_top .* cos(Theta_top);
    Y_top = R_top .* sin(Theta_top);
    Z_top = (start_z + wysokosc) * ones(size(X_top)); % Stała wysokość

    % Dolny dysk (na wysokości start_z)
    X_bottom = R_top .* cos(Theta_top);
    Y_bottom = R_top .* sin(Theta_top);
    Z_bottom = start_z * ones(size(X_bottom)); % Stała wysokość

    % Rysowanie przestrzeni roboczej w 3D
    figure('Name', 'WykresPrzestrzeniRoboczej', 'NumberTitle', 'off'); % Okno z nazwą
    hold on;

    % Powierzchnia boczna
    scatter3(X1(:), Y1(:), Z1(:), marker_size, default_color, 'filled'); % Zewnętrzny walec
    scatter3(X2(:), Y2(:), Z2(:), marker_size, default_color, 'filled'); % Wewnętrzny walec

    % Górny i dolny dysk
    scatter3(X_top(:), Y_top(:), Z_top(:), marker_size, default_color, 'filled'); % Górny dysk
    scatter3(X_bottom(:), Y_bottom(:), Z_bottom(:), marker_size, default_color, 'filled'); % Dolny dysk

    % Oznaczenia osi
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('Przestrzeń robocza robota cylindrycznego (powierzchnia)');
    grid on;
    axis equal;
    zlim([0, 2000]); % Zakres osi Z: od 0 do 2000
    view(3); % Wymuszenie widoku 3D
    hold off;
end
