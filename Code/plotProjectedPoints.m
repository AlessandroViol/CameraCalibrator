function [p] = plotProjectedPoints(imageData, calObjMeasures)
%plotProjectedPoints: creates a plot to visualize the results of the reprojection.
%
%   [p] = plotProjectedPoints(imageData, calObjMeasures) returns a handle to a plot
%   that shows the results of the reprojections of the points of the calibration
%   object in the image with respect to the actual points.
%   
%   imageData: a struct that contains an image, a 3 by 4 perspective projection
%              matrix P and the pixel coordinates of the points to compare in the
%              plot.
%   calObjMeasures: matrix of rows of coordinates in millimiters of the calibration
%              object points that will be projected using the matrix P of imageData.
%
%   By computing the results of the projection of the points of calObjMeasures, we
%   can plot separately two sets of points, the newly computed ones and the ones
%   provided inside imageData. The resulting plot allows us to visualize the quality
%   of the perspective projection matrix P.

    p = figure; 
%     View the image in the plot.
    imshow (imageData.I, 'InitialMagnification', 500);
%     Allow multiple representations of the method plot.
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

%         Plot the projected points as red circles.
        plot(u, v, 'or');
%         Plot the actual points in the image as green circles.
        plot(imageData.XYpixel(jj, 1), imageData.XYpixel(jj, 2), 'og');
    end
    hold off;
    
%     Plot the legend of the points in the image.
    legend({'Projected points', 'Detected checkerboard points'},...
        'Location', 'northwest', 'Orientation', 'vertical')
end