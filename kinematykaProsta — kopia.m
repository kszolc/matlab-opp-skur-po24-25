function kinematykaProstaBackup()
    % Funkcja kinematykaProsta - wizualizacja punktów w przestrzeni roboczej

    clear;
    clc;
    close all;

    debug_mode = 0;

    % Parametry przestrzeni roboczej
    promien_zew = 930.85;  % Zewnętrzny promień walca
    promien_wew = 130.85;  % Wewnętrzny promień walca
    start_z = 75;          % Wysokość podstawy walca od osi Z
    wysokosc = 1900;       % Wysokość walca
    q1_v_max =36;
    q2_v_max = 50;
    q3_v_max = 66.25;

    gestosc_drogi = 3000;
    freq_sampling = 100000; % Częstotliwość próbkowania (Hz)

   


    % Pobranie punktu początkowego
    start_point = getPoint([promien_wew, 0, start_z], 'Punkt początkowy', ...
        promien_wew, promien_zew, start_z, wysokosc);

    % Pobranie punktu końcowego
    end_point = getPoint([-promien_zew, 0, start_z + wysokosc], 'Punkt końcowy', ...
        promien_wew, promien_zew, start_z, wysokosc);

    % Wyliczenie odpowiednich prędkości maksymalnych złącz dla jednolitego
    % czasu najdłuższego ruchu 
    [q1_v_max, q2_v_max, q3_v_max] = odpowiedniePredkosci(start_point, end_point, q1_v_max, q2_v_max, q3_v_max);


  % Wykreślanie wykresów odpowiednich złącz i zwrot pokonywanej drogi
% przez złącza
[q1_droga, t_q1_zwrot] = rysujPredkoscObrotu(start_point(1), start_point(2), end_point(1), end_point(2), q1_v_max);
[q2_droga, t_q2_zwrot] = rysujPredkoscQ2(start_point(3), end_point(3), q2_v_max);
[q3_droga, t_q3_zwrot] = rysujPredkoscQ3(start_point(1), start_point(2), end_point(1), end_point(2), q3_v_max);

% Wybieranie najdłuższego wektora czasu
if t_q1_zwrot(end) >= t_q2_zwrot(end) && t_q1_zwrot(end) >= t_q3_zwrot(end)
    t_calkowite = t_q1_zwrot; % Przypisanie wektora czasu z q1
elseif t_q2_zwrot(end) >= t_q1_zwrot(end) && t_q2_zwrot(end) >= t_q3_zwrot(end)
    t_calkowite = t_q2_zwrot; % Przypisanie wektora czasu z q2
else
    t_calkowite = t_q3_zwrot; % Przypisanie wektora czasu z q3
end

% Debugowanie
if debug_mode == 1
    fprintf('--- DEBUG MODE ---\n');
    fprintf('Użyty najdłuższy wektor czasu pochodzi z: ');
    if t_calkowite(end) == t_q1_zwrot(end)
        fprintf('q1_zwrot\n');
    elseif t_calkowite(end) == t_q2_zwrot(end)
        fprintf('q2_zwrot\n');
    else
        fprintf('q3_zwrot\n');
    end
    fprintf('Długość t_calkowite: %d elementów\n', numel(t_calkowite));
    fprintf('-------------------\n');
end


% Sprawdzanie, czy debug_mode jest włączony
if debug_mode == 1
    fprintf('--- DEBUG MODE ---\n');
    fprintf('Długości wektorów drogi:\n');
    fprintf('q1_droga: %d elementów\n', numel(q1_droga));
    fprintf('q2_droga: %d elementów\n', numel(q2_droga));
    fprintf('q3_droga: %d elementów\n', numel(q3_droga));
    fprintf('t_calkowite: %d elementów\n', numel(t_calkowite));
    fprintf('-------------------\n');
end

% Znalezienie długości najdłuższego wektora
max_length = max([numel(q1_droga), numel(q2_droga), numel(q3_droga)]);

% Rozszerzanie zerowych wektorów do najdłuższego wektora niezerowego
if max(abs(q1_droga)) == 0
    q1_droga = zeros(1, max_length); % Rozszerzanie do maksymalnej długości
    if debug_mode == 1
    fprintf('q1_droga była zerowa i została rozszerzona do długości %d.\n', max_length);
    end
end

if max(abs(q2_droga)) == 0
    q2_droga = zeros(1, max_length); % Rozszerzanie do maksymalnej długości
    if debug_mode == 1
    fprintf('q2_droga była zerowa i została rozszerzona do długości %d.\n', max_length);
    end
end

if max(abs(q3_droga)) == 0
    q3_droga = zeros(1, max_length); % Rozszerzanie do maksymalnej długości
    if debug_mode == 1
    fprintf('q3_droga była zerowa i została rozszerzona do długości %d.\n', max_length);
    end
end




    
        % Znajdowanie najkrótszego wektora
    min_length = min([numel(q1_droga), numel(q2_droga), numel(q3_droga), numel(t_calkowite)]);
    
    % Flaga awaryjna
    emergency_flag = false;

    diff_q1 = 0;
    diff_q2 = 0;
    diff_q3 = 0;
    diff_t = 0;
    
    % Obcinanie nadmiarowych elementów z końca wektorów i wypisywanie różnic
    if numel(q1_droga) > min_length
        diff_q1 = numel(q1_droga) - min_length;
        fprintf('UWAGA! q1_droga skrócone o %d elementów.\n', diff_q1);
        q1_droga = q1_droga(1:min_length);
        if diff_q1 > freq_sampling/1000, emergency_flag = true; end
    end
    
    if numel(q2_droga) > min_length
        diff_q2 = numel(q2_droga) - min_length;
        fprintf('UWAGA! q2_droga skrócone o %d elementów.\n', diff_q2);
        q2_droga = q2_droga(1:min_length);
        if diff_q2 > freq_sampling/1000, emergency_flag = true; end
    end
    
    if numel(q3_droga) > min_length
        diff_q3 = numel(q3_droga) - min_length;
        fprintf('UWAGA! q3_droga skrócone o %d elementów.\n', diff_q3);
        q3_droga = q3_droga(1:min_length);
        if diff_q3 > freq_sampling/1000, emergency_flag = true; end
    end
    
    if numel(t_calkowite) > min_length
        diff_t = numel(t_calkowite) - min_length;
        fprintf('UWAGA! t_calkowite skrócone o %d elementów.\n', diff_t);
        t_calkowite = t_calkowite(1:min_length);
        if diff_t > freq_sampling/1000, emergency_flag = true; end
    end
    
    % Finalny komunikat
    if diff_q1 + diff_q2 + diff_q3 + diff_t ~= 0
    fprintf('Wektory zostały wyrównane do długości %d elementów.\n', min_length);
    end
    
    % Wyświetlenie komunikatu awaryjnego, jeśli flagi zostały ustawione
    if emergency_flag
        uialert(uifigure, ...
            'Skrócenie jednego z wektorów przekroczyło 1ms. Wyniki mogą być niepoprawne.', ...
            'Uwaga: Znaczne skrócenie danych', ...
            'Icon', 'warning');
    end
    
    % Wywołanie funkcji rysującej wykresy pozycji w czasie
    [x_pos, y_pos, z_pos] = rysujPozycjeWczasie(t_calkowite, q1_droga, q2_droga, q3_droga, start_point, debug_mode);

   
    v_total = rysujPredkosci(x_pos, y_pos, z_pos, t_calkowite);

% Wywołanie funkcji przestrzen_robocza do narysowania przestrzeni roboczej
przestrzen_robocza();

% Rysowanie punktów na wykresie
hold on;
p1 = scatter3(start_point(1), start_point(2), start_point(3), 50, 'g', 'filled'); % Punkt początkowy - zielony
p2 = scatter3(end_point(1), end_point(2), end_point(3), 50, 'b', 'filled');       % Punkt końcowy - niebieski

% Zakres prędkości
v_min = min(v_total);
v_max = max(v_total);

% Liczba kolorów w mapie
n_colors = 256;

% Normalizacja prędkości do zakresu [1, 256]
color_indices = round((v_total - v_min) / (v_max - v_min) * (n_colors - 1)) + 1;

% Zapewnienie, że indeksy mieszczą się w przedziale [1, 256]
color_indices = max(min(color_indices, n_colors), 1);

% Pobieranie mapy kolorów (np. 'jet')
colormap_used = jet(n_colors);

% Dopasowanie kolorów do trajektorii
colors = colormap_used(color_indices, :);

% Usuwanie zbędnych punktów na podstawie gestosc_drogi
x_sampled = x_pos(1:gestosc_drogi:end);
y_sampled = y_pos(1:gestosc_drogi:end);
z_sampled = z_pos(1:gestosc_drogi:end);
colors_sampled = colors(1:gestosc_drogi:end, :);

% Rysowanie trajektorii z kolorami
scatter3(x_sampled, y_sampled, z_sampled, 10, colors_sampled, 'filled');


% Dodanie kolorowej legendy
cbar = colorbar('Ticks', [0, 0.5, 1], ...
         'TickLabels', {sprintf('Min %.2f', v_min), ...
                        sprintf(' '), ...
                        sprintf('Max %.2f', v_max)});
cbar.Label.String = 'Prędkość (mm/s)';
colormap(colormap_used);

    
end





function [s_vector, t_calkowite]  = rysujPredkoscQ2(z0, zk, vmax)
    % Parametry
    freq_sampling = 100000; % Częstotliwość próbkowania (Hz)
    dt = 1 / freq_sampling; % Krok czasowy (s)
    rozp_ham_droga = 100 * (vmax / 50); % Droga rozpędzania i hamowania (mm)
    T_segment = 4; % Czas rozpędzania lub hamowania (s)
    t_rozp_ham = 0:dt:T_segment; % Czas rozpędzania i hamowania

    % Obliczenia
    droga_calkowita = abs(zk - z0); % Całkowita droga (mm)

    % Obsługa szczególnych przypadków
    if droga_calkowita == 0
        % Brak ruchu
        t_calosc = 0:dt:T_segment * 2; % Czas o długości jak dla ruchu rozpędzania i hamowania
        v_calosc = zeros(size(t_calosc)); % Wektor zerowy prędkości
        s_vector = zeros(size(t_calosc)); % Wektor zerowy drogi
        disp('Ruch pionowy Q2 wynosi 0mm. Brak ruchu.');
        t_calkowite = t_calosc;
        return;
    end

    if droga_calkowita >= rozp_ham_droga * 2
        % Użycie maksymalnej prędkości
        droga_srodkowa = max(0, droga_calkowita - 2 * rozp_ham_droga); % Droga z maksymalną prędkością

        % Rozpędzanie (sin^2)
        v_rozp = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Stała prędkość
        t_srodek = droga_srodkowa / vmax; % Czas trwania ruchu z maksymalną prędkością
        t_staly = 0:dt:t_srodek; % Czas dla stałej prędkości
        v_staly = vmax * ones(size(t_staly)); % Prędkość stała

        % Hamowanie (sin^2)
        v_ham = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Łączenie wyników
        t_calosc = [t_rozp_ham, t_staly + T_segment, t_rozp_ham + T_segment + t_srodek];

        if zk - z0 > 0
            v_calosc = [v_rozp, v_staly, fliplr(v_ham)];
        else
            v_calosc = [v_rozp, v_staly, fliplr(v_ham)] * -1;
        end

        s_calosc = cumtrapz(t_calosc, v_calosc); % Droga całkowita
        a_calosc = diff(v_calosc) / dt; % Przyspieszenie (mm/s^2)

    else
        % Ruch bez maksymalnej prędkości
        stala = droga_calkowita / (rozp_ham_droga * 2);
        t_calosc = 0:dt:(2 * T_segment * stala);
        v_calosc = vmax * stala * sin((pi / (2 * T_segment * stala)) * t_calosc).^2;

        if zk - z0 < 0
            v_calosc = v_calosc * -1;
        end

        s_calosc = cumtrapz(t_calosc, v_calosc * stala);
        a_calosc = diff(v_calosc) / dt; % Przyspieszenie (mm/s^2)
    end

    t_accel = t_calosc(1:end-1); % Dopasowanie osi czasu dla przyspieszenia

    % Obliczenie RPM
    rpm_calosc = v_calosc * (750 / 50); % Przekształcenie prędkości na RPM

    % Zamiana drogi na zmienną złączową
    q2 = z0 + s_calosc; % Zmienna złączowa to wartość początkowa + przebyta droga

    % Wykres zmiennej złączowej
    figure;
    subplot(4, 1, 1);
    plot(t_calosc, q2, 'k-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Zm. złączowa q_2(t) [mm]');
    title('Wykres zmiennej złączowej złącza Q2 (q_2(t))');
    legend(sprintf('Zakres q_2: %.2f mm do %.2f mm', min(q2), max(q2)), 'Location', 'best');
    grid on;

    % Wykres prędkości
    subplot(4, 1, 2);
    plot(t_calosc, v_calosc, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość q_2''(t) [mm/s]');
    title('Wykres prędkości złącza Q2 (q_2''(t))');
    legend(sprintf('Całkowity czas: %.2f s', t_calosc(end)), 'Location', 'best');
    grid on;

    % Wykres przyspieszenia
    subplot(4, 1, 3);
    plot(t_accel, a_calosc, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Przyspieszenie q_2''''(t) [mm/s^2]');
    title('Wykres przyspieszenia złącza Q2 (q_2''''(t))');
    legend(sprintf('Max przyspieszenie: %.2f mm/s^2', max(abs(a_calosc))), 'Location', 'best');
    grid on;

    % Wykres RPM
    subplot(4, 1, 4);
    plot(t_calosc, rpm_calosc, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('RPM');
    title('Wykres RPM złącza Q2');
    legend(sprintf('Max RPM: %.2f', max(abs(rpm_calosc))), 'Location', 'best');
    grid on;

    % Zwracanie przebytej drogi
    s_vector = s_calosc;
    t_calkowite = t_calosc;
end

% Ogólna funkcja do wprowadzania punktów
function point = getPoint(default, titleText, promien_wew, promien_zew, start_z, wysokosc)
    % Flaga poprawności wprowadzenia
    valid = false; 
    while ~valid
        % Okno dialogowe do wprowadzania współrzędnych
        answer = inputdlg({'X:', 'Y:', 'Z:'}, ...
            titleText, ...
            [1, 50], ...
            {num2str(default(1)), num2str(default(2)), num2str(default(3))});
        
        % Przekształcenie wprowadzenia na liczby
        if isempty(answer)
            errordlg('Musisz wprowadzić wszystkie współrzędne!', 'Błąd');
            continue;
        end
        point = str2double(answer);
        
        
        % Walidacja wprowadzonych wartości
        if any(isnan(point)) || numel(point) ~= 3
            errordlg('Wprowadź poprawne współrzędne liczbowe (X, Y, Z)!', 'Błąd');
            continue;
        end

        % Sprawdzenie, czy punkt mieści się w przestrzeni roboczej
        r = sqrt(point(1)^2 + point(2)^2); % Odległość od osi Z w płaszczyźnie XY
        if r < promien_wew
            errordlg('Punkt znajduje się wewnątrz ograniczenia wewnętrznego walca!', 'Błąd');
        elseif r > promien_zew
            errordlg('Punkt znajduje się poza ograniczeniem zewnętrznym walca!', 'Błąd');
        elseif point(3) < start_z || point(3) > (start_z + wysokosc)
            errordlg('Współrzędna Z punktu jest poza ograniczeniami przestrzeni roboczej!', 'Błąd');
        else
            % Punkt jest poprawny
            valid = true;
        end
    end
end

% Funkcja dostosowania prędkości w czasie

function [q1_predkosc, q2_predkosc, q3_predkosc] = odpowiedniePredkosci(pkt_start, pkt_end, q1_v, q2_v, q3_v)
    % Funkcja oblicza drogi dla poszczególnych złącz i zwraca maksymalne
    % prędkości dla każdego złącza
    
    % Drogi dla poszczególnych złącz

    % Q1 - Droga kątowa
    theta_start = atan2(pkt_start(2), pkt_start(1)); % Kąt początkowy (radiany)
    theta_end = atan2(pkt_end(2), pkt_end(1));       % Kąt końcowy (radiany)
    
    % Obliczenie różnicy kątów
    q1_droga = abs(theta_end - theta_start);
    
    % Uwzględnienie sytuacji, gdy różnica przekracza 180 stopni (pi radianów)
    if q1_droga > pi
        q1_droga = 2 * pi - q1_droga; % Zwracamy drogę kątową w mniejszym kierunku
    end

    q1_droga_deg = rad2deg(q1_droga); % Konwersja drogi kątowej na stopnie

    % Q3 - Droga promieniowa
    r_start = sqrt(pkt_start(1)^2 + pkt_start(2)^2); % Promień początkowy
    r_end = sqrt(pkt_end(1)^2 + pkt_end(2)^2);       % Promień końcowy
    q3_droga = abs(r_end - r_start); % Różnica promieni

    % Q2 - Droga wzdłuż osi Z
    q2_droga = abs(pkt_end(3) - pkt_start(3)); % Różnica w osi Z


    q1_t = q1_droga_deg / q1_v;
    q2_t = q2_droga / q2_v;
    q3_t = q3_droga / q3_v;

    t_max = max([q1_t,q2_t,q3_t]);

    q1_t_wsp = q1_t / t_max;
    q2_t_wsp = q2_t / t_max;
    q3_t_wsp = q3_t / t_max;




    % Maksymalne prędkości
    q1_predkosc = q1_v * q1_t_wsp;
    q2_predkosc = q2_v * q2_t_wsp;
    q3_predkosc = q3_v * q3_t_wsp;
end

function [s_vector, t_calkowite] = rysujPredkoscObrotu(x0, y0, xk, yk, vmax)
    % Parametry
    freq_sampling = 100000; % Częstotliwość próbkowania (Hz)
    dt = 1 / freq_sampling; % Krok czasowy (s)
    rozp_ham_droga = 72 * (vmax / 36); % Droga kątowa rozpędzania i hamowania (deg)
    T_segment = 4; % Czas rozpędzania lub hamowania (s)
    t_rozp_ham = 0:dt:T_segment; % Czas rozpędzania i hamowania

    % Obliczenie drogi kątowej
    theta_start = atan2(y0, x0); % Kąt początkowy (radiany)
    theta_end = atan2(yk, xk); % Kąt końcowy (radiany)
    theta_diff = theta_end - theta_start;

    % Korekta różnicy kąta dla przekroczenia 180 stopni
    if theta_diff > pi
        theta_diff = theta_diff - 2 * pi;
    elseif theta_diff < -pi
        theta_diff = theta_diff + 2 * pi;
    end
    q1_droga = abs(rad2deg(theta_diff)); % Droga kątowa w stopniach

    % Obsługa szczególnych przypadków
    if q1_droga == 0
        % Brak ruchu
        t_calosc = 0:dt:T_segment * 2; % Czas o długości jak dla ruchu rozpędzania i hamowania
        v_calosc = zeros(size(t_calosc)); % Wektor zerowy prędkości
        s_vector = zeros(size(t_calosc)); % Wektor zerowy drogi
        disp('Ruch kątowy Q1 wynosi 0 stopni. Brak ruchu.');
        t_calkowite = t_calosc;
        return;
    end

    % Obliczenia prędkości i czasu
    if q1_droga >= 2 * rozp_ham_droga % Sprawdzenie czy użyć prędkości maksymalnej
        droga_srodkowa = max(0, q1_droga - 2 * rozp_ham_droga); % Droga z maksymalną prędkością

        % Rozpędzanie (sin^2)
        v_rozp = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Stała prędkość
        t_srodek = droga_srodkowa / vmax; % Czas trwania ruchu z maksymalną prędkością
        t_staly = 0:dt:t_srodek; % Czas dla stałej prędkości
        v_staly = vmax * ones(size(t_staly)); % Prędkość stała

        % Hamowanie (sin^2)
        v_ham = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Łączenie wyników
        t_calosc = [t_rozp_ham, t_staly + T_segment, t_rozp_ham + T_segment + t_srodek];
        v_calosc = [v_rozp, v_staly, fliplr(v_ham)];
    else
        % Droga poniżej minimalnej (rozpędzanie i hamowanie)
        stala = q1_droga / (2 * rozp_ham_droga);
        t_calosc = (0:dt:(2 * T_segment * stala)); % Skalowany czas
        v_calosc = vmax * stala * sin((pi / (2 * T_segment * stala)) * t_calosc).^2;
    end

    % Uwzględnienie kierunku ruchu
    if theta_diff < 0
        v_calosc = -v_calosc;
    end

    % Obliczenie przebytej drogi kątowej
    s_calosc = cumtrapz(t_calosc, v_calosc);
    a_calosc = diff(v_calosc) / dt; % Przyspieszenie (deg/s^2)
    t_accel = t_calosc(1:end-1); % Dopasowanie osi czasu dla przyspieszenia

    % Obliczenie RPM w oparciu o aktualną prędkość
    rpm_calosc = v_calosc * (120 / 36); % Przekształcenie prędkości na RPM

    % Zamiana drogi na zmienną złączową
    q1 = rad2deg(theta_start) + s_calosc; % Zmienna złączowa to wartość początkowa + przebyta droga

    % Wykres zmiennej złączowej
    figure;
    subplot(4, 1, 1);
    plot(t_calosc, q1, 'k-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Zm. złączowa q_1(t) [deg]');
    title('Wykres zmiennej złączowej złącza Q1 (q_1(t))');
    legend(sprintf('Zakres q_1: %.2f° do %.2f°', min(q1), max(q1)), 'Location', 'best');
    grid on;

    % Wykres prędkości
    subplot(4, 1, 2);
    plot(t_calosc, v_calosc, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość q_1''(t) [deg/s]');
    title('Wykres prędkości złącza Q1 (q_1''(t))');
    legend(sprintf('Całkowity czas: %.2f s', t_calosc(end)), 'Location', 'best');
    grid on;

    % Wykres przyspieszenia
    subplot(4, 1, 3);
    plot(t_accel, a_calosc, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Przyspieszenie q_1''''(t) [deg/s^2]');
    title('Wykres przyspieszenia złącza Q1 (q_1''''(t))');
    legend(sprintf('Max przyspieszenie: %.2f deg/s^2', max(abs(a_calosc))), 'Location', 'best');
    grid on;

    % Wykres RPM
    subplot(4, 1, 4);
    plot(t_calosc, rpm_calosc, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('RPM');
    title('Wykres RPM złącza Q1');
    legend(sprintf('Max RPM: %.2f', max(abs(rpm_calosc))), 'Location', 'best');
    grid on;

    % Zwracanie przebytej drogi kątowej
    s_vector = s_calosc;
    t_calkowite = t_calosc;
end

function [s_vector, t_calkowite] = rysujPredkoscQ3(x0, y0, xk, yk, vmax)
    % Parametry
    freq_sampling = 100000; % Częstotliwość próbkowania (Hz)
    dt = 1 / freq_sampling; % Krok czasowy (s)
    rozp_ham_droga = 100 * (vmax / 50); % Droga rozpędzania i hamowania (mm)
    T_segment = 4; % Czas rozpędzania lub hamowania (s)
    t_rozp_ham = 0:dt:T_segment; % Czas rozpędzania i hamowania

    % Obliczenie drogi przesunięcia promienia
    r_start = sqrt(x0^2 + y0^2); % Promień początkowy
    r_end = sqrt(xk^2 + yk^2); % Promień końcowy
    q3_droga = abs(r_end - r_start); % Droga promieniowa (mm)

    % Obsługa szczególnych przypadków
    if q3_droga == 0
        % Brak ruchu
        t_calosc = 0:dt:T_segment * 2; % Czas o długości jak dla ruchu rozpędzania i hamowania
        v_calosc = zeros(size(t_calosc)); % Wektor zerowy prędkości
        s_vector = zeros(size(t_calosc)); % Wektor zerowy drogi
        disp('Ruch promieniowy Q3 wynosi 0 mm. Brak ruchu.');
        t_calkowite = t_calosc;
        return;
    end

    % Obliczenia prędkości i czasu
    if q3_droga >= 2 * rozp_ham_droga % Sprawdzenie czy użyć prędkości maksymalnej
        droga_srodkowa = max(0, q3_droga - 2 * rozp_ham_droga); % Droga z maksymalną prędkością

        % Rozpędzanie (sin^2)
        v_rozp = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Stała prędkość
        t_srodek = droga_srodkowa / vmax; % Czas trwania ruchu z maksymalną prędkością
        t_staly = 0:dt:t_srodek; % Czas dla stałej prędkości
        v_staly = vmax * ones(size(t_staly)); % Prędkość stała

        % Hamowanie (sin^2)
        v_ham = vmax * sin((pi / (2 * T_segment)) * t_rozp_ham).^2;

        % Łączenie wyników
        t_calosc = [t_rozp_ham, t_staly + T_segment, t_rozp_ham + T_segment + t_srodek];
        v_calosc = [v_rozp, v_staly, fliplr(v_ham)];
    else
        % Droga poniżej minimalnej (rozpędzanie i hamowanie)
        stala = q3_droga / (2 * rozp_ham_droga);
        t_calosc = (0:dt:(2 * T_segment * stala)); % Skalowany czas
        v_calosc = vmax * stala * sin((pi / (2 * T_segment * stala)) * t_calosc).^2;
    end

    % Uwzględnienie kierunku ruchu
    if r_end - r_start < 0
        v_calosc = -v_calosc;
    end

    % Obliczenie przebytej drogi promieniowej
    s_calosc = cumtrapz(t_calosc, v_calosc);
    a_calosc = diff(v_calosc) / dt; % Przyspieszenie (mm/s^2)
    t_accel = t_calosc(1:end-1); % Dopasowanie osi czasu dla przyspieszenia

    % Obliczenie RPM w oparciu o aktualną prędkość
    rpm_max = 993.75; % Maksymalne RPM dla vmax
    rpm_calosc = (v_calosc / 66.25) * rpm_max; % Przekształcenie prędkości na aktualne RPM

    % Zamiana drogi na zmienną złączową
    q3 = r_start + s_calosc; % Zmienna złączowa to wartość początkowa + przebyta droga

    % Wykres zmiennej złączowej
    figure;
    subplot(4, 1, 1);
    plot(t_calosc, q3, 'k-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Zm. złączowa q_3(t) [mm]');
    title('Wykres zmiennej złączowej złącza Q3 (q_3(t))');
    legend(sprintf('Zakres q_3: %.2f mm do %.2f mm', min(q3), max(q3)), 'Location', 'best');
    grid on;

    % Wykres prędkości
    subplot(4, 1, 2);
    plot(t_calosc, v_calosc, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość q_3''(t) [mm/s]');
    title('Wykres prędkości złącza Q3 (q_3''(t))');
    legend(sprintf('Całkowity czas: %.2f s', t_calosc(end)), 'Location', 'best');
    grid on;

    % Wykres przyspieszenia
    subplot(4, 1, 3);
    plot(t_accel, a_calosc, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Przyspieszenie q_3''''(t) [mm/s^2]');
    title('Wykres przyspieszenia złącza Q3 (q_3''''(t))');
    legend(sprintf('Max przyspieszenie: %.2f mm/s^2', max(abs(a_calosc))), 'Location', 'best');
    grid on;

    % Wykres RPM
    subplot(4, 1, 4);
    plot(t_calosc, rpm_calosc, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('RPM');
    title('Wykres RPM złącza Q3');
    legend(sprintf('Max RPM: %.2f', max(abs(rpm_calosc))), 'Location', 'best');
    grid on;

    % Zwracanie przebytej drogi promieniowej
    s_vector = s_calosc;
    t_calkowite = t_calosc;
end

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

function [x_positions, y_positions, z_positions] = rysujPozycjeWczasie(t_calkowite, q1_droga, q2_droga, q3_droga, start_point, debug_mode)
    % Funkcja rysująca wykresy pozycji w czasie dla X, Y i Z
    % na podstawie przesunięć z wektorów drogi oraz punktu początkowego.
    % Zwraca wektory pozycji x, y i z.

    

    % Rozpakowanie współrzędnych początkowych
    x_start = start_point(1);
    y_start = start_point(2);
    z_start = start_point(3);

    % Obliczenie pozycji na podstawie drogi
    theta_start = atan2(y_start, x_start); % Kąt początkowy dla osi X i Y
    radius_start = sqrt(x_start^2 + y_start^2); % Promień początkowy w XY

    % Pozycja kątowa (Q1)
    theta_positions = theta_start + deg2rad(q1_droga); % Aktualne kąty w czasie
    x_positions = radius_start * cos(theta_positions); % Pozycja X w czasie
    y_positions = radius_start * sin(theta_positions); % Pozycja Y w czasie

    % Pozycja promieniowa (Q3)
    radius_positions = radius_start + q3_droga; % Zmiana promienia w czasie
    x_positions = radius_positions .* cos(theta_positions); % Korekta X
    y_positions = radius_positions .* sin(theta_positions); % Korekta Y

    % Pozycja liniowa w osi Z (Q2)
    z_positions = z_start + q2_droga; % Pozycja Z w czasie

            % Sprawdzanie, czy debug_mode jest włączony
 if debug_mode == 1
        fprintf('--- DEBUG MODE POZYCJA W CZASIE ---\n');
        fprintf('Długości wektorów drogi:\n');
        fprintf('q1_droga: %d elementów\n', numel(q1_droga));
        fprintf('q2_droga: %d elementów\n', numel(q2_droga));
        fprintf('q3_droga: %d elementów\n', numel(q3_droga));
        fprintf('-------------------\n');

                fprintf('--- DEBUG MODE POZYCJA W CZASIE ---\n');
        fprintf('Długości wektorów pozycji:\n');
        fprintf('x_positions: %d elementów\n', numel(x_positions));
        fprintf('y_positions: %d elementów\n', numel(y_positions));
        fprintf('z_positions: %d elementów\n', numel(z_positions));
        fprintf('t_calkowite: %d elementów\n', numel(t_calkowite));
        fprintf('-------------------\n');
 end

  

    % Rysowanie wykresów
    figure;

    % Wykres pozycji X w czasie
    subplot(3, 1, 1);
    plot(t_calkowite, x_positions, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Pozycja X (mm)');
    title('Pozycja X w czasie');
    grid on;

    % Wykres pozycji Y w czasie
    subplot(3, 1, 2);
    plot(t_calkowite, y_positions, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Pozycja Y (mm)');
    title('Pozycja Y w czasie');
    grid on;

    % Wykres pozycji Z w czasie
    subplot(3, 1, 3);
    plot(t_calkowite, z_positions, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Pozycja Z (mm)');
    title('Pozycja Z w czasie');
    grid on;

    % Funkcja zwraca pozycje w osiach X, Y, Z
end


function rysujDrogeWczasie(t_calkowite, q1_droga, q2_droga, q3_droga)
    % Funkcja rysująca wykres drogi w czasie dla Q1, Q2, Q3 na podstawie istniejących wektorów

    % Tworzenie nowego okna
    figure;

    % Wykres drogi Q1
    subplot(3, 1, 1);
    plot(t_calkowite, q1_droga, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Droga Q1 (deg)');
    title('Droga kątowa Q1 w czasie');
    grid on;

    % Wykres drogi Q2
    subplot(3, 1, 2);
    plot(t_calkowite, q2_droga, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Droga Q2 (mm)');
    title('Droga liniowa Q2 w czasie');
    grid on;

    % Wykres drogi Q3
    subplot(3, 1, 3);
    plot(t_calkowite, q3_droga, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Droga Q3 (mm)');
    title('Droga promieniowa Q3 w czasie');
    grid on;
end

function v_total = rysujPredkosci(x_pos, y_pos, z_pos, t)
    % Funkcja rysująca wykresy prędkości przesuwu w osiach X, Y, Z oraz prędkości całkowitej
    % Argumenty:
    %   x_pos, y_pos, z_pos - wektory pozycji w mm
    %   t - wektor czasu w sekundach
    
    % Sprawdzanie, czy wektory mają odpowiednie długości
    if length(x_pos) ~= length(t) || length(y_pos) ~= length(t) || length(z_pos) ~= length(t)
        error('Wektory pozycji i czasu muszą mieć taką samą długość.');
    end

    % Obliczanie prędkości w osiach
    dt = diff(t); % Różnice czasu (s)
    vx = diff(x_pos) ./ dt; % Prędkość w osi X (mm/s)
    vy = diff(y_pos) ./ dt; % Prędkość w osi Y (mm/s)
    vz = diff(z_pos) ./ dt; % Prędkość w osi Z (mm/s)
    
    % Obliczanie prędkości całkowitej
    v_total = sqrt(vx.^2 + vy.^2 + vz.^2); % Całkowita prędkość

    % Dopasowanie osi czasu do prędkości
    t_vel = t(1:end-1);

    % Tworzenie okna z czterema wykresami
    figure;

    % Wykres prędkości w osi X
    subplot(4, 1, 1);
    plot(t_vel, vx, 'r-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość X (mm/s)');
    title('Prędkość przesuwu w osi X');
    legend(sprintf('Min: %.2f mm/s, Max: %.2f mm/s', min(vx), max(vx)), 'Location', 'best');
    grid on;

    % Wykres prędkości w osi Y
    subplot(4, 1, 2);
    plot(t_vel, vy, 'g-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość Y (mm/s)');
    title('Prędkość przesuwu w osi Y');
    legend(sprintf('Min: %.2f mm/s, Max: %.2f mm/s', min(vy), max(vy)), 'Location', 'best');
    grid on;

    % Wykres prędkości w osi Z
    subplot(4, 1, 3);
    plot(t_vel, vz, 'b-', 'LineWidth', 1.5);
    xlabel('Czas (s)');
    ylabel('Prędkość Z (mm/s)');
    title('Prędkość przesuwu w osi Z');
    legend(sprintf('Min: %.2f mm/s, Max: %.2f mm/s', min(vz), max(vz)), 'Location', 'best');
    grid on;

    % Wykres prędkości całkowitej
    subplot(4, 1, 4);
    plot(t_vel, v_total, 'm-', 'LineWidth', 1.5); % Prędkość całkowita w kolorze magenta
    xlabel('Czas (s)');
    ylabel('Prędkość całkowita (mm/s)');
    title('Prędkość całkowita we wszystkich osiach');
    legend(sprintf('Min: %.2f mm/s, Max: %.2f mm/s', min(v_total), max(v_total)), 'Location', 'best');
    grid on;
end

