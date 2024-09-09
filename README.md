[![matlab](https://img.shields.io/badge/matlab-2021a-3776AB.svg?style=flat&logo=matlab&logoColor=white)](https://it.mathworks.com/)

# Automatic Camera Calibration and Radial Distortion Compensation

This matlab script was developed as a project for an exam on Computer Vision and Pattern Recognition. 
It provides an estimate of the intrinsic and extrinsic parameters of a camera using homographies. Furthermore, it is able to compensate for the radial distortion of the lens. 

<br/>

## Overview
The method used to get an estimate of the characteristics of the camera is based on Zhang's camera calibration algorithm. 
This algorithm uses a collection of at least three pictures of a checkerboard of known size. 
Thanks to the correspondances between the points in the images and in the checkerboards, it estimates the parameters through an estimate of the homographies. 

Using the computed parameters, an estimate of the radial distortion can be obtained through a simple model of the distortion and the reprojection error. 
From this estimate, the radial distortion can be accounted for and the image rectified.

Further details on how the method works are illustrated in the [project report](https://github.com/AlessandroViol/CameraCalibrator/blob/main/Computer%20Vision%20Project%20Alessandro%20Viol%2C%20Federica%20Azzalini.pdf)

<br/>

## About the Project
Our work consisted in the development of a script that, given an appropriate set of already acquired black and white images of a checkerboard of known size computes the camera parameters. 
The points on the checkerboard were detected automatically using the detectCheckerboardPoints function from matlab's computer vision toolbox. No other feature from matlab image processing tools was used.

The parameters are then refined using an iterative method by considering the reprojection error. 
In a similar way, we used the reprojection error to estimate a simple radial distortion effect due to the lens.
This estimate is also refined iteratively and was used to rectify the image.  

Apart from measuring the low final reprojection error, the good quality of the results could be visually verifiable by projecting various solids on the checkerboard.

![Solid Overlay](https://github.com/AlessandroViol/CameraCalibrator/blob/main/Code/grafici/Figure%2010%20image%202.png)

<br/>

## Features
Using this software the user can calibrate his camera, view the parameters and rectify images captured with the calibrated camera. 
It also allow the user to project solids onto the image and visualize the position of reference objects with respect to the camera.

![Checkerboard wrt. camera](https://github.com/AlessandroViol/CameraCalibrator/blob/main/Code/grafici/visualize.jpg)

<br/>

## Authors

- Alessandro Viol: [@AlessandrViol](https://www.github.com/AlessandroViol)
- Federica Azzalini: [@F1397](https://github.com/F1397)

<br/>

## Reference

### [Zhang’s Camera Calibration Algorithm: In-Depth Tutorial And Implementation](https://www.researchgate.net/publication/303233579_Zhang's_Camera_Calibration_Algorithm_In-Depth_Tutorial_and_Implementation)

Burger, Wilhelm.
