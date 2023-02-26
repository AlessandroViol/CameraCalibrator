function [VEquation] = getVEquation(H, i, j)
%getVEquation: returns a vector of coeficients to build the linear system of
%equations that allow us to find an estimate of the intrinsic parameters.
%
%   [VEquation] = getVEquation(H, i, j) returns a column vector of 6 elements obtained
%   from the provided homography and some indexes. The returned vector is used to
%   build the equations to estimate the intrinsic parameters matrix K.
%
%   H: 3 by 3 matrix that represents an homography between a planar calibration
%      object and the image plane.
%   i: index for the selection of a column of H. The value must be within 1 and 3.
%   j: index for the selection of a column of H. The value must be within 1 and 3.
%
%   From the provided homography and indexes we build a 6 elements column vector that
%   represents part of the equations of the linear system that we solve to estimate
%   the intrinsic parameters matrix K.

%     Compute the value of the vij vector.
    vij = [H(1,i)*H(1,j);...
           H(1,i)*H(2,j) + H(2,i)*H(1,j);...
           H(2,i)*H(2,j);...
           H(3,i)*H(1,j) + H(1,i)*H(3,j);...
           H(3,i)*H(2,j) + H(2,i)*H(3,j);...
           H(3,i)*H(3,j)];

%     Return the column vector.
    VEquation = vij;
end