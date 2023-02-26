function [p] = visualizeResults(imageData, calObjMeasures, K, k1, k2, oldPoints)
%viualizeResults: creates a plot to visualize the results of the reprojection and
%rectification along with the intrinsic and extrinsic parameters, radial distortion
%coeficients and reprojection error.
%
%   [p] = viualizeResults(imageData, calObjMeasures, K, k1, k2, oldPoints) returns a
%   handle to a plot that shows the results of the reprojections of the points of the
%   calibration object in the image with respect to the actual points and the
%   rectified points. It also shows the values of the intrinsic and extrinsic
%   parameters, radial distortion coeficient and reprojection error for that image.
%   
%   imageData: a struct that contains an image, a 3 by 4 perspective projection
%              matrix P and the rectified pixel coordinates of the points to compare
%              in the plot.
%   calObjMeasures: matrix of rows of coordinates in millimiters of the calibration
%              object points that will be projected using the matrix P of imageData.
%   K: 3 by 3 upper diagonal matrix that represents the intrinsic parameters matrix.
%   k1: scalar that represents the first coeficient of the radial distortion effect.
%   k2: scalar that represents the second coeficient of the radial distortion effect.
%   oldPoints: matrix of rows of distorted point's pixel coordinates of the image.
%
%   By computing the results of the projection of the points of calObjMeasures, we
%   can plot separately three sets of points, the newly computed projected ones, the
%   rectified ones provided inside imageData and the distorted one of oldPoints. We
%   then unpack the intrinsic parameters matrix K and compute the reprojection error,
%   so that now we can also present the values of the intrinsic and extrinsic
%   parameters, radial distortion coeficient and reprojection error for that image.

%     Obtain the intrinsic parameters
    [u0, v0, au, av, skew] = unpackIntrinsics(K);
    p = figure; 
    imshow (imageData.I, 'InitialMagnification', 500);
    hold on;
%     For each point of the calibration object.
    for jj = 1:length(imageData.XYpixel)
%         Express the calibration object point's coordinates in homogeneous
%         coordinates.
        m = [calObjMeasures(jj, 1);...
             calObjMeasures(jj, 2);...
             0;...
             1];
         
%         Project the points.
        u = (imageData.P(1, :)*m)/(imageData.P(3, :)*m);
        v = (imageData.P(2, :)*m)/(imageData.P(3, :)*m);  
        
%         Apply radial distortion to all the points.
%         Normalize the coordinates.
        x = (u - u0)/au;
        y = (v - v0)/av;
        
%         Apply radial distortion
        u = x*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        v = y*(1+k1*(x^2+y^2)+k2*(x^2+y^2)^2);
        
%         Invert the coordinates normalization.
        u = u*au+u0;
        v = v*av+v0;
        
% %         Plot the rectified points as blue circles.
%         plot(imageData.XYpixel(jj, 1), imageData.XYpixel(jj, 2), 'ob');
%         Plot the projected points as red circles.
        plot(u, v, 'or');
        

%         Project the points.
        u = (imageData.firstP(1, :)*m)/(imageData.firstP(3, :)*m);
        v = (imageData.firstP(2, :)*m)/(imageData.firstP(3, :)*m);
%         Plot the rectified points as blue circles.
        plot(u, v, 'ob');  
        
%         Plot the distorted points as green circles.
        plot(oldPoints(jj, 1), oldPoints(jj, 2), 'og');
    end
    
%     Set the size of the text for the parameters visualization.
    textSize = 10;
%     Define some shorthands.
    R = imageData.R;
    t = imageData.t;
    
%     Prepare the string column vector with all the parameters.
    strings = ["u0 = " + num2str(u0);...
               "v0 = " + num2str(v0);...
               "au = " + num2str(au);...
               "av = " + num2str(av);...
               "skew = " + num2str(skew);...
               "R = " + num2str(R(1,1)) + ",   " + num2str(R(1,2)) + ",   " + num2str(R(1,3));...
               "       " + num2str(R(2,1)) + ",   " + num2str(R(2,2)) + ",   " + num2str(R(2,3));...
               "       " + num2str(R(3,1)) + ",   " + num2str(R(3,2)) + ",   " + num2str(R(3,3));...
               "t = " + num2str(t(1)) + ",   " + num2str(t(2)) + ",   " + num2str(t(3));...
               "k1 = " + num2str(k1);...
               "k2 = " + num2str(k2);...
               "Reprojection error = " + num2str(computeReprError(imageData.P, calObjMeasures, imageData.XYpixel))];
           
%     Print the textbox with all the parameters
    text(textSize/2, 480 - textSize/2, {strings(1), strings(2), strings(3), strings(4), strings(5),... 
        strings(6), strings(7), strings(8), strings(9), strings(10), strings(11), strings(12)},...
        'FontSize', textSize, 'BackgroundColor', 'w', 'VerticalAlignment', 'bottom');
    hold off;
%     Print the legend.
%     legend({'Rectified checkerboard points', 'Projected points', 'Detected checkerboard points'},...
%         'Location','northwest','Orientation','vertical')
legend({'Projected points after compensation',...
    'Original projected points',...
    'Detected checkerboard points'},...
        'Location','northwest','Orientation','vertical')
end