
samples = {};
labels = [];


mask1 = []; %for deleting V values
for n =1:80
    if (mod(n,4) ~= 0)
        mask1 = [mask1 n]; 
    end
end

sample_idx = 1

for i=1:length(data)
   if isempty(data(i).X)
       continue
   end
   
   fprintf('%d\n', i);
   
   [gestures, ngest] = gestureCuts(data(i).X, data(i).Y);
   %fprintf('%d\n', gest(1, 2));
   
   for k=1:ngest
       gest = gestures(k, :)
       
       sample = data(i).X(gest(2):gest(3), mask1);
       
       samples{sample_idx} = sample;
       labels(sample_idx) = gest(1);
       
       sample_idx = sample_idx + 1;
   end
   
end

save('dataset.mat', 'samples', 'labels')