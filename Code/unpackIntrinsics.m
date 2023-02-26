function [u0, v0, au, av, skew] = unpackIntrinsics(K)
%unpackIntrinsics: returns the intrinsic parameters u0, v0, au, av, skew of the
%camera that are contained in the provided intrinsic parameters matrix K.
%
%   [u0, v0, au, av, skew] = unpackIntrinsics(K) returns a 5 element row vector of
%   intrinsic parameters of the camera, extracted from the provided intrinsic
%   parameters matrix K.
%
%   K: 3 by 3 upper diagonal matrix that represents the intrinsic parameters matrix
%      of a camera.
%
%   From the provided intrinsic parameters matrix K we extract the values of five of
%   the six camera's intrinsic parameters:
%       u0: first pixel coordinate of the center of projection projected on the
%           sensor.
%       v0: second pixel coordinate of the center of projection projected on the
%           sensor.
%       au: focal length of the lenses times the reciprocal of the width of the
%           sensor's pixel. Unfortunately, the focal length of the lenses can't be
%           recovered if at least one of the dimensions of the pixel aren't provided
%           by the manifacturer.
%       av: focal length of the lenses times the reciprocal of the height of the
%           sensor's pixel. Unfortunately, the focal length of the lenses can't be
%           recovered if at least one of the dimensions of the pixel aren't provided
%           by the manifacturer.
%       skew: skew angle of the sensor.
%   A vector containing all said parameters is then returned.

%     Compute and return the parameters.
    u0 = K(1, 3);
    v0 = K(2, 3);
    
    au = K(1, 1);
    skew = atan(au/K(1, 2));
    av = K(2, 2)/sin(skew);
end

