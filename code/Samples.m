all_labels=[]
for i=1:12
     gt= getSamples(data,i);
     all_labels=vertcat(all_labels,gt);
      
end
 
model_2=getSamples(data,2)

w=1
distances=zeros(size(all_labels,1),1)
labels=zeros(size(all_labels,1),1)

tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

    for j=1:size(all_labels,1)
      d = dtw(model_2(1).subSeq, all_labels(j).subSeq, w);
      
      
     
     
      if strcmp(all_labels(j).label,tagset{2})==1
        labels(j)=1;
      else
          labels(j)=0;
      end
    end
  
set=horzcat(distances,labels);
p = .7      % proportion of rows to select for training
N = size(set,1);  % total number of rows 
tf = false(N,1);    % create logical index vector
tf(1:round(p*N)) = true;     
tf = tf(randperm(N)) ;  % randomise order
dataTraining = set(tf,:); 
dataTesting = set(~tf,:); 
%B = mnrfit(dataTraining(:,1),dataTraining(:,2))
classification_model = fitcsvm(dataTraining(:,1),dataTraining(:,2));
[label,score] = predict(classification_model,dataTesting(:,1))
conf=confusionmat(label,dataTesting(:,2))
tot=sum(sum(conf));
correct=sum(max(conf,[],2));
accuracy(i,1)=correct/tot;

%predicted_values=glmval(b,dataTesting(:,1),'logit')';
%C = confusionmat(dataTesting(:,1),predicted_values)


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


     