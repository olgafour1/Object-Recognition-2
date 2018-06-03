
close all;

num_classes = 12;

selected_class = 2;

find_models = true;
train_model = true;

if false
    c = parcluster('local');
    c.NumWorkers = 8;
    parpool(c, c.NumWorkers);
end

if find_models
    [model, model2] = get_models(train_samples, train_labels, selected_class);
else
   model = train_samples{2028}; 
   model2 = train_samples{20}; 
end

%% train SVM
if train_model
    [X, Y] = obtain_distances_and_labels(train_samples, train_labels, model, selected_class);
    num_ones = length(Y(Y==1))
    num_zeros = length(Y(Y==0))
    fprintf('fitting svm \n');
    
    ind = Y==1;
    X_0 = X(Y==0);
    Y_0 = Y(Y==0);
    
    %X = [X(ind); X_0(1:min(length(X_0), sum(ind)))];
    %Y = [Y(ind); Y_0(1:min(length(X_0), sum(ind)))];
    
    %c=[0 1; 10 0];
    %SVMModel = fitcsvm(X, Y,'KernelFunction','linear','Cost',c);
    %[B,dev,stats] = mnrfit(X,categorical(Y), 'Model', 'ordinal');
    
    %B = [0.0001; 0];
end

fprintf('obtain test samples \n');
[X, Y] = obtain_distances_and_labels(test_samples, test_labels, model, selected_class);

fprintf('predict \n');
%y_pred = predict(SVMModel, X);
%y_pred = mnrval(B, Y)
%[~, y_pred] = max(y_pred,[],2);
%y_pred = 1 - y_pred;

threshold = obtain_optimal_threshold(X, Y)

y_pred = X < threshold;

eval = Evaluate(Y, y_pred)

precision = eval(4);
recall = eval(5);
f_measure = eval(6);

fprintf('precision: %0.2f\n', precision);
fprintf('recall: %0.2f\n', recall);
fprintf('f_measure: %0.2f\n', f_measure);


function threshold = obtain_optimal_threshold(X, Y)
    %get_f1 = @(e)e(6);
    opt_fun = @(e)(e(4)-e(5))^2 - e(6)*5;
    fun = @(thr)opt_fun(Evaluate(Y, X < thr));
    
    threshold = fminsearch(fun, 100);
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