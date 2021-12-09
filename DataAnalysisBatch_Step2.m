%Takes each response window and then integrates them.
% Run this script when you are Data folder with the dates of each
% experiment
close all
clear

%Set rootdirectory to the current directory
rootdirectory = dir(pwd); 
[parentdir,~,~]=fileparts(pwd);

%data scaling dependent on your imaging frequency
DS = 25;

%Set the event window to be stored
T1 = 4;
T2 = 5;
TT = T1+T2;
Pre = -T1*DS;
Post = T2*DS;

%Set the minimal time gap allowed between events (s)
gap = 4; 

n=0;


%Run through each recording day and add the data to the table
for i=3:length(rootdirectory) 
   
    
  %Open next folder in the directory
  myFolder = fullfile(rootdirectory(i).name);     
  
  % Open the Event Times 
  % AllGreen_2 is Eventer performed on data that has been normalised in the new way
  fid = fopen(strcat(myFolder,filesep,'AllGreen_2',filesep,'eventer.output',filesep,'Data_ch1_YWave001',filesep,'txt',filesep,'times.txt'));
  C = textscan(fid,'%f');
  ET = cell2mat(C);
  
  
  %remove overlapping events 
  a = diff(ET);
  b = find(a<gap);
  
  for i=1:size(b)
      
      ET(b(i)) = NaN;
      ET(b(i)+1) = NaN;
      
  end
  
  ET = ET(~isnan(ET));
  clear a b 
  
  % Scale the event times
  EventTimes = ET.*DS;  
  N = numel(ET); % Number of events detected
  fclose(fid);
  
 % Open the responsegreen file
  CG = ephysIO(strcat(myFolder,filesep,'Nor_G.phy'));
  ZG = CG.array(:,2);
  clear CR

  
  % Open the responsered file
  CR = ephysIO(strcat(myFolder,filesep,'Nor_R.phy'));
  ZR = CR.array(:,2);
  clear CR
  

  clear C fid CRN CGN CRQA CGQA CG CR 
  

  for j=1:N
      

      %Calculate the time window for each event (1s pre and 3s post event)
      Times(j,1) = int32(EventTimes(j,1))+Pre;
      Times(j,2) = int32(EventTimes(j,1))+Post;
      
      X = Times(j,1);
      Y = Times(j,2);
      
      %Extract these timings from the igor text files of the concatenated
      %ROIs with events
      Date{:,j+n} = fullfile(rootdirectory(1).name);
      GreenResponse(:,j+n) = ZG(X:Y,1);
      RedResponse(:,j+n) = ZR(X:Y,1);
%       GreenResponseQA(:,j+n) = ZGQA(X:Y,1);
%       RedResponseQA(:,j+n) = ZRQA(X:Y,1);
      Events(1,j+n) = ET(j,1);
      
  end
  
  n=n+N;
  clear RawTimes X Y X_B Times Times_B ZG ZR ZGQA ZRQA ZGN ZRN 

end 

%Baseline subtraction and integration of responses 
Ncol = size(GreenResponse,2);

for j=1:Ncol

%Baseline Subtraction Green
BaselineG(1,j) = mean(GreenResponse(50:100,j)); %Average 2s pre event
GreenBS(:,j) = GreenResponse(:,j)-BaselineG(1,j); %Baseline subtraction
%Integration Green
tmp = cumtrapz(GreenBS(100:150,j)); %Cumulative integral from start of event time to 2s
Integrals(1,j) = max(tmp); %Calculate the max cumulative integral

%Baseline Subtraction Red
BaselineR(1,j) = mean(RedResponse(50:100,j)); %average 0-2s
RedBS(:,j) = RedResponse(:,j)-BaselineR(1,j);%Baseline subtraction
%Integration Red
tmp = cumtrapz(RedBS(100:150,j));%Cumulative integral from start of event time to 2s
Integrals(2,j) = max(tmp); %Calculate the max cumulative integral

%Log of Stev of the noise (2s)
NoiseR_SD(1,j) = log10(std(RedResponse(1:100,j)));%log(SD) -2 to 2s (log because not norm distribution)

%Calculate the Baseline CalBryte and iGluSnFR 
% Base_QA(1,j) = mean(GreenResponseQA(50:100,j));
% Base_QA(2,j) = mean(RedResponseQA(50:100,j));

%Calculate linear regression
%p = polyfit(Sec,cat(1,RedResponseN(1:50,j),RedResponseN(101:151,j)),1);
RedBS_p(:,1) = 0:0.04:TT;
RedBS_p(:,2) = RedBS(:,j);
RedBS_p(100:150,:) = [];
p = polyfit(RedBS_p(:,1),RedBS_p(:,2),1); 
LR(1,j) = p(1);
clear RedBS_p

end

% %Remove Noisy data (Tukeys method)
% IQRR = iqr(NoiseR_SD);%(log because not norm distribution)
% Tukey_RL = prctile(NoiseR_SD,25) - (IQRR*2.2);
% Tukey_RU = prctile(NoiseR_SD,75) + (IQRR*2.2);
Tukey_RL = [-0.223838301697476];
Tukey_RU = [0.186404771402488];

for k = 1:Ncol
    
    if NoiseR_SD(1,k) < Tukey_RL | NoiseR_SD(1,k) > Tukey_RU
        
        Noisy(1,k) = 1;
        
    else Noisy(1,k) = 0;
        
    end
    
end

G_Temp = GreenBS;
R_Temp = RedBS;
E_Temp = Events;

GreenBS = GreenBS(:,Noisy==0);
RedBS = RedBS(:,Noisy==0);
Events = Events(1,Noisy==0);
LR = LR(1,Noisy==0);
Integrals = Integrals(:,Noisy==0);
NoiseR_SD(1,Noisy==0);

% Base_QA = Base_QA(:,Noisy==0);
RemovedG = G_Temp(:,Noisy==1);
RemovedR = R_Temp(:,Noisy==1);
RemovedT = E_Temp(1,Noisy==1);

clear Tukey_RL Tukey_RU IQRR G_Temp R_Temp E_Temp

%Remove data with significant LR of the baseline (Tukeys method)
IQR_LR = iqr(LR);
TukeyLR_L = prctile(LR,25) - (IQR_LR*2.2);
TukeyLR_U = prctile(LR,75) + (IQR_LR*2.2);


Ncol2 = size(GreenBS,2);

for k = 1:Ncol2
    
    if LR(1,k) < TukeyLR_L | LR(1,k) > TukeyLR_U
        
        NoisyLR(1,k) = 1;
        
    else NoisyLR(1,k) = 0;
        
    end
    
end

G_Temp = GreenBS;
R_Temp = RedBS;
E_Temp = Events;

GreenBS = GreenBS(:,NoisyLR==0);
RedBS = RedBS(:,NoisyLR==0);
Events = Events(1,NoisyLR==0);
LR = LR(1,NoisyLR==0);
Integrals = Integrals(:,NoisyLR==0);
NoiseR_SD(1,NoisyLR==0);
% Base_QA = Base_QA(:,NoisyLR==0);

%If you want to see the traces that were removed based on their LR
RemovedG_LR = G_Temp(:,NoisyLR==1);
RemovedR_LR = R_Temp(:,NoisyLR==1);
RemovedT_LR = E_Temp(1,NoisyLR==1);

clear TukeyLR_L TukeyLR_U IQR_LR G_Temp R_Temp E_Temp

Ncol3= size(GreenBS,2);

%TP Analysis
A(:,1) = Integrals(2,:).';
[B,I] = sortrows(A,'descend');
AverageR = mean(RedBS,2);
AverageG = mean(GreenBS,2);

%Calculate the Baseline integrals for each trace
for i=1:Ncol3
    
BaseInt(1,i) = max(cumtrapz(RedBS(1:50,i)));

end


%Calculate the threshold from the stdev of the baseline integrals
sdnoise = sqrt(mean(((BaseInt(BaseInt>0)).^2)));
Scale_Factor = 1;
Threshold(1,1:Ncol3) = fliplr(Scale_Factor * sdnoise * 1./sqrt((1:Ncol3)));
TN = RedBS;
TN_Int = zeros(1,Ncol3);

TN_A(:,1) = mean(RedBS,2); %First average is without any data removed (All CalBryte)
TN_Int(1,1) = max(cumtrapz(TN_A(100:150,1))); %Event integral from average of all data

for i=2:Ncol3

TN(:,I(i-1,1)) = NaN; %Event average with traces removed in order of the size of their integrals
TN_A(:,i) = nanmean(TN,2);
TN_Int(1,i) = max(cumtrapz(TN_A(100:150,i)));
%calculate the baseline integral for stage from the mean TNBase_Int(1,i) = max(cumtrapz(TN_A(100:150,i)));

end

clear TN

figure('name','Ordered_Integrals');
plot(B);
hold on
plot(ones(Ncol3,1)*2*sdnoise);
hold off

figure('name','TN_Integrals');
plot(TN_Int);
hold on
plot(Threshold);
hold off

%Calculate Average TP and TN
TP_Idx = I(TN_Int>Threshold);
TP = RedBS(:,TP_Idx);
TP_G = GreenBS(:,TP_Idx);
TP_G_A = mean(TP_G,2);
IntegralsTP_G = Integrals(1,TP_Idx);
IntegralsTP_R = Integrals(2,TP_Idx);
AverageTP = mean(TP,2);
IntegralTP =  max(cumtrapz(AverageTP(100:150,1)));


TN_Idx = I(TN_Int<=Threshold);
TN = RedBS(:,TN_Idx);
TN_G = GreenBS(:,TN_Idx);
TN_G_A = mean(TN_G,2);
IntegralsTN_G = Integrals(1,TN_Idx);
IntegralsTN_R = Integrals(2,TN_Idx);
AverageTN = mean(TN,2);
IntegralTN =  max(cumtrapz(AverageTN(100:150,1)));


TPR = (sum(TN_Int>Threshold)/size(RedBS,2))*100
TPR_level = (sum(B>2*sdnoise)/size(RedBS,2))*100


figure('name','Average_Traces');
hold on
plot(AverageG);
plot(AverageR);
plot(AverageTP);
plot(AverageTN);
hold off

Traces(:,1) = AverageG;
Traces(:,2) = AverageR;
Traces(:,3) = AverageTP;
Traces(:,4) = AverageTN;

TPIntegrals(:,1) = IntegralsTP_G.';
TPIntegrals(:,2) = IntegralsTP_R.';

TNIntegrals(:,1) = IntegralsTN_G.';
TNIntegrals(:,2) = IntegralsTN_R.';

TPRs(1,1)= TPR;
TPRs(1,2)= TPR_level;
TPRs(1,3)= Ncol3;

TPs(1,TP_Idx) = 1;
TPs(1,TN_Idx) = 0;

NoiseR_SD = NoiseR_SD.';

% % %Save data as excel files

 xlswrite(strcat(parentdir,filesep,'TPR.xlsx'),TPRs);
 xlswrite(strcat(parentdir,filesep,'Traces_Ave.xlsx'),Traces);
 %xlswrite(strcat(parentdir,filesep,'Traces_TP.xlsx'),TP);
 %xlswrite(strcat(parentdir,filesep,'TN_Int.xlsx'),TN_Int);
 xlswrite(strcat(parentdir,filesep,'Threshold.xlsx'),Threshold);
 
 xlswrite(strcat(parentdir,filesep,'TNIntegrals.xlsx'),TNIntegrals);
 
  if length(TP)>=1
 xlswrite(strcat(parentdir,filesep,'TPIntegrals.xlsx'),TPIntegrals);
  end

  xlswrite(strcat(parentdir,filesep,'Noise.xlsx'),NoiseR_SD);
  
  save(strcat(parentdir,filesep,'RedBS.mat'),'RedBS');
  %save(strcat(parentdir,filesep,'sdNoise.mat'),'sdnoise');
