function [error] = computeReprError(P, XYmm, XYpixel)
%computeReprError: returns the reprojection error obtained from a perspective
%projection matrix and some points on the image and the calibration object.
%
%   [error] = computeReprError(P, XYmm, XYpixel) returns a Double value that
%   represents the reprojection error of an estimated matrix P of an image. Some
%   corresponding points XYmm of the calibration object in millimiters and XYpixel
%   points of the images need to be provided.
%
%   P: a 3 by 4 matrix representing a perspective projection matrix that describes
%      the geometric construction of the image from the camera.
%   XYmm: a matrix containing on each row a pair of coordinates of the points of the
%      calibration object in millimiters in the space.
%   XYpixel: a matrix containing on each row a pair of the pixel coordinates of the
%      points of the image corresponding to the calibration object points.
%
%   Each of the provided points XYmm of the calibration object is projected onto the
%   image using the perspective projection matrix P. We then compute the square of
%   the distance between the projected points and the detected points XYpixel. The
%   sum of all this distances for all the points is the value of the reprojection
%   error that is then returned.

%     We initialize the error to zero to compute a sum.
    error = 0;
    
%     for each pair of points we compute the error.
    for ii = 1:length(XYpixel)
%         We define the 3D real world homogeneous coordinates vector of the point.
        m = [XYmm(ii, 1);...
             XYmm(ii, 2);...
             0;...
             1];
         
%         Compute the error on the pair of points and sum it to the previous errors.
        error = error + ((P(1, :)*m)/(P(3, :)*m) - XYpixel(ii, 1))^2 +...
            ((P(2, :)*m)/(P(3, :)*m) - XYpixel(ii, 2))^2;
    end
end