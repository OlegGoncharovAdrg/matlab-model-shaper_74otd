clear; close all; clc
%% Вызов функций формирования сигналов с чатотным и кодовым разделением
Freq = 4*45e6; % Частота дискретизации
% L1F_PT
L1F_PT = generate(commsrc.pn('GenPoly', [1 0 0 0 0 1 0 0 0 1],...
'InitialStates', ones(1,9), 'Mask', [0 0 0 0 0 0 1 0 0],...
'NumBitsOut', 511))';
L1F_PT(L1F_PT==1)=-1;
L1F_PT(L1F_PT==0)=1;

% L1F_VT
L1F_VT = generate(commsrc.pn('GenPoly', [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],...
'InitialStates', ones(1,25), 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut', 5.11e6))';
L1F_VT(L1F_VT==1)=-1;
L1F_VT(L1F_VT==0)=1;

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
%% Создание поднесущей частоты
Time_Chip_Seq = 1; % Длительность базы
Sub_Freq = 30.69e6; % !!!!Значение поднесущей частоты
Sub_Freq_C = Sub_Freq; % !!!!Значение поднесущей частоты для кодового сигнала (на несущей 1600.995 МГц)
k = 3; % Номер литеры для сигнала с частотным разделением
Sub_Freq_F = Sub_Freq + k*0.5625e6 + 1.005e6;
kf = 0.903584; % Коэффициент для ослабления частотной компоненты
numberOfSamples = Freq*Time_Chip_Seq;
Signal = sign(complex(- kron(ones(1,1e3),Sampling(1e-3,L1F_PT,Freq)) .* sin(Sub_Freq_F * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)*kf...
    + Sampling(1,L1F_VT,Freq) .* cos(Sub_Freq_F * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)*kf...
    -  kron(ones(1,125),Sampling(8e-3,reshape(L1C_I, [1,4*length(L1C_I)]),Freq)) .* sin(Sub_Freq_C * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)...
    + kron(ones(1,125),Sampling(8e-3,reshape(L1C_Q, [1,2*length(L1C_Q)]),Freq)) .* cos(Sub_Freq_C * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)...
    ,Sampling(1,L1F_VT,Freq) .* sin(Sub_Freq_F * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)*kf...
    + kron(ones(1,1e3),Sampling(1e-3,L1F_PT,Freq)) .* cos(Sub_Freq_F * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)*kf...
    + kron(ones(1,125),Sampling(8e-3,reshape(L1C_Q, [1,2*length(L1C_Q)]),Freq)) .* sin(Sub_Freq_C * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi) + ...
    kron(ones(1,125),Sampling(8e-3,reshape(L1C_I, [1,4*length(L1C_I)]),Freq)) .* cos(Sub_Freq_C * Time_Chip_Seq * (1:numberOfSamples)/numberOfSamples * 2*pi)));

Signal = Signal.*exp(-sqrt(-1)*2*pi*(Sub_Freq)*(1/Freq:1/Freq:Time_Chip_Seq));

dec_factor = 4;
Signal = decimate(Signal,dec_factor);
%Signal(1:ceil(length(Signal)/50)) = 2*Signal(1:ceil(length(Signal)/50));
T_SEQ = 1;
IQ = nan(1,2*T_SEQ*Freq/dec_factor);       
IQ(1:2:end) = single(real(Signal));
IQ(2:2:end) = single(imag(Signal));
IQ = IQ /  max(abs(single(real(Signal)) + 1i*single(imag(Signal))));
IQ = floor((IQ*32767+0.5)); % длительность 8 мсек

fileID = fopen('L1Group.bin','w');
fwrite  (fileID, kron(ones(1,4),IQ), 'int16');
fclose(fileID);