clear; close all; clc;

t = 1;
Freq = 45e6;
% Загрузка ансамблей ДК
load('L1SCd_c.mat');
load('L1SCp_c.mat');

load('L1OCd_c.mat');
load('L1OCp_c.mat');

% Выбираем первые последовательности из ансамблей ДК
L1SCd_c1 = L1SCd_c(t,:); 
L1SCp_c1 = L1SCp_c(t,:);
L1OCd_c1 = L1OCd_c(t,:); 
L1OCp_c1 = L1OCp_c(t,:);

% Создание последовательностей ДК длительностью 8 мс
L1SCd_c1_8 = kron ([1 1], L1SCd_c1);
L1SCp_c1_8 = L1SCp_c1;
L1OCd_c1_8 = kron ([-1 1 -1 1], L1OCd_c1); % С учетом 2 периодов ОК [01]
L1OCp_c1_8 = L1OCp_c1;

% Создание составляющих компоненты L1C_I c поднесущими
L1SCd_c1_8_sc = kron (L1SCd_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)
L1SCp_c1_8_sc = kron (L1SCp_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)

% Создание видеосигнала квадратурной компоненты L1C_I c поднесущими
L1C_I = ones(1,8*length(L1SCd_c1_8));
for i= 1:length(L1SCd_c1_8);
   L1C_I(8*i - 7) = L1SCd_c1_8_sc(4*i-3);
   L1C_I(8*i - 6) = L1SCd_c1_8_sc(4*i-2);
   L1C_I(8*i - 5) = L1SCd_c1_8_sc(4*i-1);
   L1C_I(8*i - 4) = L1SCd_c1_8_sc(4*i);
   L1C_I(8*i - 3) = L1SCp_c1_8_sc(4*i-3);
   L1C_I(8*i - 2) = L1SCp_c1_8_sc(4*i-2);
   L1C_I(8*i - 1) = L1SCp_c1_8_sc(4*i-1);
   L1C_I(8*i) = L1SCp_c1_8_sc(4*i);   
end

% Создание составляющих компоненты L1C_Q c поднесущими
L1OCd_c1_8_sc = kron (L1OCd_c1_8, [1 1]); % BPSK(1)
L1OCp_c1_8_sc = kron (L1OCp_c1_8, [1 -1]); % BOC(1, 1)

% Создание видеосигнала квадратурной компоненты L1C_Q c поднесущими
L1C_Q = ones(1,4*length(L1OCd_c1_8));
for i= 1:length(L1OCd_c1_8);
   L1C_Q(4*i - 3) = L1OCd_c1_8_sc(2*i-1);
   L1C_Q(4*i - 2) = L1OCd_c1_8_sc(2*i);
   L1C_Q(4*i - 1) = L1OCp_c1_8_sc(2*i-1);
   L1C_Q(4*i) = L1OCp_c1_8_sc(2*i);   
end
Freq_Signal_I = Sampling(8e-3,L1C_I,Freq);
Freq_Signal_Q = Sampling(8e-3,L1C_Q,Freq);

Freq_Signal_I(1:ceil(length(Freq_Signal_I)/100)) = 2*Freq_Signal_I(1:ceil(length(Freq_Signal_I)/100));
Freq_Signal_Q(1:ceil(length(Freq_Signal_Q)/100)) = 2*Freq_Signal_Q(1:ceil(length(Freq_Signal_Q)/100));

T_SEQ = 8e-3;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(Freq_Signal_I);
IQ(2:2:end) = single(Freq_Signal_Q);
IQ = IQ /  max(abs(single(Freq_Signal_I) + 1i*single(Freq_Signal_Q)));
IQ = floor((IQ*32767+0.5)); % длительность 8 мсек
IQ = kron(ones(1,125),IQ); % длительность 1 сек
IQ = kron(ones(1,4),IQ); % длительность 4 сек
fileID = fopen('L1_С.bin','w');
fwrite  (fileID, IQ, 'int16');
fclose(fileID);