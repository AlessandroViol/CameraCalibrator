function [k1, k2] = estimateRadialDistCoef(calObjMeasures, K, imageData)
%stimateRadialDistCoef: returns an estimate of the radial distortion coeficients
%
%   [k1, k2] = estimateRadialDistCoef(calObjMeasures, K, imageData) returns two
%   scalars that represents an estimate of the radial distortion effect of a camera.
%   To make this estimate, some correspondances between the points of a calibration
%   object and the image are needed, as well as the intrinsic parameters and the
%   projection matrix that generated the image
%   
%   calObjMeasures: matrix of rows of coordinates in millimiters of the calibration
%              object points that will be projected using the matrix P of imageData.
%   K: 3 by 3 upper diagonal matrix that represents the intrinsic parameters matrix.
%   imageData: a vector of structs that contains a 3 by 4 perspective projection
%              matrix P and the pixel coordinates of the points of the checkerboard.

%
%   By approximating the radial distortion effect as a polinomial, we can obtain the
%   parameters k1 and k2 from the assumption that we have the correct perspective
%   projection matrix P. By using the projected calObjMeasures point's coordinates as
%   the ideal undistorted coordinates and the detected imageData points as the
%   distorted coordinates, we can obtain an overdetermined non-homogeneous system
%   solvable with least squares. The result are the two parameters k1 and k2 that are
%   then returned.

%     Obtain the intrinsic parameters from K.
    [u0, v0, au, av, skew] = unpackIntrinsics(K);


%     Define an empty matrix and vector for building the linear equations system.
    A = [];
    b = [];

%     For each image we compute a system of equations describing the radial
%     distortion.
    for ii = 1:length(imageData)
%         Define some shorthands for the equations.
        P = imageData(ii).P;
        XYpixel = imageData(ii).CheckerboardPoints; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Changed!

%         For each pair of points we obtain two equations
        for jj = 1:length(XYpixel)
%             Homogeneous coordinates of the calibration object points.
            m = [calObjMeasures(jj, 1);...
                 calObjMeasures(jj, 2);...
                 0;...
                 1];

%             Projection of the calibration object coordinates.
            u = (P(1, :)*m)/(P(3, :)*m);
            v = (P(2, :)*m)/(P(3, :)*m);

%             Distorted coordinates shorthands.
            uT = XYpixel(jj, 1);
            vT = XYpixel(jj, 2);

%             Define the scaling factor rdSquared.
            rdSquared = ((u-u0)/au)^2 + ((v-v0)/av)^2;

%             Build the overdetermined non-homogeneous linear system of equations bya
%             appending a new pair of equations to both A and b.
            A = [A;...
                (u-u0)*rdSquared, (u-u0)*rdSquared^2;...
                (v-v0)*rdSquared, (v-v0)*rdSquared^2];
            b = [b;...
                uT-u;...
                vT-v];
        end
    end

%     Obtain and return the two coeficients.
%     coef = inv(A'*A)*A'*b;
    coef = A\b;

    k1 = coef(1); 
    k2 = coef(2);

%     Alternative way to obtain the coeficients
%     [Q, R] = qr(A);
%     coef = R\(Q'*b);
%     k1 = coef(1); 
%     k2 = coef(2);
end

