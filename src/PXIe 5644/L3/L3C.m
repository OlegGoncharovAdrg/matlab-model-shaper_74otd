clear; close all; clc

t = 2; % номер КА
Freq = 45e6;

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


Code_Signal_I = Sampling(10e-3,L3OCd,Freq);
Code_Signal_Q = Sampling(10e-3,L3OCp,Freq);

Code_Signal_I(1:ceil(length(Code_Signal_I)/100)) = 2*Code_Signal_I(1:ceil(length(Code_Signal_I)/100));
Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100)) = 2*Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100));

T_SEQ = 10e-3;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(Code_Signal_I);
IQ(2:2:end) = single(Code_Signal_Q);
IQ = IQ /  max(abs(single(Code_Signal_I) + 1i*single(Code_Signal_Q)));
IQ = floor((IQ*32767+0.5)); % длительность 8 мсек

fileID = fopen('L3_С.bin','w');
fwrite  (fileID, kron(ones(1,400),IQ), 'int16');
fclose(fileID);