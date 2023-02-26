function [p] = visualizeEstrinsics(imageData, squareSize, indexes)
%visualizeEstrinsics: creates a 3D plot to visualize the extrinsic parameters of the
%camera.
%
%   [p] = visualizeEstrinsics(imageData, squareSize, indexes) returns a handle to a
%   3D plot that shows the extrinsics of the camera as the position and rotation of
%   the checkerboards with respect to the camera in a cameracentric way.
%   
%   imageData: a vector of structs that contains a 3 by 3 rotation matrix R, a 3
%              element translation vector t and the vector of the dimensions of the
%              checkerboard.
%   squareSize: size in millimiters of a checkerboard's square edge.
%   indexes: index of the image associated to the planes in the plot
%
%   By applying the rotation and translation to the planes defined by squareSize and
%   by the dimensions specified in the imageData struct, we build a 3d plot to view
%   the position and rotation of the checkerboards with respect to the camera. An
%   handle to the graph is returned.

%     Define the rectangle that represent the checkerboard.
    r = [0 0 squareSize*imageData(1).dim(2) squareSize*imageData(1).dim(2);...
         0 squareSize*imageData(1).dim(1) squareSize*imageData(1).dim(1) 0];

    figure
%         Properties of the figure, builded starting from an empty 3d plot.
        h = plot3(0,0,0);
        axis equal
        grid on;
    hold on
    
%     Select a color map.
    colorM = colormap(turbo);
    color = [];
%     Create a vector of selected colors from the color map.
    for ii = 1:length(imageData)
        color = [color;...
                 colorM((ii-1)*floor(length(colorM)/length(imageData))+1,:)];
    end
    
%     Draw the axis at the position of the camera
    cAxis = [0, 100, 0, 0, 0, 0;...
             0, 0, 0, 100, 0, 0;...
             0, 0, 0, 0, 0, 100];
    plot3(cAxis(1,:), cAxis(3,:), cAxis(2,:), 'black', 'LineWidth', 3);
    axisLabel = ["Xc", "Yc", "Zc"];
%     Plot the labels of the axis
    for ii = 1:3
        text(cAxis(ii,2)*1.2, cAxis(ii,6)*1.2, cAxis(ii,4)*1.3, axisLabel(ii),...
            'FontSize', 15, 'Color', 'black');
    end
    
%     Plot the rotated and translated planes for each image.
    for ii = 1:length(imageData)
%         Define some shorthands
        R = imageData(ii).R;
        t = imageData(ii).t;

%         Represent the position and rotation of the planes with respect to the
%         camera
        R = [-R(:, 1), -R(:, 2), R(:, 3)];
        t = -t;
        
%         Creates the vectors of points of the rectangle
        x = r(1, :);
        y = r(2, :);
        z = zeros(1, length(x));

%         Transform the points
        for jj = 1:length(r)
            p = R * [x(jj); y(jj); z(jj)] + t;
            x(jj) = p(1);
            y(jj) = p(3);
            z(jj) = -p(2);
        end
%         Plots a filled transformed plane.
        fill3(x, y, z, color(ii, :));
        alpha(0.25);
%         Plots the number of image of which we are plotting the extrinsics.
        text(x(1)-25, y(1)-25, z(1)+25, num2str(indexes(ii)), 'FontSize', 22, 'Color', color(ii, :)/1.5);   
    end
    
%     We use a function of the computer vision toolbox's libraries to easely plot a
%     camera placeholder in the space. A simple plot of a triangle could also
%     accomplish the same feat.
    R = [-1 0 0; 0 0 1;0 1 0];
    t = [0 0 0];
    pose = rigid3d(R,t);
    plotCamera('AbsolutePose',pose,'Opacity',0.1,'size',30,'color','black')    
    
%     We make the plot space symmetrical to the camera.
    lim = axis;
    if(abs(lim(1)) > abs(lim(2)))
        lim(2) = -lim(1);
    else
        lim(1) = -lim(2);
    end
    if(abs(lim(5)) > abs(lim(6)))
        lim(6) = -lim(5);
    else
        lim(5) = -lim(6);
    end
    axis(lim);
    hold off;
end