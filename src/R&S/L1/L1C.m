clear; close all; clc
%% Вызов функций формирования сигналов с чатотным и кодовым разделением
Freq = 122.76e6; % Частота дискретизации
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
Signal = complex(Sampling(1,kron(ones(1,125),reshape(L1C_I, [1,4*length(L1C_I)])),Freq),...
    Sampling(1,kron(ones(1,125),reshape(L1C_Q, [1,2*length(L1C_Q)])),Freq));


% Сохраним в WV
wvfile = 'L1C.wv';  
IQ_data_len = length(single(real(Signal)));
IQ_data = single(zeros(1, 2*IQ_data_len));  
IQ_data(1:2:end) = single(real(Signal));
IQ_data(2:2:end) = single(imag(Signal));
IQ_data = IQ_data /  max(abs(single(real(Signal)) + 1i*single(imag(Signal))));
rms  = sqrt(mean(IQ_data(1:2:end).*IQ_data(1:2:end) + IQ_data(2:2:end).*IQ_data(2:2:end))) / 1.0;
IQ_data = floor((IQ_data*32767+0.5)); 

WV_file_id = fopen(wvfile,'wb+');
fprintf (WV_file_id, '%s','{TYPE: SMU-WV, 0}' ); 
fprintf (WV_file_id, '%s','{ORIGIN INFO: RS Matlab Toolkit}' );
fprintf (WV_file_id, '%s','{LEVEL OFFS: ',num2str(20*log10(1.0/rms)),', ',num2str(20*log10(1.0)),'}');
fprintf (WV_file_id, '%s', ['{DATE: ' datestr(date,29) ';' datestr(clock,13) '}']);
fprintf (WV_file_id, '%s','{CLOCK: ', num2str(Freq),'}'); 
fprintf (WV_file_id, '%s','{SAMPLES: ', num2str(IQ_data_len),'}');
fprintf (WV_file_id, '%s','{WAVEFORM-',num2str(length(IQ_data)*2 + 1),': #');
fwrite  (WV_file_id, IQ_data, 'int16');
fprintf (WV_file_id, '%s','}' ); 
fclose  (WV_file_id);
