
distances=zeros(size(y,2),size(x,2))
for i=1:size(y,2)
    for j=1:size(x,2)
        distances(i,j)=(x(j)-y(i))^2;
    end
end


path = [[size(x,2),size(y,2)]];
accumulated_cost = zeros(size(y,2),size(x,2));
accumulated_cost(1,1)=distances(1,1);

for i=2:size(x,2)
    accumulated_cost(1,i) = distances(1,i) + accumulated_cost(1, i-1);
end
for i=2:size(y,2)
    accumulated_cost(i,1) = distances(i, 1) + accumulated_cost(i-1, 1);   
end

for i=2:size(y,2)
    for j=2:size(x,2)
        accumulated_cost(i, j) = min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]) + distances(i, j);
    end
end


i = size(y,2);
j = size(x,2);

while i>1 && j>1
    if i==1
        j=j-1;
    elseif j==1
        i=i-1;
    else
         if accumulated_cost(i-1, j) == min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]);
                  i = i - 1
         elseif accumulated_cost(i, j-1) == min([accumulated_cost(i-1, j-1), accumulated_cost(i-1, j), accumulated_cost(i, j-1)]);
            j = j-1
         else
            i = i - 1;
            j= j- 1;
         end
      
    end
  path=[path,[j,i]];
end
path=[path,[1,1]];


cost=0;
[m,n]=size(path);
for i=1:2:n
    
    cost=cost+(distances(path(i+1),path(i)));
    
end


