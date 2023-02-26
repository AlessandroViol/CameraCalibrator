function [newData] = compensateRadialDist(K,k1,k2,imageData)
%compensateRadialDist: returns a struct of imageData containing rectified pixel
%coordinates of the points
%
%   [newData] = compensateRadialDist(K,k1,k2,imageData) returns a structure imageData
%   that contains the new XYpixel coordinates of the rectified points of the
%   argument imageData. The rectification assumes that the radial distortion effect
%   is caused by a polinomial of coeficients k1 and k2.
%   
%   K: 3 by 3 upper diagonal matrix that represents the intrinsic parameters matrix.
%   k1: scalar that represents the first coeficient of the radial distortion effect.
%   k2: scalar that represents the second coeficient of the radial distortion effect.
%   imageData: a struct that contains the pixel coordinates of the points to rectify.
%
%   By applying the newton's method to the normalized imageData pixel coordinates to
%   an opportune function obtained from the polinomial that describes the radial
%   distortion we can recover the undistorted (or rectified) pixel coordinates. These
%   coordinates are then saved into a new struct, which is then returned.

%     Obtain the intrinsic parameters from K.
    [u0, v0, au, av, skew] = unpackIntrinsics(K);

%     For each point of the vector.
    for ii = 1:length(imageData.CheckerboardPoints)
%         Normalize the coordinates of the image as the distorted coordinates
        xT = (imageData.CheckerboardPoints(ii, 1) - u0)/au;
        yT = (imageData.CheckerboardPoints(ii, 2) - v0)/av;

%         Initialize the two candidates undistorted points as the distorted points.
        x = xT;
        y = yT;

%         Iterate the newton's method for a maximum of 30 times.
        for jj = 1:100
%             Call newton's method on the candidate solutions x and y.
            [x, y] = newton(x, y, k1, k2, xT, yT);

%             Apply the distortion to the found coordinates
            f = [x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);...
                 y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2)];

%             Compute the difference between the found distorted solutions and the
%             original point's coordinates. We need to revert the normalization.
            distX = abs((f(1)*au+u0) - xT);
            distY = abs((f(2)*av+v0) - yT);
            
%             If the difference is less than a tenth of a pixel we stop the
%             iterations
            if(distX < 1/length(imageData.XYpixel) && distY < 1/length(imageData.XYpixel))
%                 Save the solution.
                imageData.XYpixel(ii, :) = [x*au+u0, y*av+v0];
                break;
            end
        end
%         Save the solution.
        imageData.XYpixel(ii, :) = [x*au+u0, y*av+v0];
    end
%     Return the new struct with the undistorted points.
    newData = imageData;
end

