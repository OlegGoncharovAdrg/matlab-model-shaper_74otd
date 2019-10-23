function n1=prn2num(prnL1SC, prnL1OC)
% Вычисление номера фазы n1 в созвездии сигнала [s_L1SC(t)+s_L1OC(t)] в
% зависимости от значений модулирующих последовательностей сигналов L1SC и
% L1OC

% Да вообще-то эта функция одинакова для сигналов ГЛОНАСС с кодовым и
% частотным разделением!

% %---- Пример использования
% clear all; close all; clc;
% prnL1SC=1 % значение 0 или 1
% prnL1OC=1 % значение 0 или 1
% n1=prn2num(prnL1SC, prnL1OC)
% %---- Конец примера использования

% % % if prnL1SC==1 & prnL1OC==1
% % %     n1=0;
% % % elseif prnL1SC==1 & prnL1OC==-1
% % %     n1=3;
% % % elseif prnL1SC==-1 & prnL1OC==1
% % %     n1=1;
% % % elseif prnL1SC==-1 & prnL1OC==-1
% % %     n1=2;
% % % end

if prnL1SC==-1 & prnL1OC==-1
    n1=0;
elseif prnL1SC==-1 & prnL1OC==1
    n1=3;
elseif prnL1SC==1 & prnL1OC==-1
    n1=1;
elseif prnL1SC==1 & prnL1OC==1
    n1=2;
end

% % % if prnL1SC==0 & prnL1OC==0
% % %     n1=0;
% % % elseif prnL1SC==0 & prnL1OC==1
% % %     n1=3;
% % % elseif prnL1SC==1 & prnL1OC==0
% % %     n1=1;
% % % elseif prnL1SC==1 & prnL1OC==1
% % %     n1=2;
% % % end

