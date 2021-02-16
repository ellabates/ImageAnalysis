% Run this script when you are in an eventer output folder 

%Set rootdirectory to the surrent directory
rootdirectory = dir(pwd); 

%data scaling type in your frequency
DS = 25;

%Set the event window to be collected
Pre = -1*DS;
Post = 3*DS;

%Create TotalResponse Structures
ResponsesGreen = struct;
ResponsesRed = struct;
AverageGreen = struct;
AverageRed = struct;
PeakAmpGreen = struct;
PeakAmpRed = struct;
  
%Fun through each folder in this directory
for j=3:length(rootdirectory)
%j=6
  
  %Open next folder in the directory
  myFolder = fullfile(rootdirectory(j).name);         
  % Open the Event Times
  fid = fopen(strcat(pwd,filesep,myFolder,filesep,myFolder,'Green',filesep,'eventer.output',filesep,'Data_ch1_YWave001',filesep,'txt',filesep,'times.txt'));
  C = textscan(fid,'%f');
  ET = cell2mat(C);
  EventTimes = ET.*DS; % Scale the event times 
  N = numel(ET); % Number of events simulated
  fclose(fid);
  
 % Open the responsegreen file
  fidG = fopen(strcat('../',myFolder,'responsegreen.itx'));
  C = textscan(fidG, '%s','delimiter','\n');
  %remove useless text
  CG = C{1,1}(4:end-2,1);
  %turn cells into matricies 
  ZG=zeros(size(CG,1),1);
  ZG=str2double(CG);
  fclose(fidG);
  
  % Open the responsered file
  fidR = fopen(strcat('../',myFolder,'responsered.itx'));
  C = textscan(fidR, '%s','delimiter','\n');
  %remove useless text
  CR = C{1,1}(4:end-2,1);  
  %turn cells into matricies 
  ZR=zeros(size(CR,1),1);
  ZR=str2double(CR);
  fclose(fidR);
  
  J=j-2;
  
  for i=1:N
      
      %Calculate the time window for each event (1s pre and 3s post event)
      T = EventTimes(i,1);
      Times(i,1) = int32(T)+Pre;
      Times(i,2) = int32(T)+Post;
      X = Times(i,1);
      Y = Times(i,2);
      
      %Extract these timings from the igor text files of the concatenated
      %ROIs with events
      GreenResponse(:,i) = ZG(X:Y,1);
      RedResponse(:,i) = ZR(X:Y,1);
      
      %Find the peak amplitudes of each event 
      PeakAmpG(i) = max(GreenResponse(:,i))
      PeakAmpR(i) = max(RedResponse(:,i))
      

  end
  
  

  %Peak Amplitude Analysis
  PeakAmpGreen(J).Trial = myFolder;
  PeakAmpRed(J).Trial = myFolder;
  PeakAmpGreen(J).PeakAmp = PeakAmpG
  PeakAmpRed(J).PeakAmp = PeakAmpR
  
  PeakAmpGreen(J).Average = mean(PeakAmpG,2);
  PeakAmpRed(J).Average = mean(PeakAmpR,2);
  AveragePAGreen1 = PeakAmpGreen.Average;
  AveragePARed1 = PeakAmpRed.Average;
  AveragePAGreen = mean(AveragePAGreen1);
  AveragePARed = mean(AveragePARed1);
  
  %Average Responses for each Cell seperately
  CellAverageGreen(J).Trial = myFolder;
  CellAverageGreen(J).Average = mean(GreenResponse,2);
  CellAverageRed(J).Trial = myFolder;
  CellAverageRed(J).Average = mean(RedResponse,2);
  
  %Average Responses for each Cell together
  %AverageGreen1(:,J) = CellAverageGreen(J).Average;
  %AverageRed1(:,J) = CellAverageRed(J).Average;
  %AverageGreen=mean(AverageGreen1,2);
  %AverageRed=mean(AverageRed1,2);
  
  %Create structure with all individual responses
      ResponsesGreen(J).Trial = myFolder;
      ResponsesGreen(J).Data = GreenResponse;
      ResponsesRed(J).Trial = myFolder;
      ResponsesRed(J).Data = RedResponse;
      
      fprintf(myFolder)
      clear GreenResponse RedResponse %PeakAmpG PeakAmpR
end

%Save all peak amplitudes of all cells and as excel files
%xlswrite(strcat('../','AllPeakAmpGreen.xlsx'),AllPeakAmpGreen);
%xlswrite(strcat('../','AllPeakAmpRed.xlsx'),AllPeakAmpRed);

%Save peak amplitudes of all cells and as excel files
%xlswrite(strcat('../','AveragePeakAmpGreen.xlsx'),AveragePAGreen);
%xlswrite(strcat('../','AveragePeakAmpRed.xlsx'),AveragePARed);
%Save peak amplitudes of all cells and as matlab files
%save(strcat('../','AveragePeakAmpGreen.mat'),'AveragePAGreen');
%save(strcat('../','AveragePeakAmpRed.mat'),'AveragePARed');

%Save total average responses of all cells as excel files
%xlswrite(strcat('../','AverageGreenResponse.xlsx'),AverageGreen);
%xlswrite(strcat('../','AverageRedResponse.xlsx'),AverageRed);
%Save total average responses as matlab files
%save(strcat('../','AverageGreenResponse.mat'),'AverageGreen');
%save(strcat('../','AverageRedResponse.mat'),'AverageRed');

%Save average responses of each cell as excel files
%writetable(struct2table(CellAverageGreen), strcat('../','AverageCellGreenResponse.xlsx'));
%writetable(struct2table(CellAverageRed), strcat('../','AverageCellRedResponse.xlsx'));
%Save average responses as matlab files
%save(strcat('../','AverageCellGreenResponse.mat'),'CellAverageGreen');
%save(strcat('../','AverageCellRedResponse.mat'),'CellAverageRed');

%Save total responses of each cell as excel files
writetable(struct2table(ResponsesGreen), strcat('../','ResponsesGreen.xlsx'));
writetable(struct2table(ResponsesRed), strcat('../','ResponsesRed.xlsx'));
%Save total responses as matlab files
save(strcat('../','ResponsesGreen.mat'),'ResponsesGreen');
save(strcat('../','ResponsesRed.mat'),'ResponsesRed');
      
%Clear all of the junk
clear X Y ZG ZR Times T N myFolder J i fidG fidR fid EventTimes ET CR CG C ans Pre Post rootdirectory j AverageGreen1 AverageRed1 AveragePAGreen1 AveragePARed1;


