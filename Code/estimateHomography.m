function [H] = estimateHomography(calObjMeasures, XYpixel)
%estimateHomography: returns the homography of a provided image using the
%correspondances between points on a plane in the image and in the space.
%
%   [H] = estimateHomography(calObjMeasures, XYpixel) returns a 3 by 3 matrix that
%   represents the homography that maps the points of the planar calibration object
%   onto the image plane. 
%
%   calObjMeasures: vector of pairs of coordinates (x,y) in millimeters of the planar
%            calibration object.
%   XYpixel: vector of pairs of pixel coordinates (x,y) of the calObjMeasures
%            corresponding points in the image.
%
%   We use each pair of points of calObjMeasures and XYpixel to estimate the
%   homography that maps the points of the first to the points of the second. The
%   homography is represented by its 3 by 3 matrix H, which is returned.

%     Prepare an empty vector to build the matrix that represents the overdetermined
%     system of equations we want to solve to estimate H.
    A = [];

%     For each of the correspondancies between two pairs of points we obtain two
%     equations, represented by two rows of A, that we will append to that matrix.
    for jj = 1:length(XYpixel)
%         Define some shorthands for our matrices definitions.
        Xpixel = XYpixel(jj, 1);
        Ypixel = XYpixel(jj, 2);
        Xmm = calObjMeasures(jj, 1);
        Ymm = calObjMeasures(jj, 2);

%         A*x = 0.
%         [m'    0'  -u*m'] [h1]
%         [0'    m'  -v*m']*[h2] = 0
%                           [h3]
%         Where the unknown variables h1, h2, h3 are the Homogeneous matrix H column
%         vectors.

%         Column vector of the homogeneous coordinates in the plane reference system.
        m = [Xmm;...
             Ymm;...
             1]; 

%         Shorthand for writing A.
        O = [0;...
             0;...
             0];
%         Append 2 more rows to A.
        A = [A;... 
             m' O' -Xpixel*m';...
             O' m' -Ypixel*m']; 
    end

%     We solve the overdetermined Ax=0 linear system by applying singular value
%     decomposition to the matrix A.
    [LEFT, SIGMA, RIGHT] = svd(A); 
%     The result will be the right-most singular vector.
    h = RIGHT(:, end);

%     We reshape the found vector into the 3 by 3 matrix H that represents an
%     estimate of the homography.
    H = reshape(h, [3 3])';
    
%     We make the assumption that the camera is capturing the image from above the
%     pattern.
    if(H(3, 3) > 0)
        H = -H;
    end
end