function Q2_analiza_wstepna()
    % Funkcja do analizy trzeciego silnika z ruchem pionowym
    % Uwzględnia tylko grawitację i bezwładność, bez tarcia gwintu

    % Parametry dla trzeciego silnika
    A = 40000;  % Maksymalna wartość funkcji (m/s) dla trzeciego silnika (częstotliwość sterowania)
    T = 8;      % Całkowity czas analizy (s)

    % Parametry silnika krokowego
    mikrokroki_na_obrot = 200 * 16; % Liczba mikrokroków na pełny obrót (200 kroków * 16 mikrokroków na krok)

    % Parametry śruby trapezowej
    skok = 4 / 10; % Skok w centymetrach (4 mm przeliczone na cm)
    p = 0.004; % Skok śruby (m)
    

    % Częstotliwość próbkowania i czas próbkowania
    fs = A;                    % Częstotliwość próbkowania (Hz)
    dt = 1 / fs;               % Krok próbkowania (s)
    x = 0:dt:T;                % Zakres czasu z częstotliwością próbkowania
    y = A * sin((pi / T) * x).^2; % Obliczenie A * sin^2((pi/T) * x)
    y_rounded = round(y);      % Zaokrąglenie wartości \( y \) do całości (dla innych obliczeń)

    % Obliczanie prędkości obrotowej
    rps = y / mikrokroki_na_obrot; % Prędkość obrotowa w obrotach na sekundę (RPS)
    rpm = rps * 60;               % Prędkość obrotowa w obrotach na minutę (RPM)

    % Obliczanie prędkości liniowej (m/min i m/s)
    v_m_min = rps * skok * 60 / 100; % Prędkość liniowa w m/min
    v_m_s = v_m_min / 60;            % Prędkość liniowa w m/s (gładka, bez zaokrągleń)
   

    % Okno dialogowe do wprowadzania masy ładowanej
    valid_mass = false; % Flaga walidacji masy
    while ~valid_mass
        prompt = {'Wprowadź masę obciążenia (kg):'};
        dlgtitle = 'Masa obciążenia';
        dims = [1 50];
        default_mass = {'100'}; % Domyślna masa
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

    % Pozostałe masy
    masses = [mass_1, 21, 2.55, 6.25]; % Masy elementów (kg)
    masa_wozka = sum(masses); % Suma mas wózka i ładunku

    % Rysowanie pierwszego okna (3 wykresy)
    figure;

    % Wykres 1: Częstotliwość sterowania
    subplot(3, 1, 1);
    plot(x, y_rounded, 'r', 'LineWidth', 2);
    [max_y, idx_y] = max(y_rounded);
    xlabel('Czas (s)');
    ylabel('Częstotliwość [Hz]');
    title('Wykres sterowania silnika');
    grid on;
    legend(sprintf('f_{max}=%d (czas %.2f s)', max_y, x(idx_y)));

    % Wykres 2: Prędkość obrotowa (RPM)
    subplot(3, 1, 2);
    plot(x, rpm, 'g', 'LineWidth', 2);
    [max_rpm, idx_rpm] = max(rpm);
    xlabel('Czas (s)');
    ylabel('Prędkość obrotowa (RPM)');
    title('Prędkość obrotowa silnika (RPM)');
    grid on;
    legend(sprintf('RPM_{max}=%.2f (czas %.2f s)', max_rpm, x(idx_rpm)));

    % Wykres 3: Prędkość liniowa (m/min)
    subplot(3, 1, 3);
    plot(x, v_m_min, 'b', 'LineWidth', 2);
    [max_v, idx_v] = max(v_m_min);
    xlabel('Czas (s)');
    ylabel('Prędkość liniowa (m/min)');
    title('Prędkość liniowa wózka');
    grid on;
    legend(sprintf('v_{max}=%.2f (czas %.2f s)', max_v, x(idx_v)));

    % Obliczanie przyspieszenia liniowego (m/s^2)
    a_m_s2 = diff(v_m_s) / dt; % Przyspieszenie jako pochodna prędkości
    x_accel = x(1:end-1);      % Dopasowanie czasu do przyspieszenia

    % Rysowanie wykresu przyspieszenia liniowego (m/s^2)
    figure;
    subplot(3, 1, 1);
    plot(x_accel, a_m_s2, 'm', 'LineWidth', 2);
    [max_a, idx_a] = max(a_m_s2); % Maksymalne przyspieszenie
    xlabel('Czas (s)');
    ylabel('Przyspieszenie liniowe (m/s^2)');
    title('Przyspieszenie liniowe');
    grid on;
    legend(sprintf('a_{max}=%.2f (czas %.2f s)', max_a, x_accel(idx_a)), 'Location', 'best');

    % Obliczanie przebytej drogi (m)
    s_m = cumtrapz(x, v_m_s); % Całkowanie prędkości liniowej w m/s względem czasu

    % Rysowanie wykresu przebytej drogi (m)
    subplot(3, 1, 2);
    plot(x, s_m, 'k', 'LineWidth', 2); % Wykres drogi w czasie
    [max_s, idx_s] = max(s_m); % Maksymalna droga i czas jej osiągnięcia
    xlabel('Czas (s)');
    ylabel('Przebyta droga (m)');
    title('Przebyta droga w czasie');
    grid on;
    legend(sprintf('s_{max}=%.2f (czas %.2f s)', max_s, x(idx_s)), 'Location', 'best');

    % Siła osiowa (uwzględniająca grawitację i przyspieszenie)
    g = 9.81; % Przyspieszenie grawitacyjne
    F_total = masa_wozka * g + masa_wozka * a_m_s2; % Całkowita siła osiowa

    % Moment obrotowy na śrubie (Nm)
    torque_screw = F_total * p / (2 *3.14); % Uwzględnienie kąta nachylenia gwintu

    % Rysowanie wykresu momentu obrotowego
    subplot(3, 1, 3);
    plot(x_accel, torque_screw, 'c', 'LineWidth', 2);
    [max_torque, idx_torque] = max(torque_screw); % Maksymalny moment obrotowy
    xlabel('Czas (s)');
    ylabel('Moment obrotowy (Nm)');
    title('Moment obrotowy (z uwzględnieniem gwintu, bez tarcia)');
    grid on;
    legend(sprintf('\\tau_{max}=%.2f (czas %.2f s)', max_torque, x_accel(idx_torque)), 'Location', 'best');
end
