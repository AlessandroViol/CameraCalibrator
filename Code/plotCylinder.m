function [p] = plotCylinder(imageData, K, k1, k2, pos, r, h)
%plotCylinder: creates a plot where a cylinder is overlayed to an image.
%
%   [p] = plotCylinder(imageData, K, k1, k2, pos, r, h) returns a handle to a plot
%   that shows a cylinder of radius r and height h in the position pos of a
%   checkerboard using the camera model specified by imageData, K and k1, k2.
%   
%   imageData: a struct that contains an image and a 3 by 4 perspective projection
%       matrix P.
%   K: 3 by 3 upper diagonal matrix that represents the intrinsic parameters matrix.
%   k1: scalar that represents the first coeficient of the radial distortion effect.
%   k2: scalar that represents the second coeficient of the radial distortion effect.
%   pos: a 2 elements row vector that represents the coordinates in millimiters of
%       the center of the base of the cilinder in the checkerboard.
%   r: scalar that represents radius of the cylinder
%   h: scalar that represents height of the cylinder
% 
%   The points are obtained from the cylinder method and are projected using the
%   perspective projection matrix P of imageData. We also add radial distortion using
%   k1 and k2.

%     Obtain the cylinder points coordinates.
    [X, Y, Z] = cylinder(r, 40);
%     Add more points between the bases to give a better looking result.
    Z = ones(51, 41).*(0:1:50)';
    Z = Z./50;
    
%     Set the cylinder height.
    Z = Z*h;

%     Define the points of the lower and upper base of the cylinder.
    lowerBase = [X(1, :); Y(1, :); Z(1, :)];
    upperBase = [X(2, :); Y(2, :); Z(end, :)];

%     Define the translation vector of the cylinder and apply the translation.
    tcyl = [pos, 0];
    lowerBase = lowerBase + tcyl';
    upperBase = upperBase + tcyl';

%     Express the points of the bases in homogeneous coordinates.
    lowerBase = [lowerBase; ones(1, length(X(1,:)))];
    upperBase = [upperBase; ones(1, length(X(2,:)))];

%     Define some shorthands.
    t = imageData.t;
    R = imageData.R;
    
%     Compute P.
    P = K*[R, t];

    figure
        imshow (imageData.I, 'InitialMagnification', 500)
    hold on 

%     Project the lower base.
    lowerBase = [(P(1, :)*lowerBase)./(P(3, :)*lowerBase);...
            (P(2, :)*lowerBase)./(P(3, :)*lowerBase)];

%     Obtain the intrinsic parameters.
    [u0, v0, au, av, skew] = unpackIntrinsics(K);

%     Apply radial distortion to all the points
    for ii = 1:length(lowerBase)
%         Normalize the coordinates
        x = (lowerBase(1, ii) - u0)/au;
        y = (lowerBase(2, ii) - v0)/av;
        
%         Apply radial distortion
        lowerBase(1, ii) = x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        lowerBase(2, ii) = y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        
%         Invert the coordinates normalization.
        lowerBase(1, ii) = lowerBase(1, ii)*au+u0;
        lowerBase(2, ii) = lowerBase(2, ii)*av+v0;
    end

%     Draw the blue lower base.
    hnd = fill(lowerBase(1, :), lowerBase(2, :), 'b', 'LineWidth', 3);
    alpha(hnd, 0.25);
%     Add a text to better identify it.
    text(mean(lowerBase(1, :)), mean(lowerBase(2, :)), "B", 'FontSize', 16, 'Color', 'w'); 
    
%     Do the same for the upper base.
%     Project the upper base.
    upperBase = [(P(1, :)*upperBase)./(P(3, :)*upperBase);...
            (P(2, :)*upperBase)./(P(3, :)*upperBase)];
        
%     Apply radial distortion to all the points
    for ii = 1:length(upperBase)
%         Normalize the coordinates
        x = (upperBase(1, ii) - u0)/au;
        y = (upperBase(2, ii) - v0)/av;
        
%         Apply radial distortion
        upperBase(1, ii) = x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        upperBase(2, ii) = y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        
%         Invert the coordinates normalization.
        upperBase(1, ii) = upperBase(1, ii)*au+u0;
        upperBase(2, ii) = upperBase(2, ii)*av+v0;
    end

%     Draw the green upper base.
    hnd = fill(upperBase(1, :), upperBase(2, :), 'g', 'LineWidth', 3);
    alpha(hnd, 0.25);
%     Add a text to better identify it.
    text(mean(upperBase(1, :)), mean(upperBase(2, :)), "T", 'FontSize', 16, 'Color', 'w'); 
    
%     For each side of the cylinder.
    for ii = 1:40
        rectangle = [];
%         build a piece of the side of the cylinder as a rectangle.
        for jj = 1:50
            rectangle = [rectangle, [[X(1, ii:(ii+1)), X(1, (ii+1):-1:ii)];...
                                     [Y(1, ii:(ii+1)), Y(1, (ii+1):-1:ii)];...
                                     [Z(jj, ii:(ii+1)), Z(jj+1, ii:(ii+1))]]];
        end
        
%         Translate the coordinates
        rectangle = rectangle + tcyl';
%         Express them in homogeneous coordinates
        rectangle = [rectangle; ones(1, length(rectangle(1,:)))];
        
%         Project the coordinates
        rectangle = [(P(1, :)*rectangle)./(P(3, :)*rectangle);...
            (P(2, :)*rectangle)./(P(3, :)*rectangle)];

%         Apply radial distortion to them.
        for kk = 1:length(rectangle)
%             Normalize the coordinates.
            x = (rectangle(1, kk) - u0)/au;
            y = (rectangle(2, kk) - v0)/av;

%             Distort the coordinates.
            rectangle(1, kk) = x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
            rectangle(2, kk) = y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);

%             Invert the coordinates normalization.
            rectangle(1, kk) = rectangle(1, kk)*au+u0;
            rectangle(2, kk) = rectangle(2, kk)*av+v0;
        end

%         Draw part of the side of the cylinder
        hnd = fill(rectangle(1, :), rectangle(2, :), 'w', 'LineStyle', 'none');
        alpha(hnd, 0.25);
    end
end