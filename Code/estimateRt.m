function [ROrth, t] = estimateRt(H, K)
%estimateRt: returns the 3 by 3 rotation matrix R and the translation vector t that
%describe the rotation and the position of the checkerboards with respect to the
%camera
%
%   [ROrth, t] = estimateRt(H, K) returns a 3 by 3 rotation matrix R and a
%   translation vector t obtained from a matrix H that describes the homography of an
%   image and an upper triangular 3 by 3 matrix K that contains the intrinsic
%   parameters of the camera.
%   
%   H: 3 by 3 matrix that describes the homography map of a given image.
%   K: upper triangular 3 by 3 matrix that contains the intrinsic parameters of a
%      camera.
%
%   From the provided matrices of the homography H and of the intrinsic parameters K
%   we compute the translation vector t and we find an orthogonal matrix that
%   estimate the rotation matrix of the image.

%     Compute the lambda coeficient.
    lambda = 1/norm(inv(K)*H(:, 1));

%     Compute the rotation matrix columns.
    r1 = lambda*inv(K)*H(:, 1);
    r2 = lambda*inv(K)*H(:, 2);
    r3 = cross(r1, r2);

    R = [r1, r2, r3];
    
%     R might very well not be a rotation matrix, so we find the closest rotation
%     matrix aproximation according to the Frobenius norm by applying singular value
%     decomposition.
    [LEFT, SIGMA, RIGHT] = svd(R);
    ROrth =  LEFT*(RIGHT');

%     We normalize the rotation matrix if needed.
    if(norm(ROrth(3, :)) ~= 1)
       ROrth = ROrth/norm(ROrth(3, :));
    end

%     Lastly, we compute the translation vector.
    t = lambda*inv(K)*H(:, 3);
end