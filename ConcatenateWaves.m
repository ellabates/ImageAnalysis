%Concatenates all Nor traces and normalises them ready to be analysed in
%eventer
%Run this in the data directory
clear 

%State directories
rootdirectory = dir(cd); 
rootid = cd;
[parentdir,~,~]=fileparts(pwd);

%Specify Tukeys multiplier
Tuk = 1.5;

%Run through every folder in the data directory
for j = 3:length(rootdirectory)

    %Open folder j
    myFolder = fullfile(rootdirectory(j).name);    
    
    %Find all files ending with responsegreenNor and responseredNor
    G_files = dir(strcat(myFolder,filesep,'*responsegreenNor.itx'));
    R_files = dir(strcat(myFolder,filesep,'*responseredNor.itx'));
    
    %Initialise all matircies
    E = length(G_files);
    L(1,1:E) = zeros;
    waves{2,E} = zeros;
    dataG{1,E} = zeros;
    dataR{1,E} = zeros;
    wavestemp(1,E) = zeros;

    for i=1:length(G_files)
        
        %Open all Nor files and add them to a cell
        myfile = fullfile(G_files(i).name);  
        fid = fopen(strcat(myFolder,filesep,myfile));
        C = textscan(fid, '%s','delimiter','\n');
        %remove useless text
        CGN = C{1,1}(4:end-2,1);
        xG = str2double(CGN);
        fclose(fid);
        clear fid CGN C 
    
        name = myfile(1:end-20);
        L(1,i) = length(xG);
        waves{1,i} = name;
        %waves{2,i} =  L(1,i)/500;
        wavestemp(1,i) = (L(1,i)/500)*20;
        waves{2,i} = sum(wavestemp);
        
    
        dataG{1,i} = xG;
    
        myfile = fullfile(R_files(i).name);  
        fid = fopen(strcat(myFolder,filesep,myfile));
        C = textscan(fid, '%s','delimiter','\n');
        %remove useless text
        CRN = C{1,1}(4:end-2,1);
        xR = str2double(CRN);
        fclose(fid);
        clear fid CGN C 
    
        dataR{1,i} = xR;
  
    end
    
    
    if exist(strcat(myFolder,filesep,'waves.xlsx'), 'file')==2
        
        delete(strcat(myFolder,filesep,'waves.xlsx'));
        
    end
    
    save(strcat(myFolder,filesep,'waves.mat'),'waves');

    A(1:sum(L),1) = zeros;
    A(:,1) = vertcat(dataG{:});

    B(1:sum(L),1) = zeros;
    B(:,1) = vertcat(dataR{:});


    clear L

    L = length(A);
    k = 1;


    for i = 1:500:L
        
        m = i+499;
        tmpG(:,k) = A(i:m,1);
        tmpR(:,k) = B(i:m,1);
        k=k+1;
    
    end
    
    [Nrow,Ncol] = size(tmpG);


   %Normalise Data
   for i = 1:500:L
       
       m = i+499;
       %Green norm
       tempG = A(i:m,1);
       x_NorG(i:m,2) = tempG./sqrt(mean(((tempG(tempG<0)).^2)));
       %Red norm
       tempR = B(i:m,1);
       x_NorR(i:m,2) = tempR./sqrt(mean(((tempR(tempR<0)).^2)));
   end
      
      %Make x axis
      for i=1:L
          
          x_NorG(i,1) = (i-1)*0.04;
          x_NorR(i,1) = (i-1)*0.04;
    
      end
      
      
      ephysIO (strcat(myFolder,filesep,'Nor_G.phy'),x_NorG,'s','A');
      ephysIO (strcat(myFolder,filesep,'Nor_R.phy'),x_NorR,'s','A');
      
      clear xR xG tmpG tmpR x_NorG x_NorR tempG tempR L A B dataG dataR waves wavestemp
  
end 

%clear

          
   
