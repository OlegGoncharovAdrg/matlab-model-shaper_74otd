clear; close all; clc

t = 2; % ����� ��
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

KB = [0 0 0 1 0]; % ��� ������� �� 5 ��
KB(KB==1)=-1;
KB(KB==0)=1;
KB = kron(ones(1,2),KB); % ��� ������� �� 10 ��

HC = [0 0 0 0 1 1 0 1 0 1]; % ��� �������-�������� �� 10 ��
HC(HC==1)=-1;
HC(HC==0)=1;

L3OCd = kron(KB, x_exit_L3OCd); % ������������������ �� 10 �� � ����� �������
L3OCp = kron(HC,x_exit_L3OCp); % ������������������ �� 10 �� � ����� �������-��������


Code_Signal_I = Sampling(10e-3,L3OCd,Freq);
Code_Signal_Q = Sampling(10e-3,L3OCp,Freq);

Code_Signal_I(1:ceil(length(Code_Signal_I)/100)) = 2*Code_Signal_I(1:ceil(length(Code_Signal_I)/100));
Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100)) = 2*Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100));

T_SEQ = 10e-3;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(Code_Signal_I);
IQ(2:2:end) = single(Code_Signal_Q);
IQ = IQ /  max(abs(single(Code_Signal_I) + 1i*single(Code_Signal_Q)));
IQ = floor((IQ*32767+0.5)); % ������������ 8 ����

fileID = fopen('L3_�.bin','w');
fwrite  (fileID, kron(ones(1,400),IQ), 'int16');
fclose(fileID);