clear all % Clear workspace.

personalDevice = 0; % Boolean to calibrate our personal device

if(personalDevice)
    iimage = 1:7; % Indices of the images to be processed for our device calibration.
else
    iimage = 1:18; % Indices of the images to be processed.
end

% Load images.
for ii = 1:length(iimage)
%     Compose the path of one of the specified images and open it. The image data is
%     then stored in an array of structures imageData.
    if(personalDevice)
        imageFileName = fullfile('images', ['imagec', num2str(iimage(ii)), '.png'])
    else
        imageFileName = fullfile('images', ['image', num2str(iimage(ii)), '.tif'])
    end
    
    imageData(ii).I = imread(imageFileName); 
    
%     Check that all the images have the same size in pixel, otherwise we'll trow an
%     exception and stop the execution.
    pixSzRef = size(imageData(1).I);
    pixSz = size(imageData(ii).I);
    
    if(pixSz(1) ~= pixSzRef(1) || pixSz(2) ~= pixSzRef(2))
        ME_dis = MException('MyComponent:recognizedDifferentImageSizes', ...
            "The image %d has a size of %dx%d pixel."+...
            "Expected an image of %dx%d pixel instead.", iimage(ii), pixSz(2), pixSz(1),...
            pixSzRef(2), pixSzRef(1));
        
        throw(ME_dis)
    end
    
%     By calling the method detectCheckerboardPoints we obtain the pixel coordinates
%     of the upper left corners of the checkerboard's squares and its size, expressed
%     as the number of rows and columns of the checkerboard.
    [imageData(ii).XYpixel, imageData(ii).dim] = detectCheckerboardPoints(imageData(ii).I);

%     We are interested in just the location of the upper left corner of each square,
%     so the actual number of points of the checkerboard we are considering is one
%     less than the number provided by the method.
    imageData(ii).dim = imageData(ii).dim - 1;

%     Check that all the checkerboards have a consistent number of rows and columns.
%     If a checkerboard has a different number of rows or columns we'll throw an
%     exception and stop the execution.
    n = imageData(1).dim(1);
    m = imageData(1).dim(2);
    
    if(imageData(ii).dim(1) ~= n || imageData(ii).dim(2) ~= m)
        length(imageData)
        ME_rdc = MException('MyComponent:recognizedDifferentCheckerboard',...
            "The checkerboard %d is recognized as a %dx%d checkerboard."+...
            "Expected a %dx%d checkerboard instead.", iimage(ii), imageData(ii).dim(1),...
            imageData(ii).dim(2), n, m);
        
        throw(ME_rdc)
    end
    
%     Lastly, we check if the detectCheckerBoardPoints method has been able to
%     recognize all the points.
    if(any(isnan(imageData(ii).XYpixel)))
        ME_bcr = MException('MyComponent:badCheckerboardRecognition',...
            "The detectCheckerboardPoints couldn't recognize all of the"+...
            "checkerboard's points in image %d.", iimage(ii));

        throw(ME_bcr)
    end
end

% In order to calibrate the camera, we need to know the coordinates in millimiters of
% the checkerboard's squares corners.
squareSize = 30;    %size of each square in millimiters
% By invoking the method getCheckerboardWorldPoints we obtain the coordinates in
% millimeters of each point of the checkerboard calibration object
calObjMeasures = getCheckerboardWorldPoints(imageData(1).dim, squareSize);

% We perform a test to investigate the effect of the number of points considered in
% the homographies estimation onto the reprojection error
[homErrors, NoP] = testHomographyNoP(calObjMeasures, imageData);

% Plot the result of the test
figure
hold on
grid on
p = plot(NoP(1:end), homErrors(1:end));
xlabel('Number of points');
ylabel('Reprojection error');

% Estimate the homographies for each image on all of its points.
for ii = 1:length(imageData)
    imageData(ii).H = estimateHomography(calObjMeasures, imageData(ii).XYpixel);
end

% We perform a test to investigate the effect of the size of the image set used to
% estimate the intrinsic parameters matrix K onto the reprojection error. We do this
% by applying a leave-one-out cross validation like procedure.
KErrorsMatrix = [];
% Get a randomly generated permutation of the indexes of the images.
indexesK = randperm(length(imageData));

% Select one of the images each time and then estimate the intrinsic parameters
% matrix on the others
for ii = 1:length(imageData)
%     Obtain the indexes of the images for which we want to estimate K.
    idx = setdiff(indexesK, ii);
%     Test the estimated K matrices for a different sizes of image set on the
%     selected image.
    [KErrors, NoI] = testIntrinsicsNoI(calObjMeasures, imageData(idx),...
        imageData(indexesK(ii)));
    KErrorsMatrix = [KErrorsMatrix; KErrors'];
end
% Plot the results.
figure
hold on
grid on
boxplot(KErrorsMatrix, 'Labels', {NoI(1:end)});
xlabel('Number of images');
ylabel('Reprojection error');
% Plot the average of the results above
figure
plot(NoI(1:end), sum(KErrorsMatrix, 1)/length(imageData))
xlabel('Number of images');
ylabel('Average reprojection error');

% To investigate if the order of the images considered in the previous test might
% have affected the results, we perform it 50 times. Each time we randomize the order
% of the images.
KErrorsDistribution = [];
for jj = 1:50
    KErrorsMatrix = [];
%     Each iteration shuffle the images
    indexesK = randperm(length(imageData));
%     Repeat the test above
    for ii = 1:length(imageData)
        idx = setdiff(indexesK, ii);
        [KErrors, NoI] = testIntrinsicsNoI(calObjMeasures, imageData(idx), imageData(indexesK(ii)));
        KErrorsMatrix = [KErrorsMatrix; KErrors'];
    end
%     Average the errors obtained from each iteration of the for cycle above
    KErrorsDistribution = [KErrorsDistribution; sum(KErrorsMatrix, 1)/length(imageData)];
end
% Plot the results.
figure
hold on
grid on
boxplot(KErrorsDistribution, 'Labels', {NoI(1:end)});
xlabel('Number of images');
ylabel('Reprojection error');

% Estimate K on a subset of 6 images, as suggested by the test above. We fixed this
% particular set so that we always obtain the same results
if(personalDevice)
    indexesK = 1:7; % Indexes for our device calibration.
else
    indexesK = [1 2 7 10 14 16];
end

K = estimateIntrinsics(imageData(indexesK));

totalReprojectionError = 0; % We want to sum the reprojection error of each image.

% For each image we estimate the estrinsic parameters and compute the reprojection
% error
for ii = 1:length(imageData)
%     We use the method estimateRt to get the rotation matrix R and the translation
%     vector t of each image.
    [imageData(ii).R, imageData(ii).t] = estimateRt(imageData(ii).H, K);
    
%     For ease of future access, we define the perspective projection matrix P and
%     store it inside the corresponding imageData element.
    imageData(ii).P = K * [imageData(ii).R, imageData(ii).t];
    imageData(ii).firstP = imageData(ii).P;
    
%     Compute the reprojection error on the image and add it to the total
%     reprojection error of all the images.
    totalReprojectionError = totalReprojectionError + computeReprError(imageData(ii).P,...
        calObjMeasures, imageData(ii).XYpixel);
    
%     Plot the results of the projection of the calibration object's points using the
%     estimated P
    p = plotProjectedPoints(imageData(ii), calObjMeasures);
%     Save the plot
%     imagePath = fullfile("grafici", "Figure 6 image " + num2str(ii) + ".png");
%     saveas(gcf, imagePath)

%     For future plots and elaborations, we want to save the points detected by the
%     detectCheckerboardPoints method inside another variable of imageData.
    imageData(ii).CheckerboardPoints = imageData(ii).XYpixel;
end

% We obtain an estimate of the radial distortion's coefficients k1 and k2 using the
% method estimateRadialDistCoef. We use the whole image set and all their points for
% the estimate.
[k1, k2] = estimateRadialDistCoef(calObjMeasures, K, imageData);

% We now apply radial distortion compensation to get the pixel coordinates of the
% undistorted points of the checkerboard's corners in the images. We use these new
% points coordinates to estimate again the homographies and the intrinsics and
% estrinsics parameters. By doing that and by re-computing the reprojection error, we
% can see that we obtain better results this way.
for ii = 1:length(imageData)
%     We replace the old imageData(ii) wit a new one returned by the method
%     compensateRadialDistortion, which replaces the old XYpixel distorted
%     coordinates with an aproximation of the corresponding undistorted coordinates
    imageData(ii) = compensateRadialDist(K, k1, k2, imageData(ii));
    
%     We plot the new and old points to be able to easely check the differences
    plotRectifiedPoints(imageData(ii), imageData(ii).CheckerboardPoints);
%     We save the plotted images.
%     imagePath = fullfile("grafici", "Figure 7 image " + num2str(ii) + ".png");
%     saveas(gcf, imagePath)
    
%     We can now estimate again the homographies using the rectified points.
    imageData(ii).H = estimateHomography(calObjMeasures, imageData(ii).XYpixel);
end

% We use the new estimated homographies to re-estimate the intrinsic parameters
% matrix K. We will still use the same subset of images as in the previous estimation
% of K.
K = estimateIntrinsics(imageData(indexesK));


totalReprojectionError = [totalReprojectionError; 0]; % We want to append the new
                                                      % total reprojection error to
                                                      % the previous calculated value

% We can now estimate the estrinsics parameters R and t and compute the perspective
% projection matrix P to compute the new reprojection error.
for ii = 1:length(imageData) 
%     Estimate the rotation matrix R and the translation vector t
    [imageData(ii).R, imageData(ii).t] = estimateRt(imageData(ii).H, K);
%     Compute the perspective projection P
    imageData(ii).P = K * [imageData(ii).R, imageData(ii).t];
    
%     Compute the reprojection error and append it to the vector of total
%     reprojection errors.
    totalReprojectionError(end) = totalReprojectionError(end) + ...
        computeReprError(imageData(ii).P, calObjMeasures, imageData(ii).XYpixel);
end

% To investigate how much the reprojection error decreases with subsequent
% compensations and estimations, we decided to iterate the procedure to observe the
% reprojection error for 25 found perspective projection matrix, starting with the
% one estimated without compensation.
for jj = 1:43
%     We append a new counter for the total reprojection error
    totalReprojectionError = [totalReprojectionError; 0];
    
%     Estimate the new radial distortion parameters
    [k1, k2] = estimateRadialDistCoef(calObjMeasures, K, imageData);

%     For each image we compensate the radial distortion and then we estimate their
%     new homography matrix.
    for ii = 1:length(imageData)
        imageData(ii) = compensateRadialDist(K, k1, k2, imageData(ii));

        imageData(ii).H = estimateHomography(calObjMeasures, imageData(ii).XYpixel);
    end

%     We estimate the intrinsic parameters matrix K on the usual subset of images
    K = estimateIntrinsics(imageData(indexesK));

    errorImage = [];

    for ii = 1:length(imageData) 
        [imageData(ii).R, imageData(ii).t] = estimateRt(imageData(ii).H, K);
        imageData(ii).P = K * [imageData(ii).R, imageData(ii).t];
% 
%         errorImage = [errorImage; computeReprError(imageData(ii).P, calObjMeasures, imageData(ii).XYpixel)];
%         totalReprojectionError(end) = totalReprojectionError(end) + errorImage(end);
        totalReprojectionError(end) = totalReprojectionError(end) + ...
            computeReprError(imageData(ii).P, calObjMeasures, imageData(ii).XYpixel);
    end
end

% Plot the results
figure
hold on
grid on
plot(1:length(totalReprojectionError), totalReprojectionError);
xlabel('Number of iteration');
ylabel('Reprojection error');

% We use the visualizeEstrinsics method to plot some planes in the space and in the
% corresponding positions and rotations.

if(personalDevice)
    visualizeEstrinsics(imageData([1 3 5 7]), squareSize, [1 3 5 7]); % For our device calibration
else
    visualizeEstrinsics(imageData([1 6 9 10]), squareSize, [1 6 9 10]);
end

% For each image we now make some result's summary plots.
for ii = 1:length(imageData)
%     Plot the reprojected, rectified and detcetd corner points to confront their
%     position and to visualize the effects of the rectification and projection.
%     plotProjectedPointsRadDist(imageData(ii), imageData(ii).CheckerboardPoints,...
%         calObjMeasures);
%     Save the images.
%     imagePath = fullfile("grafici", "Figure 9 image " + num2str(ii) + ".png");
%     saveas(gcf, imagePath)
    
%     Plot an ovelayed cylinder to the center of the checkerboards in the image.
    plotCylinder(imageData(ii), K, k1, k2, [360/2 360/2], 30, 180);
%     Save the images.
%     imagePath = fullfile("grafici", "Figure 10 image " + num2str(ii) + ".png");
%     saveas(gcf, imagePath)
    
%     Plot the images with their reprojected, rectified and detected points and
%     display the values of all the found parameters and the reprojection error on
%     the image.
    visualizeResults(imageData(ii), calObjMeasures, K, k1, k2,...
        imageData(ii).CheckerboardPoints);
%     Save the images.
%     imagePath = fullfile("grafici", "Figure 11 image " + num2str(ii) + ".png");
%     saveas(gcf, imagePath)
end

    
