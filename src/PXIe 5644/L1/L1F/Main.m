clear; close all; clc
Freq = 45e6;
%% ��������� ������ I
L1F_PT = zeros(1,511);
x = [1 1 1 1 1 1 1 1 1]; % ��������� ������������������
for i = 1:511
   L1F_PT(i) = x(7);
   x_temporary = xor(x(5), x(9));
   x = circshift(x,[0 1]);
   x(1) = x_temporary;
end

L1F_PT(L1F_PT==1)=1;
L1F_PT(L1F_PT==0)=-1;
Freq_Signal_I = Sampling(1e-3,L1F_PT,Freq);
Freq_Signal_I = kron(ones(1,1e3),Freq_Signal_I);

Freq_chip = 5.11e6; % ������� ���������� ���������
T = 0:1/Freq_chip:1 - 1/Freq_chip; % �������� �������, ������������ ����������� ���
Number_PRN_RAZR = 25; % ����� �������� ���������� ��
x1 = ones(1,Number_PRN_RAZR); % ��������� ��������� ���
L1F_VT = nan(1, length(T)); % ������������ ��
for t = 1:length(T)
    L1F_VT(t) = x1(10);
    temp = xor(x1(3),x1(25));
    x1 = circshift(x1,[0 1]);
    x1(1) = temp;
end
L1F_VT(L1F_VT==1)=1;
L1F_VT(L1F_VT==0)=-1;
Freq_Signal_Q = Sampling(1,L1F_VT,Freq);


Freq_Signal_I(1:ceil(length(Freq_Signal_I)/100)) = 2*Freq_Signal_I(1:ceil(length(Freq_Signal_I)/100));
Freq_Signal_Q(1:ceil(length(Freq_Signal_Q)/100)) = 2*Freq_Signal_Q(1:ceil(length(Freq_Signal_Q)/100));

T_SEQ = 1;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(Freq_Signal_I);
IQ(2:2:end) = single(Freq_Signal_Q);
IQ = IQ /  max(abs(single(Freq_Signal_I) + 1i*single(Freq_Signal_Q)));
IQ = floor((IQ*32767+0.5)); 
fileID = fopen('L1_F.bin','w');
fwrite  (fileID, IQ, 'int16');
fclose(fileID);