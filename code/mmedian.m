function [med idx] = mmedian(x, percent)
    %# MYMEDIAN
    %#
    %# Input:   x        vector
    %# Output:  med      median value
    %# Output:  idx      corresponding index
    %#
    %# Note: If vector has even length, idx contains two indices
    %# (their average is the median value)
    %#
    %# Example:
    %#    x = rand(100,1);
    %#    [med idx] = mymedian(x)
    %#    median(x)
    %#
    %# Example:
    %#    x = rand(99,1);
    %#    [med idx] = mymedian(x)
    %#    median(x)
    %#
    %# See also: median
    %#

    assert(isvector(x));
    [~,ord] = sort(x);
    num = numel(x);

    idx = ord(floor(num*percent)+1);
    med = x(idx);
end