function n1=prn2num(prnL1SC, prnL1OC)
% ���������� ������ ���� n1 � ��������� ������� [s_L1SC(t)+s_L1OC(t)] �
% ����������� �� �������� ������������ ������������������� �������� L1SC �
% L1OC

% �� ������-�� ��� ������� ��������� ��� �������� ������� � ������� �
% ��������� �����������!

% %---- ������ �������������
% clear all; close all; clc;
% prnL1SC=1 % �������� 0 ��� 1
% prnL1OC=1 % �������� 0 ��� 1
% n1=prn2num(prnL1SC, prnL1OC)
% %---- ����� ������� �������������

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

