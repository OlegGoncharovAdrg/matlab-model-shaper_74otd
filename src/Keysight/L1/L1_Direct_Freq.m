clear; close all; clc
%% Вызов функций формирования сигналов с чатотным и кодовым разделением
Freq = 8e9; % Частота дискретизации
% L1F_PT
t = 1; % Номер космического аппарата

% L1SCd
InitialStates = strcat('0000000',dec2bin(1:63))-'0';
x_exit_L1SCd = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 0 0 1 1 0 1 1],...
'InitialStates', [0 0 0 1 0 1 1 1 1 0 1 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut', 5115))',generate(commsrc.pn('GenPoly', [1 1 0 0 0 1 0 0 0 0 0 1 0 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut', 5115))');
x_exit_L1SCd(x_exit_L1SCd==1)=-1;
x_exit_L1SCd(x_exit_L1SCd==0)=1;

% L1SCp
InitialStates = strcat('0',dec2bin(1:63))-'0';
x_exit_L1SCp = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1],...
'InitialStates', [0 0 1 1 0 1 0 0 1 1 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1], ...
'NumBitsOut',    10230))',generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 1], 'NumBitsOut', 10230))');
x_exit_L1SCp(x_exit_L1SCp==1)=-1;
x_exit_L1SCp(x_exit_L1SCp==0)=1;

% L1OCd
InitialStates = strcat('0000', dec2bin(1:63))-'0';
x_exit_L1OCd = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 1 0 0 1],...
'InitialStates', [0 0 1 1 0 0 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 1],   ...
'NumBitsOut',    1023))',generate(commsrc.pn('GenPoly', [1 0 0 1 0 0 0 1 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 1023))');
x_exit_L1OCd(x_exit_L1OCd==1)=-1;
x_exit_L1OCd(x_exit_L1OCd==0)=1;

% L1OCp
InitialStates = dec2bin(1:63)-'0';
x_exit_L1OCp = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 0 1 0 0 1 1],...
'InitialStates', [0 0 0 0 1 1 0 0 0 1 0 1], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 1],   ...
'NumBitsOut',    4092))',generate(commsrc.pn('GenPoly', [1 1 0 0 0 0 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 1], 'NumBitsOut', 4092))');
x_exit_L1OCp(x_exit_L1OCp==1)=-1;
x_exit_L1OCp(x_exit_L1OCp==0)=1;

% Создание составляющих компоненты L1C_I c поднесущими
L1SCd_c1_8_sc = kron (kron ([1 1], x_exit_L1SCd), [1 -1 1 -1]); % BOC(5, 2.5)
L1SCp_c1_8_sc = kron (x_exit_L1SCp, [1 -1 1 -1]); % BOC(5, 2.5)

% Создание видеосигнала квадратурной компоненты L1C_I c поднесущими
L1C_I = zeros(4, length(L1SCp_c1_8_sc)/2);  
L1C_I(:,1:2:end) = reshape(L1SCd_c1_8_sc,[4,length(L1SCd_c1_8_sc)/4]);
L1C_I(:,2:2:end) = reshape(L1SCp_c1_8_sc,[4,length(L1SCp_c1_8_sc)/4]);

% Создание составляющих компоненты L1C_Q c поднесущими
L1OCd_c1_8_sc = kron (kron ([-1 1 -1 1], x_exit_L1OCd), [1 1]); % BPSK(1) % С учетом 2 периодов ОК [01]
L1OCp_c1_8_sc = kron (x_exit_L1OCp, [1 -1]); % BOC(1, 1)

% Создание видеосигнала квадратурной компоненты L1C_Q c поднесущими
L1C_Q = zeros(2, length(L1OCd_c1_8_sc));  
L1C_Q(:,1:2:end) = reshape(L1OCd_c1_8_sc,[2,length(L1OCd_c1_8_sc)/2]);
L1C_Q(:,2:2:end) = reshape(L1OCp_c1_8_sc,[2,length(L1OCp_c1_8_sc)/2]);
Signal = Sampling(8e-3,reshape(L1C_I, [1,4*length(L1C_I)]),Freq).*sin(2*pi*1600.995e6*(1/Freq:1/Freq:8e-3))+...
    Sampling(8e-3,reshape(L1C_Q, [1,2*length(L1C_Q)]),Freq).*cos(2*pi*1600.995e6*(1/Freq:1/Freq:8e-3));
%Signal = circshift(Signal,[0 -ceil(Freq*30760e-9)]);
save('Signal_L1.mat','Signal','Freq');