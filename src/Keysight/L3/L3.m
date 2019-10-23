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
Signal = complex(Sampling(1,kron(ones(1,100),L3OCd),Freq),Sampling(1,kron(ones(1,100),L3OCp),Freq));
Signal = circshift(Signal,[0 -ceil(Freq*30700e-9)]);

save('Signal_L3C.mat','Signal','Freq');