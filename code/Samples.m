% data=load_dataset()
all_subsequences=[]
chosen_class=2
for i=1:12
     gt= getSamples(data,i);
     
    all_subsequences=vertcat(all_subsequences,gt);
    
end

     

 subsequence=getSamples(data,chosen_class);
 

 [accuracy,C]=classification_model(subsequence,all_subsequences)
 
 function [accuracyPercentage,C]=classification_model(subsequence,all_subsequences)

w=1;
distances=zeros(size(all_subsequences,1),1);
labels=zeros(size(all_subsequences,1),1);


tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

    for j=1:size(all_subsequences,1)
      %distances(j) = dtw(model_2(1).subSeq, all_labels(j).subSeq, w);
      distances(j)=multi_dwt(subsequence(1).subSeq, all_subsequences(j).subSeq,'cityblock');
      if strcmp(all_subsequences(j).label,tagset{2})==1
        labels(j)=1;
      else
          labels(j)=0;
      end
    end
  
set=horzcat(distances,labels);
p = .7  ;    % proportion of rows to select for training
N = size(set,1);  % total number of rows 
tf = false(N,1);    % create logical index vector
tf(1:round(p*N)) = true;     
tf = tf(randperm(N)) ;  % randomise order
dataTraining = set(tf,:); 
dataTesting = set(~tf,:); 
model = fitcknn(dataTraining(:,1),dataTraining(:,2),'NumNeighbors',1);
label = predict(model,dataTesting(:,1));
C = confusionmat(dataTesting(:,2),label);
accuracy = (sum(label == dataTesting(:,2))) / numel(dataTesting(:,2));
accuracyPercentage = 100*accuracy;



 end

function [gt] = getSamples(data,chosen_class);


m=1;
gt=struct;
for k=1:size(data)

frame={};
indices=(find(data(k).Y(:,chosen_class)==1)');
if indices>1
   
   for j=1:size(indices,2)-1
            
       frame{j,1}=data(k).tagset{chosen_class};
       frame{j,2}=indices(j);
       frame{j,3}=indices(j+1);
   end

 end
        
   
 if (size(frame,1)>1)
     for i=1:size(frame,1)

         gt(m,1).subSeq=data(k).X(frame{i,2}:frame{i,3},:);
         gt(m,1).label=frame{i};
         gt(m,1).beg_frame=frame{i,2};
         gt(m,1).end_frame=frame{i,3};
         m=m+1;
     end
 
end
 
end
end


function cost=multi_dwt(x,y,metric);
distances = pdist2(y,x,metric);

path = [[size(x,1),size(y,1)]];
accumulated_cost = zeros(size(y,1),size(x,1));
accumulated_cost(1,1)=distances(1,1);

for i=2:size(x,1)
    accumulated_cost(1,i) = distances(1,i) + accumulated_cost(1, i-1);
end
for i=2:size(y,1)
    accumulated_cost(i,1) = distances(i, 1) + accumulated_cost(i-1, 1);   
end

for i=2:size(y,1)
    for j=2:size(x,1)
        accumulated_cost(i, j) = min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]) + distances(i, j);
    end
end


i = size(y,1);
j = size(x,1);

while i>1 && j>1
    if i==1
        j=j-1;
    elseif j==1
        i=i-1;
    else
         if accumulated_cost(i-1, j) == min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]);
                  i = i - 1;
         elseif accumulated_cost(i, j-1) == min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]);
            j = j-1;
         else
            i = i - 1;
            j= j- 1;
         end
      
    end
  path=[path,[j,i]];
end
path=[path,[1,1]];


cost=0;
[m,n]=size(path);
for i=1:2:n-2
    
    cost=cost+(distances(path(i+1),path(i)));
    
end
end

function data = load_dataset();
myFolder = 'C:/Users/Olga/Desktop/MicrosoftGestureDataset/data/'
data=struct
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.csv');
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  disp(baseFileName);
  fullFileName = fullfile(myFolder, baseFileName);
  [filepath,name,ext] = fileparts(fullFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
 
  [X,Y,tagset]=load_file(name);

  data(k,1).X = X;
  data(k,1).Y=Y;
  data(k,1).tagset=tagset;
      
end
 
end 


     