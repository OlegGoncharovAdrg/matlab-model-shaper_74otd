function [Samples_out] = Sampling(duration,array_in,Freq)
    Samples_out = zeros(1,ceil(duration/(1/Freq))); % Последовательность отсчетов
    i = 1; % Счетчик чипов
    Chip_Margin = duration/length(array_in); % Текущая временная граница чипов
    Sample_Margin = 0; % Текущая временная граница отсчетов
    for j = 1:ceil(duration/(1/Freq))
        if Sample_Margin > Chip_Margin
            i = i+1;
            Chip_Margin = Chip_Margin + duration/length(array_in);
        end
        Sample_Margin = Sample_Margin + 1/Freq;
        Samples_out(j) = array_in(i);
    end
end

