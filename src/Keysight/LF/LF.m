clear; close all; clc;

Freq = 122.76e6;
% ЧАСТОТНЫЙ СИГНАЛ I
L1F_PT = zeros(1,511);
x = [1 1 1 1 1 1 1 1 1]; % Стартовая последовательность
for i = 1:511
   L1F_PT(i) = x(7);
   x_temporary = xor(x(5), x(9));
   x = circshift(x,[0 1]);
   x(1) = x_temporary;
end

L1F_PT(L1F_PT==1)=-1;
L1F_PT(L1F_PT==0)=1;
%% ЧАСТОТНЫЙ СИГНАЛ Q
Freq_chip = 5.11e6; % Частота следования импульсов

T = 0:1/Freq_chip:1 - 1/Freq_chip; % Дискреты времени, определяющие формируемую ПСП
Number_PRN_RAZR = 25; % Число разрядов генератора ДК
x1 = ones(1,Number_PRN_RAZR); % Начальное состояние ГДК
L1F_VT = nan(1, length(T)); % Формирование ДК
for t = 1:length(T)
    L1F_VT(t) = x1(10);
    temp = xor(x1(3),x1(25));
    x1 = circshift(x1,[0 1]);
    x1(1) = temp;
end
L1F_VT(L1F_VT==1)=-1;
L1F_VT(L1F_VT==0)=1;
Signal = complex(Sampling(1,kron(ones(1,1e3),L1F_PT),Freq),Sampling(1,L1F_VT,Freq));
Signal = circshift(Signal,[0 -ceil(Freq*30700e-9)]);
save('Signal_LF.mat','Signal','Freq');
clear;