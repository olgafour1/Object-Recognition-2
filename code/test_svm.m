
close all;

num_classes = 12;

selected_class = 4;

find_models = true;
train_model = true;

if false
    c = parcluster('local');
    c.NumWorkers = 8;
    parpool(c, c.NumWorkers);
end

precision = zeros(num_classes, 1);
recall = zeros(num_classes, 1);
f_measure = zeros(num_classes, 1);

for selected_class = 1:num_classes
    fprintf('\n################\n');
    fprintf('class: %d\n', selected_class);
    fprintf('################\n');
    if find_models
        models = get_models(train_samples, train_labels, selected_class, 5);
        model = models{1};
    end

    %% train SVM
    if train_model
        [X, Y] = obtain_multi_distances_and_labels(train_samples, train_labels, models, selected_class);
        num_ones = length(Y(Y==1));
        num_zeros = length(Y(Y==0));

        thresholds = [];
        fvals = [];
        for i = 1:length(models)
            [thresholds(i), fvals(i)] = obtain_optimal_threshold(X(:,i), Y);
        end
        [~, best_model_idx] = min(fvals);
        fprintf('best model: %d  threshold: %f\n', best_model_idx, thresholds(best_model_idx));
        best_model = models{best_model_idx};
    end

    fprintf('obtain test samples \n');
    [X, Y] = obtain_distances_and_labels(test_samples, test_labels, best_model, selected_class);

    fprintf('predict \n');

    y_pred = X < threshold;

    eval = Evaluate(Y, y_pred);

    precision(selected_class) = eval(4);
    recall(selected_class) = eval(5);
    f_measure(selected_class) = eval(6);

    fprintf('precision: %0.2f\n', precision(selected_class));
    fprintf('recall: %0.2f\n', recall(selected_class));
    fprintf('f_measure: %0.2f\n', f_measure(selected_class));

end

fprintf('\n');
for i = 1:length(f_measure)
    fprintf('class %d: F1: %0.2f \n', i, f_measure(i));
end

fprintf('\naverage F1: %0.2f\n', mean(f_measure));

function [threshold, fval] = obtain_optimal_threshold(X, Y)
    opt_fun = @(e)((e(4)-e(5))^2 - e(6)*5);
    fun = @(thr)opt_fun(Evaluate(Y, X < thr));
    
    [threshold, fval] = fminsearch(fun, 200);
end

function [X, Y] = obtain_distances_and_labels(samples, labels, model, selected_class)
    X = zeros(length(samples), 1);
    Y = zeros(length(samples), 1);
    
    parfor i = 1:length(samples)
        X(i) = dtw(model, samples{i}, 1);
        if labels(i) == selected_class
            Y(i) = 1;
        end
    end
end

function [X, Y] = obtain_multi_distances_and_labels(samples, labels, models, selected_class)
    num_models = length(models);
    X = zeros(length(samples), num_models);
    Y = zeros(length(samples), 1);
    
    parfor i = 1:length(samples)
        sample = samples{i};
        Xrow = zeros(1, num_models);
        for j = 1:num_models
            Xrow(j) = dtw(models{j}, sample, 1);
        end
        X(i, :) = Xrow;
        if labels(i) == selected_class
            Y(i) = 1;
        end
    end
end

function [X, Y] = obtain_multi_distances_and_labels_old(samples, labels, model, selected_class)
    num_joints = 20;
    X = zeros(length(samples), num_joints);
    Y = zeros(length(samples), 1);
    
    parfor i = 1:length(samples)
        sample = samples{i};
        Xrow = zeros(1, num_joints);
        for j = 0:num_joints-1
            range = j*3+1:j*3+3;
            Xrow(j+1) = dtw(model(:,range), sample(:,range), 1);
        end
        X(i, :) = Xrow;
        if labels(i) == selected_class
            Y(i) = 1;
        end
    end
end

function [models] = get_models(samples, labels, selected_class, count)
    models = samples(labels == selected_class);
    models = models(randperm(length(models)));
    models = models(1:count);
end