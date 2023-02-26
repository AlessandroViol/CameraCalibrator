function [error, NoI] = testIntrinsicsNoI(calObjMeasures, imageDataK, imageDataRt)
%testIntrinsicsNoI: returns the reprojection error and the number of images for which
%the intrinsic parameters matrix K was estimated.
%
%   [error, NoI] = testIntrinsicsNoI(calObjMeasures, imageDataK, imageDataRt) returns
%   2 columns vectors, errors and NoI. The first is the reprojection errors obtained
%   from various reprojection matrices which were estimated from a intrinsic
%   parameters matrix K. The second is the number of images used to estimate the
%   various matrices K. In particoular, we estimate K using an increasing number of
%   images and we compute the reprojection error for a image that wasn't used to
%   estimate K
%
%   calObjMeasures: matrix of rows of millimiters coordinates of the calibration
%              object used to compute the reprojection error.
%   imageDataK: a vector of structs containing the homographies of each image to
%              estimate the intrinsic parameters matrix K.
%   imageDataRt: a struct containing the homography matrix and the pixel coordinates
%              of the squares of the checkerboard used to compute the reprojection
%              error.
%   
%   From an increasing number of images, starting from a minimum of three images, we
%   estimate various intrinsic parameters matrix K. Each of these matrices is then
%   used to estimate the rotation matrix and translation vector of a left out image.
%   For this image is then computed the reprojection error, which is returned along
%   with the corresponding number of images used in the estimation process.

%     Define an empty matrix for appending the reprojection errors for each number of
%     images considered in the estimation of K.
    error = [];
    
%     Starting from the minimum of three images, we estimate K and compute the
%     reprojection error on a left out image.
    for ii = 3:length(imageDataK)
%         Set up the counter for the current reprojection error.
        error = [error; 0];
        
%         Estimate K on the currently selected image set
        K = estimateIntrinsics(imageDataK(1:ii));

%         Compute the left out image rotation matrix, translation vector and
%         projection matrix.
        [imageDataRt.R, imageDataRt.t] = estimateRt(imageDataRt.H, K);
        imageDataRt.P = K * [imageDataRt.R, imageDataRt.t];
        
%         Compute the reprojection error on the left out image.
        error(end) = error(end) + computeReprError(imageDataRt.P, calObjMeasures,...
            imageDataRt.XYpixel); 
    end
    
%     Set the number of images of each iteration.
    NoI = 3:length(imageDataK);
end