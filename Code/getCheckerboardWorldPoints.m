function [Pmm] = getCheckerboardWorldPoints(dim, squareSize)
%getCheckerboardWorldPoints: returns the real world coordinates of the checkerboard's
%squares corners.
%
%   [Pmm] = getCheckerboardWorldPoints(dim, squareSize) returns a 2 by dim(1)*dim(2)
%   matrix. Each column represents a point coordinates in millimiters with respect to
%   the upper left corner of the checkerboard.
%
%   dim(1): number of rows of the checkerboard.
%   dim(2): number of columns of the checkerboard.
%   squareSize: size of a square of the checkerboard measured in millimiters.
%
%   For each of the dim(1)*dim(2) corners we compute their coordinates in
%   millimiters and we progressively store them in the 2 by dim(1)*dim(2) matrix
%   Pmm.
    n = dim(1);
    m = dim(2);
    
    Pmm = [];
    for ii = 1:n*m
%         Given an index jj of a vector of n*m elements, we obtain the [row, col]
%         indexes of the corresponding element in a n*m matrix.
        [row, col] = ind2sub([n, m], ii); 
        
%         We need to store the real world position of the corners with respect to the
%         origin. Because the first corner of the image will be on the origin (0,0),
%         we subtract the row and col indexes by 1.
        Pmm = [Pmm;...
               [col - 1, row - 1] * squareSize];
    end
end

