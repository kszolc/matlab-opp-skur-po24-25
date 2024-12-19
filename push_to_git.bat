@echo off
REM Skrypt do pushowania plikow do repozytorium matlab-opp-skur-po24-25

REM Przejdz do katalogu projektu
cd /d D:\1-Projekty\Domowe\MATLAB

REM Dodaj wszystkie pliki, w tym zmodyfikowane i usuniete
git add --all

REM Wyswietl status Git
git status

REM Pobierz wiadomosc dla commita od uzytkownika
set /p commit_message=Podaj wiadomosc dla commita: 

REM Wykonaj commit
git commit -m "%commit_message%"

REM Wypchnij zmiany na GitHub
git push

REM Pauza na zakonczenie
echo.
echo Operacja zakonczona dla repozytorium matlab-opp-skur-po24-25. Nacisnij dowolny klawisz, aby zamknac.
pause
