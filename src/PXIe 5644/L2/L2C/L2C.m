clear; close all; clc; 
t = 1;
Freq = 45e6;
% L2 KSI
InitialStates = strcat('0000', dec2bin(1:63))-'0';
x_exit_L2KSI = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 1 0 0 1],...
'InitialStates', [0 0 1 1 0 0 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 1],   ...
'NumBitsOut',    1023))',generate(commsrc.pn('GenPoly', [1 0 0 1 0 0 0 1 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 1023))');
x_exit_L2KSI(x_exit_L2KSI==1)=-1;
x_exit_L2KSI(x_exit_L2KSI==0)=1;

% L2OCp
InitialStates = strcat('1', dec2bin(1:63))-'0';
x_exit_L2OCp = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1],...
'InitialStates', [0 0 1 1 0 1 0 0 1 1 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1], ...
'NumBitsOut', 10230))',generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 1], 'NumBitsOut', 10230))');
x_exit_L2OCp(x_exit_L2OCp==1)=-1;
x_exit_L2OCp(x_exit_L2OCp==0)=1;

% L2SCd
InitialStates = strcat('0000000',dec2bin(1:63))-'0';
x_exit_L2SCd = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 0 0 1 1 0 1 1],...
'InitialStates', [0 0 0 1 0 1 1 1 1 0 1 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut', 5115))',generate(commsrc.pn('GenPoly', [1 1 0 0 0 1 0 0 0 0 0 1 0 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 1],...
'NumBitsOut', 5115))');
x_exit_L2SCd(x_exit_L2SCd==1)=-1;
x_exit_L2SCd(x_exit_L2SCd==0)=1;

% L2SCp
InitialStates = strcat('0',dec2bin(1:63))-'0';
x_exit_L2SCp = bitxor(generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1],...
'InitialStates', [0 0 1 1 0 1 0 0 1 1 1 0 0 0], 'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1], ...
'NumBitsOut',    10230))',generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1],...
'InitialStates', InitialStates(t,:), 'Mask', [0 0 0 0 0 0 1], 'NumBitsOut', 10230))');
x_exit_L2SCp(x_exit_L2SCp==1)=-1;
x_exit_L2SCp(x_exit_L2SCp==0)=1;


% Создание последовательностей ДК длительностью 8 мс
L1SCd_c1_8 = kron ([1 1], x_exit_L2SCd);
L1SCp_c1_8 = x_exit_L2SCp;

% Создание составляющих компоненты L1C_I c поднесущими
L1SCd_c1_8_sc = kron (L1SCd_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)
L1SCp_c1_8_sc = kron (L1SCp_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)

% Создание видеосигнала квадратурной компоненты L1C_I c поднесущими
L2C_I = ones(1,8*length(L1SCd_c1_8));
for i= 1:length(L1SCd_c1_8);
   L2C_I(8*i - 7) = L1SCd_c1_8_sc(4*i-3);
   L2C_I(8*i - 6) = L1SCd_c1_8_sc(4*i-2);
   L2C_I(8*i - 5) = L1SCd_c1_8_sc(4*i-1);
   L2C_I(8*i - 4) = L1SCd_c1_8_sc(4*i);
   L2C_I(8*i - 3) = L1SCp_c1_8_sc(4*i-3);
   L2C_I(8*i - 2) = L1SCp_c1_8_sc(4*i-2);
   L2C_I(8*i - 1) = L1SCp_c1_8_sc(4*i-1);
   L2C_I(8*i) = L1SCp_c1_8_sc(4*i);   
end
Code_Signal_I = Sampling(8e-3,L2C_I,Freq);
Code_Signal_I = kron(ones(1,125),Code_Signal_I);

% Дополняем до 40 мс
L2DKSI_c1_40 = kron(ones(1,20), x_exit_L2KSI); 
L2DKSI_c1_40_sc = kron (L2DKSI_c1_40, [1 1]);
L2DKSI_c1_1__sc = kron (ones(1,25), L2DKSI_c1_40_sc); % Дополняем до 1 с

L2OCp_c1_40 = kron(ones(1,2), x_exit_L2OCp);
L2OCp_c1_40_sc = kron(L2OCp_c1_40, [1 -1]);
 
OK = [0 0 1 0 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 ...
    0 0 0 0 0 0 1 0 1 1 0 0 0 1 0 0 0 1 0];
OK(OK==1)=-1;
OK(OK==0)=1;
OK = reshape(OK,[2,25]);
L2OCp_c1_1_sc_without_OK = kron (ones(1,25), L2OCp_c1_40_sc); % Дополняем до 1 с
L2OCp_c1_1_sc = nan(1,25*length(L2OCp_c1_40_sc));

for k = 1:length(OK)
    L2OCp_c1_1_sc((k-1)*length(L2OCp_c1_40_sc)+1:(k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2) = L2OCp_c1_1_sc_without_OK((k-1)*length(L2OCp_c1_40_sc)+1:(k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2)*OK(1,k);
    L2OCp_c1_1_sc((k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2+1:k*length(L2OCp_c1_40_sc)) = L2OCp_c1_1_sc_without_OK((k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2+1:k*length(L2OCp_c1_40_sc))*OK(2,k);
end

% Создание видеосигнала квадратурной компоненты L1C_Q c поднесущими
L2C_Q = nan(1,2*length(L2DKSI_c1_1__sc));
for i = 1:length(L2DKSI_c1_1__sc)/2
    L2C_Q(4*i - 3) = L2DKSI_c1_1__sc(2*i-1);
    L2C_Q(4*i - 2) = L2DKSI_c1_1__sc(2*i);
    L2C_Q(4*i - 1) = L2OCp_c1_1_sc(2*i-1);
    L2C_Q(4*i) = L2OCp_c1_1_sc(2*i);   
end

Code_Signal_Q = Sampling(1,L2C_Q,Freq);

Code_Signal_I(1:ceil(length(Code_Signal_I)/100)) = 2*Code_Signal_I(1:ceil(length(Code_Signal_I)/100));
Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100)) = 2*Code_Signal_Q(1:ceil(length(Code_Signal_Q)/100));

T_SEQ = 1;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(Code_Signal_I);
IQ(2:2:end) = single(Code_Signal_Q);
IQ = IQ /  max(abs(single(Code_Signal_I) + 1i*single(Code_Signal_Q)));
IQ = floor((IQ*32767+0.5)); % длительность 8 мсек
fileID = fopen('L2_С.bin','w');
fwrite  (fileID, kron(ones(1,4),IQ), 'int16');
fclose(fileID);