function [error, NoP] = testHomographyNoP(calObjMeasures, imageData)
%testHomographyNoP: returns the reprojection error and the number of points for which
%the homography was estimated.
%
%   [error, NoP] = getCheckerboardWorldPoints(dim, squareSize) returns 2 columns
%   vectors, errors and NoP. The first is the reprojection errors obtained from
%   various reprojection matrices which were estimated from a homography. The second
%   is the number of points used to estimate the various homographies.
%
%   calObjMeasures: matrix of rows of millimiters coordinates of the calibration
%              object.
%   imageData: a vector of struct containing the pixel coordinates of the squares of
%              the checkerboard.
%   
%   By using an increasing step size in a vector declaration, we've been able to
%   uniformely select a subset of points for which we can estimate the homographies.
%   For each estimated homography we then estimate the instrinsic and estrinsic
%   parameters to compute the reprojection error. The reprojection error is returned
%   along with the number of points used to estimate the corresponding homography.

%     We set up 2 empty vectors to progressively append the error and the number of
%     points of each iteration
    error = [];
    NoP = [];
    
%     We increase the step size from 1 to 10
    for ii = [1:10]
%         We select the indexes of the points for this current iteration
        indexes = 1:ii:length(calObjMeasures);

%         If the number of points is too low, the estimation is too poor and
%         inconsistent. There is a chance that the estimated B matrix in the
%         estimateIntrinsics might be either positive nor negative definite. This
%         prevents us to compute the intrinsic parameters matrix via Cholesky
%         factorization. To prevent this occurrance, we'll stop testing if we get
%         less then 15 points for the homographies estimation
        if(length(indexes) < 15)
            break;
        end
        
%         Append the current number of points
        NoP = [NoP; length(indexes)];
        
%         Estimate the homographies for all the images
        for jj = 1:length(imageData)
            imageData(jj).H = estimateHomography(calObjMeasures(indexes, :),...
                imageData(jj).XYpixel(indexes, :));
        end

%         Estimate the intrinsic parameters matrix using all the images.
        K = estimateIntrinsics(imageData);
        
%         Determine the estrinsic parameters and compute the corresponding total
%         reprojection error. The latter is then appended to the output error vector.
        error = [error; 0];
        for jj = 1:length(imageData)
            [imageData(jj).R, imageData(jj).t] = estimateRt(imageData(jj).H, K);
            imageData(jj).P = K * [imageData(jj).R, imageData(jj).t];
            
            error(end) = error(end) + computeReprError(imageData(jj).P,...
                calObjMeasures, imageData(jj).XYpixel);
        end
    end
end