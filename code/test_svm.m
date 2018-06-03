
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
        [model, model2] = get_models(train_samples, train_labels, selected_class);
    else
       %model = train_samples{2028}; 
       %model2 = train_samples{20}; 
    end

    %% train SVM
    if train_model
        [X, Y] = obtain_distances_and_labels(train_samples, train_labels, model, selected_class);
        num_ones = length(Y(Y==1));
        num_zeros = length(Y(Y==0));

        threshold = obtain_optimal_threshold(X, Y);
        fprintf('threshold: %f\n', threshold);
    end

    fprintf('obtain test samples \n');
    [X, Y] = obtain_distances_and_labels(test_samples, test_labels, model, selected_class);

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

for i = 1:length(f_measure)
    fprintf('class %d: F1: %0.2f \n', i, f_measure(i));
end

function threshold = obtain_optimal_threshold(X, Y)
    %get_f1 = @(e)e(6);
    opt_fun = @(e)(e(4)-e(5))^2 - e(6)*5;
    fun = @(thr)opt_fun(Evaluate(Y, X < thr));
    
    threshold = fminsearch(fun, 200);
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

function [model, model2] = get_models(samples, labels, selected_class)
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
end