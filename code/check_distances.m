
num_classes = 12;

selected_class = 2;

if false
    c = parcluster('local');
    c.NumWorkers = 8;
    parpool(c, c.NumWorkers);
end


for i=1:length(samples)
    if labels(i) == selected_class
        model = samples{i};
        model_idx = i;
        break;
    end
end

for i=fix(length(samples)/2):length(samples)
    if labels(i) == selected_class
        model2 = samples{i};
        model2_idx = i;
    end
end

if true
    class_indexes = cell(1, num_classes);
    class_indexes(:) = {[]};
    
    
    distances1 = cell(1, num_classes);
    distances1(:) = {[]};
    
    distances2 = cell(1, num_classes);
    distances2(:) = {[]};
    
    for i=1:length(samples)
        class_indexes{labels(i)} = [class_indexes{labels(i)} i];
    end
    
    if false
        for i=1:length(samples)
            if labels(i) == selected_class || selected_class == 0
                fprintf('%d\n', i);
                distances{labels(i)} = [distances{labels(i)} dtw(model, samples{i}, 0)];

                distances2{labels(i)} = [distances2{labels(i)} dtw(model2, samples{i}, 0)];
            end
        end
    end
    
    %cls = selected_class
    for cls=1:num_classes
        cls_count = length(class_indexes{cls});
        fprintf('class: %d  count: %d\n', cls, cls_count);
        
        distances1{cls} = zeros(cls_count, 1);
        distances2{cls} = zeros(cls_count, 1);
        dist1 = distances1{cls};
        dist2 = distances2{cls};
        cls_indexes = class_indexes{cls};

        parfor i=1:cls_count
            dist1(i) = dtw(model, samples{cls_indexes(i)}, 0);
            dist2(i) = dtw(model2, samples{cls_indexes(i)}, 0);
        end

        distances1{cls} = dist1;
        distances2{cls} = dist2;
    end
end

mean_distances = [];

%for i = 1:num_classes
%    mean_distances(i) = mean(distances{i});
%end

if false
    figure;
    for i = 1:num_classes
        scatter(repmat(i, [length(distances{i}) 1]), distances{i});
        hold on;
    end
    ylim([0 1000]);
end



figure;
%i = selected_class;
%size(distances1{i})
%size(distances2{i})

for i = 1:num_classes
    scatter(distances1{i}, distances2{i});
    hold on;
end

ylim([0 1000]);
xlim([0 1000]);

