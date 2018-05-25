function [gt] = getSamples(data,chosen_class);


m=1;
gt=struct;
for k=1:size(data)

frame={};
indices=(find(data(k).Y(:,chosen_class)==1)');
if indices>1
   disp(k)
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
     