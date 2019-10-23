clear; close all; clc; 
t = 1;
choose_SN = t+1;
Freq = 122.76e6;
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
%% L2_ksi
k = [0 0 1 1 0 0 1 0 0 0]; % НС1
%НС2 
str = [zeros(1,10); zeros(63,4) num2str(dec2bin(1:63))-'0'];
start_PRN = str (choose_SN,:);
% задаем ПСП ДК 1
L2_ksi1 = generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 0 1 0 0 1], 'InitialStates', k,...
'Mask', [0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 1023))';
L2_ksi1(L2_ksi1==1)=-1;
L2_ksi1(L2_ksi1==0)=1;
% задаем ПСП ДК 2
L2_ksi2 = generate(commsrc.pn('GenPoly', [1 0 0 1 0 0 0 1 0 1 1], 'InitialStates', start_PRN,...
'Mask', [ 0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 1023))';
L2_ksi2(L2_ksi2==1)=-1;
L2_ksi2(L2_ksi2==0)=1;
% соединяем
L2_ksi = L2_ksi1.*L2_ksi2;
%% проверяем сингнал L2_ksi
L2_ksi_proverka = L2_ksi;
L2_ksi_proverka(L2_ksi_proverka ==1)= 0;
L2_ksi_proverka(L2_ksi_proverka == -1)= 1;
first_sim_L2_ksi = {'13228DB8', '9306460E', '531423D5', 'D330E863', '3339DA8E', 'B31D1138',...
    '730F74E3', 'F32BBF55', '030BED95', '832F2623', '433D43F8', 'C319884E', '2310BAA3',...
    'A3347115', '632614CE', 'E302DF78', '1B363DAE', '9B12F618', '5B0093C3', 'DB245875',...
    '3B2D6A98', 'BB09A12E', '7B1BC4F5', 'FB3F0F43', '0B1F5D83', '8B3B9635', '4B29F3EE',...
    'CB0D3858', '2B040AB5', 'AB20C103', '6B32A4D8', 'EB166F6E', '1728D5B3', '970C1E05',...
    '571E7BDE', 'D73AB068', '37338285', 'B7174933', '77052CE8', 'F721E75E', '0701B59E',...
    '87257E28', '47371BF3', 'C713D045', '271AE2A8', 'A73E291E', '672C4CC5', 'E7088773',...
    '1F3C65A5', '9F18AE13', '5F0ACBC8', 'DF2E007E', '3F273293', 'BF03F925', '7F119CFE',...
    'FF355748', '0F150588', '8F31CE3E', '4F23ABE5', 'CF076053', '2F0E52BE', 'AF2A9908',...
    '6F38FCD3', 'EF1C3765'};
    a_L2_ksi =  dec2bin(hex2dec(first_sim_L2_ksi(choose_SN)))-'0';
    a_L2_ksi = [ zeros(1, 32-length(a_L2_ksi)) a_L2_ksi];
    d = L2_ksi_proverka(1:32);
    n = isequal(a_L2_ksi,d);   
    end_sim_L2_ksi = {'D51F792C', '0E8093A7', '634F66E2', 'B8D08C69', '8E3776CB', '55A89C40',...
    '38676905', 'E3F8838E', 'A3149454', '788B7EDF', '15448B9A', 'CEDB6111', 'F83C9BB3',...
    '23A37138', '4E6C847D', '95F36EF6', 'EE1A8F90', '3585651B', '584A905E', '83D57AD5',...
    'B5328077', '6EAD6AFC', '03629FB9', 'D8FD7532', '981162E8', '438E8863', '2E417D26',...
    'F5DE97AD', 'C3396D0F', '18A68784', '756972C1', 'AEF6984A', 'C89D8272', '130268F9',...
    '7ECD9DBC', 'A5527737', '93B58D95', '482A671E', '25E5925B', 'FE7A78D0', 'BE966F0A',...
    '65098581', '08C670C4', 'D3599A4F', 'E5BE60ED', '3E218A66', '53EE7F23', '887195A8',...
    'F39874CE', '28079E45', '45C86B00', '9E57818B', 'A8B07B29', '732F91A2', '1EE064E7',...
    'C57F8E6C', '859399B6', '5E0C733D', '33C38678', 'E85C6CF3', 'DEBB9651', '05247CDA',...
    '68EB899F', 'B3746314'};
    b_L2_ksi =  dec2bin(hex2dec(end_sim_L2_ksi(choose_SN)))-'0';
    b_L2_ksi = [ zeros(1, 32-length(b_L2_ksi)) b_L2_ksi];
    e = L2_ksi_proverka(end-31:end);
    m = isequal(b_L2_ksi,e);   
if n==1 && m==1
        fprintf('дальномерный код сигнала L2_KSI верен\n');
    else
        fprintf('дальномерный код сигнала L2_KSI не верен\n');
end 
%% L2O_Cp
k = [0 0 1 1 0 1 0 0 1 1 1 0 0 0]; % НС1
%НС2 
str1 = [zeros(1,6); num2str(dec2bin(1:63))-'0'];
str = [ones(64,1) str1];
start_PRN = str (choose_SN,:);
% задаем ПСП ДК 1
L2O_Cp1 = generate(commsrc.pn('GenPoly', [1 0 0 0 1 0 0 0 1 0 0 0 0 1 1], 'InitialStates', k,...
'Mask', [0 0 0 0 0 0 0 0 0 0 0 0 0 1], 'NumBitsOut', 10230))';
L2O_Cp1(L2O_Cp1==1)=-1;
L2O_Cp1(L2O_Cp1==0)=1;
% задаем ПСП ДК 2
L2O_Cp2 = generate(commsrc.pn('GenPoly', [1 0 0 0 0 0 1 1], 'InitialStates',start_PRN ,...
'Mask', [0 0 0 0 0 0 1], 'NumBitsOut', 10230))';
L2O_Cp2(L2O_Cp2==1)=-1;
L2O_Cp2(L2O_Cp2==0)=1;
% оверлейный код 
over = [0 0 1 0 1 1 0 1 0 1 1 1 1 1 0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 0 0 0 0 ...
 0 1 0 1 1 0 0 0 1 0 0 0 1 0];

%over = ones(1,50);
over(over==1)=-1;
over(over==0)=1;
% собираем ДК L2O_Cp
L2O_Cp = L2O_Cp1.*L2O_Cp2;
%% проверяем ДК L2O_Cp
proverka_L2O_Cp = L2O_Cp;
proverka_L2O_Cp(proverka_L2O_Cp==1)=0;
proverka_L2O_Cp(proverka_L2O_Cp==-1)=1;
first_sim_L2O_Cp = {'1EBF3DE2', '9FB9299B', '5F3A23A7', 'DE3C37DE', '3E7DB2C0', 'BF7BA6B9',...
    '7FF8AC85', 'FEFEB8FC', '0EDE7A73', '8FD86E0A', '4F5B6436', 'CE5D704F', '2E1CF551',...
    'AF1AE128', '6F99EB14', 'EE9FFF6D', '168F9E2A', '97898A53', '570A806F', 'D60C9416',...
    '364D1108', 'B74B0571', '77C80F4D', 'F6CE1B34', '06EED9BB', '87E8CDC2', '476BC7FE',...
    'C66DD387', '262C5699', 'A72A42E0', '67A948DC', 'E6AF5CA5', '1AA76C06', '9BA1787F',...
    '5B227243', 'DA24663A', '3A65E324', 'BB63F75D', '7BE0FD61', 'FAE6E918', '0AC62B97',...
    '8BC03FEE', '4B4335D2', 'CA4521AB', '2A04A4B5', 'AB02B0CC', '6B81BAF0', 'EA87AE89',...
    '1297CFCE', '9391DBB7', '5312D18B', 'D214C5F2', '325540EC', 'B3535495', '73D05EA9',...
    'F2D64AD0', '02F6885F', '83F09C26', '4373961A', 'C2758263', '2234077D', 'A3321304',...
    '63B11938', 'E2B70D41'};
    a_L2O_Cp =  dec2bin(hex2dec(first_sim_L2O_Cp(choose_SN)))-'0';
    a_L2O_Cp = [ zeros(1, 32-length(a_L2O_Cp)) a_L2O_Cp];
    d = proverka_L2O_Cp(1:32);
    n = isequal(a_L2O_Cp,d);   
    end_sim_L2O_Cp = {'1BA445DE', '86EBE41A', '484C34F8', 'D503953C', 'B2507D4D', '2F1FDC89',...
    'E1B80C6B', '7CF7ADAF', 'CF5E5997', '5211F853', '9CB628B1', '01F98975', '66AA6104',...
    'FBE5C0C0', '35421022', 'A80DB1E6', 'F1D94BFA', '6C96EA3E', 'A2313ADC', '3F7E9B18',...
    '582D7369', 'C562D2AD', '0BC5024F', '968AA38B', '252357B3', 'B86CF677', '76CB2695',...
    'EB848751', '8CD76F20', '1198CEE4', 'DF3F1E06', '4270BFC2', '6E9AC2CC', 'F3D56308',...
    '3D72B3EA', 'A03D122E', 'C76EFA5F', '5A215B9B', '94868B79', '09C92ABD', 'BA60DE85',...
    '272F7F41', 'E988AFA3', '74C70E67', '1394E616', '8EDB47D2', '407C9730', 'DD3336F4',...
    '84E7CCE8', '19A86D2C', 'D70FBDCE', '4A401C0A', '2D13F47B', 'B05C55BF', '7EFB855D',...
    'E3B42499', '501DD0A1', 'CD527165', '03F5A187', '9EBA0043', 'F9E9E832', '64A649F6',...
    'AA019914', '374E38D0'};
    b_L2O_Cp =  dec2bin(hex2dec(end_sim_L2O_Cp(choose_SN)))-'0';
    b_L2O_Cp = [ zeros(1, 32-length(b_L2O_Cp)) b_L2O_Cp];
    e = proverka_L2O_Cp(end-31:end);
    m = isequal(b_L2O_Cp,e);   
if n==1 && m==1
        fprintf('дальномерный код сигнала L2O_Cp верен\n');
    else
        fprintf('дальномерный код сигнала L2O_Cp не верен\n');
end 
% соединяем ОК с ДК и накладываем МП
L2O_Cp = kron((kron(over,(L2O_Cp1.*L2O_Cp2))),[0 0 -1 1]);
% формироуем сигналы на ортах и соединяем
L2_Q = kron(ones(1,500),(kron(L2_ksi, [1 1 0 0])))+L2O_Cp;
% Signal_L2C = complex(Sampling(1,kron(ones(1,125),L2C_I),Freq),Sampling(1,L2_Q,Freq));
% Signal_L2C(1:1e3) = 2*Signal_L2C(1:1e3);
% Signal_L2C = circshift(Signal_L2C,[0 -ceil(Freq*30700e-9)]);
% save('Signal_L2.mat','Signal_L2C','Freq');