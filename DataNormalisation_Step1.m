%Takes each response window and then integrates them.
% Run this script when you sre in the folder with the experiment date
% folders in them 

%Set rootdirectory to the surrent directory
clear all
rootdirectory = dir(pwd); 
Tuk = 1.5;
    
  %Open next folder in the directory
  
  for l=3:length(rootdirectory)
  %Open next folder in the directory
  myFolder = fullfile(rootdirectory(l).name);  
  
%   CG = ephysIO(strcat(myFolder,filesep,'AllGreen.phy'));
%   xG = CG.array(:,2);
%   clear CG
%   
%   CR = ephysIO(strcat(myFolder,filesep,'AllRed.phy'));
%   xR = CR.array(:,2);
%   clear CR
  % Open the non normalised responsegreenNor file

  fid = fopen(strcat(myFolder,filesep,'AllresponsegreenNor.itx'));
  C = textscan(fid, '%s','delimiter','\n');
  %remove useless text
  CGN = C{1,1}(4:end-2,1);
  xG = str2double(CGN);
  fclose(fid);
  clear fid CGN C 
  
  % Open the non normalised responseredNor file
  
  fid = fopen(strcat(myFolder,filesep,'AllresponseredNor.itx'));
  C = textscan(fid, '%s','delimiter','\n');
  %remove useless text
  CRN = C{1,1}(4:end-2,1);  
  %turn cells into matricies 
  %ZRN = zeros(size(CRN,1),1);
  xR = str2double(CRN);
  fclose(fid);
  clear fid CRN C 

  % Assign each 20s recording to a column
  L = length(xG);
  k = 1;
  t(:,1) = 0:0.04:19.96;
  
  for i = 1:500:L
      
      j = i+499;
      tmpG(:,k) = xG(i:j,1);
      tmpR(:,k) = xR(i:j,1);
      k=k+1
  
  end

[Nrow,Ncol] = size(tmpG);  


   %Normalise Data
      for i = 1:500:L
          
          j = i+499;
          
          tempG = xG(i:j,1);

          x_NorG(i:j,2) = tempG./sqrt(mean(((tempG(tempG<0)).^2)));
          
          tempR = xR(i:j,1);

          x_NorR(i:j,2) = tempR./sqrt(mean(((tempR(tempR<0)).^2)));

          
      end
      
      %Make x axis
      for i=1:L
          
          x_NorG(i,1) = (i-1)*0.04;
          x_NorR(i,1) = (i-1)*0.04;
    
      end
      
      
      ephysIO (strcat(myFolder,filesep,'Nor_G.phy'),x_NorG,'s','A');
      ephysIO (strcat(myFolder,filesep,'Nor_R.phy'),x_NorR,'s','A');
      
      clear xR xG tmpG tmpR x_NorG x_NorR tempG tempR
      
  end
      clear all

          
   