clear; close all; clc;

Freq = 122.76e6;
% ��������� ������ I
L1F_PT = zeros(1,511);
x = [1 1 1 1 1 1 1 1 1]; % ��������� ������������������
for i = 1:511
   L1F_PT(i) = x(7);
   x_temporary = xor(x(5), x(9));
   x = circshift(x,[0 1]);
   x(1) = x_temporary;
end

L1F_PT(L1F_PT==1)=-1;
L1F_PT(L1F_PT==0)=1;

%% ��������� ������ Q
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
L1F_VT(L1F_VT==1)=-1;
L1F_VT(L1F_VT==0)=1;



Signal = complex(Sampling(1,kron(ones(1,1e3),L1F_PT),Freq),Sampling(1,L1F_VT,Freq));


% �������� � WV
wvfile = 'LF.wv';  
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