function [K] = estimateIntrinsics(imageData)
%estimateIntrinsics: returns the intrinsic parameters matrix K that contains a
%combination of the intrinsic parameters of the camera.
%
%   [K] = estimateIntrinsics(imageData) returns a 3 by 3 matrix that contains the u0,
%   v0, au, av and skew angle parameters of the camera.
%
%   imageData: vector of structures that contains at least 3 different homographies
%              associated to images obtained by the same camera on the same
%              calibration object.
%
%   For each of the provided homographies we obtain two different equations on the
%   same unknown variables. By stacking these pairs of equations we obtain an
%   overdetermined linear system of equation that, once solved with singular value
%   decomposition, allows us to compute the intrinsic parameters matrix K by applying
%   Cholesky factorization. The resulting matrix K is then returned once normalized.

%     We set up an empty matrix for appending multiple equations
    V = [];

%     For each image, we get two rows to append to V. The coeficients of these
%     equations are provided by the getVEquation method.
    for ii = 1:length(imageData)
        V = [V;...
             getVEquation(imageData(ii).H, 1, 2)';...
             (getVEquation(imageData(ii).H, 1, 1) - getVEquation(imageData(ii).H, 2, 2))'];
    end

%     We get the vector b by performing singular value decomposition of V and taking
%     the right-most singular vector
    [LEFT, SIGMA, RIGHT] = svd(V);
    b = RIGHT(:, end);

%     We reconstruct the symmetric matrix B from the relation:
%     b = [B(1,1) B(1,2) B(2,2) B(1,3) B(2,3) B(3,3)]
    B = [b(1), b(2), b(4);...
         b(2), b(3), b(5);...
         b(4), b(5), b(6)];

%     By using the chol method to compute the Cholesky factorization of B we can
%     check if that matrix is positive or negative definite. We then proceed to
%     compute the factorization on the appropriate matrix, respectively B or -B
    try chol(B, 'lower');
        L = chol(B, 'lower');
    catch ME
        L = chol(-B, 'lower');
    end

%     Compute the intrinsic parameters matrix
    K = inv(L');
%     normalize the matrix
    K = K/K(3,3);
end

