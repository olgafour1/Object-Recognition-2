function [gest, ngest] = gestureCuts(dataX, dataY)
% "ngest" is the number of gesture and 
% "gest" is a list of gestures, of size (ngest,3), consisting of a gesture label,
% and a beginning and end frame

label = 0;  % number refering to G<label> in tagset
gest = [];
for i = 1:12
    if(size(dataY(:,i))>0) % check if nonempty
        [pks,locs] = findpeaks(dataY(:,i));
        if(size(locs)>0)
            label = i;
            
            for k = 2:1:size(locs)
                gest(k-1,:) = [label, locs(k-1), locs(k)];
            end
        end
    end
end
ngest = size(gest, 1);
end