clear; close all; clc
t = 1; % ����� ��
Freq = 45e6;
k_freq = -3;
n=1024;
a=0.903584;

capacity=16; % ����������� ��� (�� ��������� capacity=14)
% �������� ���� p1, � ������, ��� n1=0 (�� ��������� p0=1/8, �.�. pi/4 ������)
% ��������� ������ ������������ p01, ��������, p01=0, ��� �������� �
% �������� ��������� ���������, �� �� �������� �� ������ ������.
p01=1/8;
%---- ����� ������� ������

% ���������� ������� �������� ���������� ������� ��� �������� ������ ���� �
% ��������� ������� [s_L1SC(t)+s_L1OC(t)], �.�. ��� ������ n1=0.
[mreal, mimag, s, maxd] = iqtable(n, a, capacity, p01);

% L2F ��
L2F_PT = generate(commsrc.pn('GenPoly', [1 0 0 0 0 1 0 0 0 1], 'InitialStates', ones(1,9),...
'Mask', [0 0 0 0 0 0 1 0 0], 'NumBitsOut', 511))';
L2F_PT(L2F_PT==1)=-1;
L2F_PT(L2F_PT==0)=1;
Freq_Signal_I = Sampling(1,kron(ones(1,1e3),L2F_PT),Freq);

% L2F ��
L2F_VT = generate(commsrc.pn('GenPoly', [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'InitialStates', ones(1,25),...
'Mask', [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0], 'NumBitsOut', 5110000))';
L2F_VT(L2F_VT==1)=-1;
L2F_VT(L2F_VT==0)=1;
Freq_Signal_Q = Sampling(1,L2F_VT,Freq);

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



% �������� ������������������� �� ������������� 8 ��
L1SCd_c1_8 = kron ([1 1], x_exit_L2SCd);
L1SCp_c1_8 = x_exit_L2SCp;

% �������� ������������ ���������� L1C_I c �����������
L1SCd_c1_8_sc = kron (L1SCd_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)
L1SCp_c1_8_sc = kron (L1SCp_c1_8, [1 -1 1 -1]); % BOC(5, 2.5)

% �������� ������������ ������������ ���������� L1C_I c �����������
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

% ��������� �� 40 ��
L2DKSI_c1_40 = kron(ones(1,20), x_exit_L2KSI); 
L2DKSI_c1_40_sc = kron (L2DKSI_c1_40, [1 1]);
L2DKSI_c1_1__sc = kron (ones(1,25), L2DKSI_c1_40_sc); % ��������� �� 1 �

L2OCp_c1_40 = kron(ones(1,2), x_exit_L2OCp);
L2OCp_c1_40_sc = kron(L2OCp_c1_40, [1 -1]);
 
OK = [0 0 1 0 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 ...
    0 0 0 0 0 0 1 0 1 1 0 0 0 1 0 0 0 1 0];
OK(OK==1)=-1;
OK(OK==0)=1;
OK = reshape(OK,[2,25]);
L2OCp_c1_1_sc_without_OK = kron (ones(1,25), L2OCp_c1_40_sc); % ��������� �� 1 �
L2OCp_c1_1_sc = nan(1,25*length(L2OCp_c1_40_sc));

for k = 1:length(OK)
    L2OCp_c1_1_sc((k-1)*length(L2OCp_c1_40_sc)+1:(k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2) = L2OCp_c1_1_sc_without_OK((k-1)*length(L2OCp_c1_40_sc)+1:(k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2)*OK(1,k);
    L2OCp_c1_1_sc((k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2+1:k*length(L2OCp_c1_40_sc)) = L2OCp_c1_1_sc_without_OK((k-1)*length(L2OCp_c1_40_sc)+length(L2OCp_c1_40_sc)/2+1:k*length(L2OCp_c1_40_sc))*OK(2,k);
end

% �������� ������������ ������������ ���������� L1C_Q c �����������
L2C_Q = nan(1,2*length(L2DKSI_c1_1__sc));
for i = 1:length(L2DKSI_c1_1__sc)/2
    L2C_Q(4*i - 3) = L2DKSI_c1_1__sc(2*i-1);
    L2C_Q(4*i - 2) = L2DKSI_c1_1__sc(2*i);
    L2C_Q(4*i - 1) = L2OCp_c1_1_sc(2*i-1);
    L2C_Q(4*i) = L2OCp_c1_1_sc(2*i);   
end

Code_Signal_Q = Sampling(1,L2C_Q,Freq);


% ���������� ������������������ ������� n1
nt=length(Code_Signal_I);
n1=zeros(nt,1);
for i=1:nt
    n1(i)=prn2num(Code_Signal_I(i), Code_Signal_Q(i));
end

% ������� �������� L1 �� � L1 �� ��� ��������� ������ k (�� ��������� fk = -0.12
fk=-2.06e6+k_freq*437.5e3;
% ���������� ���� p, � ������, ����������� ��������� exp(1j*2*pi*fk*t) ��
% ���� ������ ������������� �������
dp=fk/Freq;
% ��������������� ����������
m=n/4;
if m~=round(m)
    error('n ������ ������� �� ������!')
end
% ���������� ������������������ ������� n0
n0=zeros(nt,1);
for i=1:nt
    n0(i)=prn2num(Freq_Signal_I(i), Freq_Signal_Q(i)); % �������� ��������, ������ �������� dL1OF(i)     
end
% ������������������ ������� n2
n2=phase2num(n, dp, nt)+n0*m;
for i=1:length(n2)
    if n2(i)>=n
        n2(i)=n2(i)-n;
    elseif n2(i)<0
        n2(i)=n2(i)+n;      
    end
end

clear n0  Freq_Signal_I Freq_Signal_Q Code_Signal_I Code_Signal_Q Freq_Signal_I_exp Freq_Signal_Q_exp n0;
% ���������� I � Q
I=zeros(nt,1);
Q=zeros(nt,1);
for i=1:nt
    index=n2(i)-n1(i)*m;
    if index<0
        index=index+n;
    elseif index>=n
        index=index-n;
    end
    index=index+1; % ��������� � MATLAB ���������� ���� � �������, � �� � ����
    switch n1(i)
        case 0
            I(i)=mreal(index);
            Q(i)=mimag(index);
        case 1
            I(i)=-mimag(index);
            Q(i)=mreal(index);
        case 2
            I(i)=-mreal(index);
            Q(i)=-mimag(index);        
        case 3
            I(i)=mimag(index);
            Q(i)=-mreal(index);
    end
end
% �������� �������, ���������� �� ���

Signal=I+1j*Q;
clear I Q;

%---- ������ ����� ������������� ������ ��������� (!)

Signal = Signal.'; % ��������������� � ������ !

Signal(1:ceil(length(Signal)/50))=2*Signal(1:ceil(length(Signal)/50));
T_SEQ = 1;
IQ = nan(1,2*T_SEQ*Freq);       
IQ(1:2:end) = single(imag(Signal));
IQ(2:2:end) = single(real(Signal));
IQ = IQ /  max(abs(single(real(Signal)) + 1i*single(imag(Signal))));
IQ = floor((IQ*32767+0.5)); % ������������ 8 ����
fileID = fopen('L2Group_LIKE_BIR.bin','w');
fwrite  (fileID, kron(ones(1,4),IQ), 'int16');
fclose(fileID);