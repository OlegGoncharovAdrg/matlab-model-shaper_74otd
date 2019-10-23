clear; close all; clc;

Freq = 122.76e6;
t = 1;
InitialStates = strcat('0', dec2bin(1:63))-'0';
x_exit_L3OCd = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 1],   ...
'NumBitsOut',    10230))',generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1],...
'InitialStates', [0 0 1 1 0 1 0 0 1 1 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'NumBitsOut',    10230))');
x_exit_L3OCd(x_exit_L3OCd==1)=-1;
x_exit_L3OCd(x_exit_L3OCd==0)=1;
     
InitialStates = strcat('1', dec2bin(1:63))-'0';
x_exit_L3OCp = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 1],...
'NumBitsOut',    10230))',generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1],...
'InitialStates', [0 0 1 1 0 1 0 0 1 1 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut',    10230))');
x_exit_L3OCp(x_exit_L3OCp==1)=-1;
x_exit_L3OCp(x_exit_L3OCp==0)=1;

KB = [0 0 0 1 0]; % Код Баркера на 5 мс
KB(KB==1)=-1;
KB(KB==0)=1;
KB = kron(ones(1,2),KB); % Код Баркера на 10 мс

HC = [0 0 0 0 1 1 0 1 0 1]; % Код Ньюмана-Хоффмана на 10 мс
HC(HC==1)=-1;
HC(HC==0)=1;

L3OCd = kron(KB, x_exit_L3OCd); % Последовательность на 10 мс с кодом Баркера
L3OCp = kron(HC,x_exit_L3OCp); % Последовательность на 10 мс с кодом Ньюмана-Хоффмана
Signal = complex(Sampling(1,kron(ones(1,1e2),L3OCd),Freq),Sampling(1,kron(ones(1,1e2),L3OCp),Freq));

% Сохраним в WV
wvfile = 'L3C.wv';  
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