indices = randperm(length(samples));

train_split = 40 % percent

train_size = fix(length(samples)*train_split/100)
test_size = length(samples) - train_size

train_samples = samples(indices(1:train_size));
train_labels = labels(indices(1:train_size));

test_samples = samples(indices(train_size:end));
test_labels = labels(indices(train_size:end));

save('dataset_train_test.mat', 'train_samples', 'train_labels', 'test_samples', 'test_labels')