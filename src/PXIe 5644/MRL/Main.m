clear; close all; clc

load('Samples_of_PRN.mat');
Freq = 45e6; % частота дискритизации
% частота дискритизации несущей 250e3*(n-1)+2211,75 МГц
T = 5; % длительность в секундах
T_PSP_0 = 0.9765;
T_PSP_V = 3.608;
% задаем ПСП-В-I
PSP_V_I = generate(commsrc.pn('GenPoly', [1 1 1 0 0 0 0 1 0 0 1 1 1], 'InitialStates', ones(1,12),...
'Mask', [0 0 0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 4095))';
PSP_V_I(PSP_V_I==1)=-1;
PSP_V_I(PSP_V_I==0)=1;
% задаем ПСП-О-I
PSP_O_I = generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 0 0 0 1 1 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 0 1 1], 'InitialStates', ones(1,32),...
'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'NumBitsOut',18761600 ))';
PSP_O_I(PSP_O_I==1)=-1;
PSP_O_I(PSP_O_I==0)=1;
zero = zeros(1,Freq*0.4155);

PSP_I = [kron([kron(ones(1,296),PSP_V_I) kron([-1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1],PSP_V_I)],[1 1 1 1]) PSP_O_I];
Litera_1 = complex([Sampling((T-0.4155),PSP_I,Freq) zero], [Sampling((T-0.4155),PSP_I,Freq) zero]);
Litera_1_M8190A = circshift(Litera_1,[0, -ceil(85e-6*Freq)]);
save('Litera_1.mat','Litera_1_M8190A','Freq');
clearvars -except Freq Litera_1;

T_SEQ = 5;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(real(Litera_1));
IQ(2:2:end) = single(imag(Litera_1));
IQ = IQ /  max(abs(single(real(Litera_1)) + 1i*single(imag(Litera_1))));
IQ = floor((IQ*32767+0.5)); 
fileID = fopen('MRL_1_sec.bin','w');
fwrite  (fileID, IQ, 'int16');
fclose(fileID);