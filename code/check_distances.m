
num_classes = 12;

selected_class = 10;

for i=1:length(samples)
    if labels(i) == selected_class
        model = samples{i};
        model_idx = i;
    end
end

if true
    distances = cell(1, num_classes);
    distances(:) = {[]};

    for i=2:length(samples)
        if labels(i) == selected_class || selected_class == 0
            fprintf('%d\n', i);
            distances{labels(i)} = [distances{labels(i)} dtw(model, samples{i}, 0)];
        end
    end

end

mean_distances = [];

for i = 1:num_classes
    mean_distances(i) = mean(distances{i});
end

figure;
for i = 1:num_classes
    scatter(repmat(i, [length(distances{i}) 1]), distances{i})
    hold on;
end