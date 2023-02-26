function [p] = plotProjectedPointsRadDist(imageData, oldPoints, calObjMeasures)
%plotProjectedPointsRadDist: creates a plot to visualize the results of the
%reprojection and rectification.
%
%   [p] = plotProjectedPointsRadDist(imageData, oldPoints, calObjMeasures) returns a
%   handle to a plot that shows the results of the reprojections of the points of the
%   calibration object in the image with respect to the actual points and the
%   rectified points.
%   
%   imageData: a struct that contains an image, a 3 by 4 perspective projection
%              matrix P and the rectified pixel coordinates of the points to compare
%              in the plot.
%   oldPoints: matrix of rows of distorted point's pixel coordinates of the image.
%   calObjMeasures: matrix of rows of coordinates in millimiters of the calibration
%              object points that will be projected using the matrix P of imageData.
%
%   By computing the results of the projection of the points of calObjMeasures, we
%   can plot separately three sets of points, the newly computed projected ones, the
%   rectified ones provided inside imageData and the distorted one of oldPoints.

    p = figure; 
        imshow (imageData.I, 'InitialMagnification', 500);
        hold on;
%     For each point in the calibration oject compute the projected pixel coordinates
%     and plot the points.    
    for jj = 1:length(imageData.XYpixel)
%         Homogeneous coordinates of the calibration object points.
        m = [calObjMeasures(jj, 1);...
             calObjMeasures(jj, 2);...
             0;...
             1];
         
%         Compute the pixel coordinates by applying the projection of the homogeneous
%         coordinates.
        u = (imageData.P(1, :)*m)/(imageData.P(3, :)*m);
        v = (imageData.P(2, :)*m)/(imageData.P(3, :)*m);       
        
%         Plot the rectified points as blue circles.
        plot(imageData.XYpixel(jj, 1), imageData.XYpixel(jj, 2), 'ob');
%         Plot the projected points as red circles.
        plot(u, v, 'or');
%         Plot the distorted points as green circles.
        plot(oldPoints(jj, 1), oldPoints(jj, 2), 'og');
    end
    hold off;
%     Add the legend to the plot
    legend({'Rectified checkerboard points', 'Projected points', 'Detected checkerboard points'},'Location','northwest','Orientation','vertical')
end
