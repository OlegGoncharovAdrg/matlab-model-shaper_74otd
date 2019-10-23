function [Samples_out] = Sampling(duration,array_in,Freq)
    Time_Chip_Seq = duration; % ����� �������� ������������ ������������������ ����� (� ��������)
    Chip_Seq = array_in;
    Time_Sample = 1/Freq; % ������������ ������� � �������� (������� �������)
    Number_Samples = floor(Time_Chip_Seq/Time_Sample); % ���������� �������� � �������
    Sample_Seq = zeros(1,Number_Samples); % ������������������ ��������
    Time_Chip = Time_Chip_Seq/length(Chip_Seq) ; % ������������ ����
    i = 1; % ������� �����
    Chip_Margin = Time_Chip; % ������� ��������� ������� �����
    Sample_Margin = 0; % ������� ��������� ������� ��������
    for j = 1:Number_Samples
        if Sample_Margin > Chip_Margin
            i = i+1;
            Chip_Margin = Chip_Margin + Time_Chip;
        end
        Sample_Margin = Sample_Margin + Time_Sample;
        Sample_Seq(j) = Chip_Seq(i);
    end
    Samples_out = Sample_Seq;
end

