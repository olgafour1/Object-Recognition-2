function data = load_dataset();
myFolder = 'C:/Users/Olga/Desktop/MicrosoftGestureDataset/data/'
data=struct
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.csv');
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  disp(baseFileName);
  fullFileName = fullfile(myFolder, baseFileName);
  [filepath,name,ext] = fileparts(fullFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  [X,Y,tagset]=load_file(name);
  %X_values = X(:,1:4:end)
  %X_values=[ reshape(X_values(:,1:end),[],1) ]
  %Y_values=X(:,2:4:end)
  %Y_values=[ reshape(Y_values(:,1:end),[],1) ]
 
  data(k,1).X = X;
  data(k,1).Y=Y;
  data(k,1).tagset=tagset;
      
end
 
end 

  