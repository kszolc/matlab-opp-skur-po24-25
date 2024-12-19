function Q1_analiza_wstepna()
    % Q1_analiza_wstepna - Analizuje charakterystyki silnika i ramienia
    % Parametry na stałe:
    A = 6400; % Maksymalna wartość funkcji (m/s)
    T = 8;   % Całkowity czas analizy (s)

    % Częstotliwość próbkowania i czas próbkowania
    fs = A;                    % Częstotliwość próbkowania (Hz)
    dt = 1 / fs;               % Krok próbkowania (s)
    x = 0:dt:T;                % Zakres czasu z częstotliwością próbkowania
    y = A * sin((pi / T) * x).^2; % Obliczenie A * sin^2((pi/T) * x)

    % Okno dialogowe do wprowadzania masy obciążenia
    valid_mass = false; % Flaga walidacji masy
    while ~valid_mass
        prompt = {'Wprowadź masę obciążenia (kg):'};
        dlgtitle = 'Masa obciążenia';
        dims = [1 50];
        default_mass = {'100'};
        user_input = inputdlg(prompt, dlgtitle, dims, default_mass);

        % Przekształcenie danych wejściowych na liczbę
        mass_1 = str2double(user_input);

        % Walidacja masy (zakres 0-100 kg)
        if mass_1 >= 0 && mass_1 <= 100
            valid_mass = true; % Masa jest poprawna
        else
            errordlg('Masa musi być w zakresie 0-100 kg. Spróbuj ponownie.', 'Błąd masy');
        end
    end

    % Pozostałe masy i odległości od osi obrotu (w mm)
    masses = [mass_1, 21, 2.55, 6.25];       % Mas (kg) z wprowadzaną masą 1
    distances_mm = [930.85, 531, 1069, 930.85]; % Odległości (mm)
    distances_m = distances_mm / 1000;       % Konwersja na metry

    % Obliczanie momentu bezwładności
    I = sum(masses .* (distances_m.^2));    % Całkowity moment bezwładności (kg·m²)

    % Obliczanie prędkości obrotowej (RPS) dla silnika i deg/s dla ramienia
    rps_silnik = y / 3200;               % Prędkość obrotowa silnika w obrotach na sekundę (RPS)
    rps_ramie = rps_silnik / 20;         % Prędkość obrotowa ramienia w obrotach na sekundę (RPS)
    deg_per_s_ramie = rps_ramie * 360;   % Prędkość kątowa ramienia w stopniach na sekundę

    % Poprawne obliczanie przyspieszenia kątowego (pochodna deg/s względem czasu)
    angular_acceleration_deg = diff(deg_per_s_ramie) / dt; % Przyspieszenie kątowe w deg/s^2
    angular_acceleration_rad = angular_acceleration_deg * (pi / 180); % Przyspieszenie w rad/s^2
    x_accel = x(1:end-1); % Dopasowanie długości wektora czasu do pochodnej

    % Obliczanie momentu obrotowego
    torque = I * angular_acceleration_rad; % Moment obrotowy (Nm)
    torque_70 = torque * (10 / 7); % Moment obrotowy przy sprawności 70%

    % Obliczanie drogi kątowej
    angular_distance_deg = cumtrapz(x, deg_per_s_ramie); % Droga kątowa w stopniach

    % --- Rysowanie pierwszego okna z trzema wykresami ---
    figure;

    % Wykres 1: Częstotliwość sterowania
    subplot(3, 1, 1);
    plot(x, y, 'r', 'LineWidth', 2);
    [max_y, idx_y] = max(y);
    xlabel('Czas (s)');
    ylabel('Częstotliwość [Hz]');
    title('Wykres sterowania silnika');
    grid on;
    legend(sprintf('f_{max}=%.2f (czas %.2f s)', max_y, x(idx_y)));

    % Wykres 2: RPS dla silnika
    subplot(3, 1, 2);
    plot(x, rps_silnik, 'b', 'LineWidth', 2);
    [max_rps, idx_rps] = max(rps_silnik);
    xlabel('Czas (s)');
    ylabel('Prędkość obrotowa (RPS)');
    title('Prędkość obrotowa silnika');
    grid on;
    legend(sprintf('RPS_{max}=%.2f (czas %.2f s)', max_rps, x(idx_rps)));

    % Wykres 3: deg/s dla ramienia
    subplot(3, 1, 3);
    plot(x, deg_per_s_ramie, 'g', 'LineWidth', 2);
    [max_deg, idx_deg] = max(deg_per_s_ramie);
    xlabel('Czas (s)');
    ylabel('Prędkość kątowa (deg/s)');
    title('Prędkość kątowa ramienia');
    grid on;
    legend(sprintf('deg/s_{max}=%.2f (czas %.2f s)', max_deg, x(idx_deg)));

    % --- Rysowanie drugiego okna z trzema wykresami ---
    figure;

    % Wykres 4: Przyspieszenie kątowe (deg/s^2)
    subplot(3, 1, 1);
    plot(x_accel, angular_acceleration_deg, 'm', 'LineWidth', 2);
    [max_acc, idx_acc] = max(angular_acceleration_deg);
    xlabel('Czas (s)');
    ylabel('Przyspieszenie kątowe (deg/s^2)');
    title('Przyspieszenie kątowe ramienia');
    grid on;
    legend(sprintf('deg/s^2_{max}=%.2f (czas %.2f s)', max_acc, x_accel(idx_acc)));

    % Wykres 5: Droga kątowa (deg)
    subplot(3, 1, 2);
    plot(x, angular_distance_deg, 'k', 'LineWidth', 2);
    [max_dist, idx_dist] = max(angular_distance_deg);
    xlabel('Czas (s)');
    ylabel('Droga kątowa (deg)');
    title('Droga kątowa ramienia');
    grid on;
    legend(sprintf('Dist_{max}=%.2f (czas %.2f s)', max_dist, x(idx_dist)), 'Location', 'southeast');

    % Wykres 6: Moment obrotowy (100% i 70%)
    subplot(3, 1, 3);
    plot(x_accel, torque, 'b', 'LineWidth', 2); % Linia ciągła dla sprawności 100%
    hold on;
    plot(x_accel, torque_70, '--r', 'LineWidth', 2); % Linia przerywana dla sprawności 70%
    [max_torque, idx_torque] = max(torque);
    [max_torque_70, idx_torque_70] = max(torque_70);
    xlabel('Czas (s)');
    ylabel('Moment obrotowy (Nm)');
    title('Moment obrotowy ramienia (100% i 70% sprawności)');
    grid on;
    legend(...
        sprintf('Torque_{max}=%.2f (czas %.2f s), sprawność=100%%', max_torque, x_accel(idx_torque)), ...
        sprintf('Torque_{max}=%.2f (czas %.2f s), sprawność=70%%', max_torque_70, x_accel(idx_torque_70)) ...
    );
end
