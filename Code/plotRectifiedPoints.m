function [p] = plotRectifiedPoints(imageData, oldPoints)
%plotRectifiedPoints: creates a plot to visualize the results of the reprojection.
%
%   [p] = plotRectifiedPoints(imageData, oldPoints) returns a handle to a plot that
%   shows the results of the rectification of the points of the pixel in the image
%   with respect to the distorted points oldPoints in the image.
%   
%   imageData: a struct that contains an image and the rectified pixel coordinates of
%              the points to compare in the plot.
%   oldPoins: matrix of rows of coordinates in pixel of the distorted image points.
%
%   We plot the rectified points of imageData as blue circles and the distorted
%   points of oldPoints as green circle. A handle to the plot with the correct legend
%   is then returned.
    p = figure; 
    imshow (imageData.I, 'InitialMagnification', 500);
    hold on;
    
%     Plot the rectified points.
    plot(imageData.XYpixel(:, 1), imageData.XYpixel(:, 2), 'ob')
%     Plot the distorted points.
    plot(oldPoints(:, 1), oldPoints(:, 2), 'og')
    hold off;
%     Add the legend.
    legend({'Rectified checkerboard points', 'Detected checkerboard points'},...
        'Location', 'northwest', 'Orientation', 'vertical')
end
