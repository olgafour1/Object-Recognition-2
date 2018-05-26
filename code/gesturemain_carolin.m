
%[data, tagset] = loadAll();

chosen_classModel = 5;
chosen_class = 0; % class = 0 -> all labels
[mod] = getSamples(data, chosen_classModel); % to get model gesture from different class
[gt] = getSamples(data, chosen_class);
model = mod(10); % model sample (gt->same class; mod->other class)


%t = gt(20,1:80);
%w = 1;
%d=dtw(s,t,w);   % s: signal 1, size is ns*k, row for time, colume for channel 
                % t: signal 2, size is nt*k, row for time, colume for channel 
                % w: window parameter
                %      if s(i) is matched with t(j) then |i-j|<=w
                % d: resulting distance
%disp(d);
threshold = 200;
[acc, avdist] = classification(model, gt, threshold);

disp("accuracy: ");
disp(acc);
disp("gesture model label: " + model.indices(1));
disp("average distance for label " + chosen_class);
disp(avdist);


% for m = 1:12 %class model
%     [mod] = getSamples(data, m);
%     for t = 1:12 % class test  
%         [gt] = getSamples(data, t);
%         distSum = 0;
%         noTest = 0;
%         for n = 1:size(mod,2) %pick model subseq
%             model = mod(n);
%             [acc, avdist] = classification(model, gt, threshold);
%             distSum = distSum + avdist;
%             noTest = noTest +1;
%         end
%         distance = vpa(distSum/noTest);
%         disp("model: " + m),
%         disp("  class: " + t);
%         disp("distance: ");
%         disp(distance);
%     end       
% end

function [accuracy, avdist] = classification(model, gtdata, threshold)
w = 1; %window parameter s.o.
score = 0.0;
dist = 0;
label = model.indices(1);
for i=1:size(gtdata,2)
    d = dtw(model.subSeq, gtdata(i).subSeq, w);
    dist = dist+d; %to calculate average distance between diffrent gesture classes
    if(d == 0)  % discard model sample
        continue;
    end
    if((d<=threshold)&&(label == gtdata(i).indices(1)))
        score = score+1;
    elseif ((d>threshold)&&(label ~= gtdata(i).indices(1)))
        score = score+1;
    end
end

avdist = vpa(dist/(size(gtdata,2)-1));
accuracy = vpa(score/(size(gtdata,2)-1));
end

function [data, tagset] = loadAll()
%cd('D:/Carol/Documents/MATLAB/OR/gesture');
files = dir(strcat('../data/*.csv'));
discard_zero_frames = 1;
tagset=[];

for i= 1:size(files)
    file_basename = files(i).name(1:end-4);
    try
        disp(file_basename);
        [X,Y,itagset]=load_file(file_basename, discard_zero_frames);
        data(i).X = X;
        data(i).Y = Y;
        tagset = [tagset, itagset];
    catch
        fprintf('error loading %s', file_basename);
    end
end    

%data: structure containing 594 sequences described by the vectors X and Y
%plot(data(13).X(:,1)), illustrate the variation of the X axis (all the frames) of the sequence 13
end

function [gt] = getSamples(data, chosen_class)
% separate the beginning and end of each gesture 
gt = struct('subSeq',{},'indices',{});
mask1 = []; %for deleting V values
for n =1:80
    if (mod(n,4) ~= 0)
        mask1 = [mask1 n]; 
    end
end

for i = 1:size(data,2) % i = sequences
    if size(data(i).X, 1) == 0
        continue
    end
    
    [gest, ngest] = gestureCuts(data(i).X, data(i).Y);
    % b:
    subSeq = []; % size(ngest, 80)
    indices = []; % size(ngest, 3)
    if (size(gest, 1) > 0)
        for g = 1:ngest % g = ngestures
            beginframe = gest(g,2);
            endframe = gest(g,3);
            if (chosen_class == 0)
                if ((gest(g,2) > 0) && (gest(g,3) > -1))
                                                                    
%                     subSeq = [subSeq; data(i).X(beginframe:endframe,:)]; %-------------------------------------g frames
%                     indices = [indices; gest(g,1:3)];
                    subSeq = data(i).X(beginframe:endframe,:);
                    indices = gest(g,1:3);
                    gt(end+1).subSeq = subSeq(:, mask1);
                    gt(end).indices = indices;
                end
            elseif (gest(g,1) == chosen_class) % gest(g,1) = gesture label            
                if ((gest(g,2) > 0) && (gest(g,3) > 0))
                    
                    %subSeq = cat(3, subSeq, data(i).X(beginframe:endframe,:));
%                     subSeq = [subSeq; data(i).X(beginframe:endframe,:)];
%                     indices = [indices; gest(g,1:3)]; % with gesture label (gest(g,1))
                    subSeq = data(i).X(beginframe:endframe,:);
                    indices = gest(g,1:3);
                    gt(end+1).subSeq = subSeq(:, mask1);
                    gt(end).indices = indices;
                end
            end 
%             gt(end+1).subSeq = subSeq;
%             gt(end+1).subSeq = indices;
        end
%         disp(size(subSeq));
%         disp(size(indices));
%         newSeq = [subSeq; indices];
%         gt(end+1) = (newSeq);
    end
end
% b. The function then select and concatenate only the gestures of a chosen label (for
% instance the gesture 12), use the beginning and end frame to select only the
% subsequence of the signal contained between beg-end.

% c. the resulting variable "gt" is a structure composed of the following vectors:
% subSeq = sequence cuts size(n_ gestures,80) where 80 is 20xXYZV
% indices = beg-end frames of each sequence size(n_ gestures)
end