function [xn,yn] = newton(x,y,k1,k2,xT,yT)
%newton: returns a better approximation of the roots of the function that defines the
%radial distortion effect.
%
%   [xn,yn] = newton(x,y,k1,k2,xT,yT) returns two scalars that represent the
%   coordinates of an approximation of the roots of the function that models the
%   radial distortion of a camera, characterized by their two coefficients k1, k2 and
%   the biases xT and yT that represent the distorted coordinates.
%   
%   x: scalar that reprensent the first normalized pixel coordinates of a candidate
%      undistorted point.
%   y: scalar that reprensent the second normalized pixel coordinates of a candidate
%      undistorted point.
%   k1: scalar that represents the first coeficient of the radial distortion effect.
%   k2: scalar that represents the second coeficient of the radial distortion effect.
%   xT: scalar that reprensent the first normalized pixel coordinates of the
%   distorted point.
%   yT: scalar that reprensent the second normalized pixel coordinates of the
%   distorted point.
%
%   By computing the Jacobian of the function f we can obtain a better estimate of
%   the roots of f than the proposed x,y candidates using the newton's method. The
%   function is defined by the two radial distortion coeficients k1, k2 and by the
%   two point's distorted coordinates xT, yT.

%     Define the jacobian of f.
    J = [x*(2*k1*x+4*k2*x*(x^2+y^2))+k1*(x^2+y^2)+k2*(x^2+y^2)^2+1, x*(2*k1*y+4*k2*y*(x^2+y^2));...
         y*(2*k1*x+4*k2*x*(x^2+y^2)), y*(2*k1*y+4*k2*y*(x^2+y^2))+k1*(x^2+y^2)+k2*(x^2+y^2)^2+1];

%     Define f.
    f = [x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2)-xT;...
         y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2)-yT];

%     Find the new candidates for the root of f.
    pn = [x; y] - inv(J)*f;

%     Return the candidates.
    xn = pn(1);
    yn = pn(2);
end

