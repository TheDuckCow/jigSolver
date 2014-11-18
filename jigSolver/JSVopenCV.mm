//
//  JSVopenCV.mm
//  jigSolver
//

#import "JSVopenCV.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
using namespace cv;

@implementation JSVopenCV


//////////////////
// This function is the main processing call,
// takes input of scrambled pieces and original intact image
// outputs the moves to make
+ (UIImage *)solvePuzzle:(UIImage *)input withOriginal: (UIImage *) original{
    
    // First, segment out the background and the individual pieces
    // keep two images for each puzzle piece found, origal (color etc) & binary mask
    
    Mat inputM;
    Mat sansBackground;
    UIImageToMat(input,inputM);
    
    
    [self segmentFromBackground:inputM withDst:sansBackground];
    
    // now break the segmented background into multiple pieces
    
    //Vector<Mat> piecesColor;
    //Vector<Mat> piecesMask;
    //Vector<Attributes> piecesAttr; // object storing attribtues for each piece; area color % etc.
    
    // now somehow magically combine them
    
    // return the result
    return MatToUIImage(sansBackground);
}


// test bench program, servers no final purpose
+ (UIImage *) testFunction: (UIImage *) input{
    //Load image with face
    Mat faceImage;
    UIImageToMat(input, faceImage);
    NSLog(@"channels: %i",faceImage.channels());
    GaussianBlur(faceImage, faceImage, cv::Size(5, 5), 1.2, 1.2);
    Mat greyMat;
    cvtColor(faceImage, greyMat, CV_BGR2GRAY);
    
    Mat binary = Mat::zeros(faceImage.size(), CV_8UC1);
    for (int x=0; x<binary.cols; x++){
        for (int y=0; y< binary.rows; y++){
            // IT NEEDED TO BE Vec4b BECAUSE IT IS READ IN AS FOUR CHANNELS
            if (faceImage.at<Vec4b>(y,x)[0] > 200){
                binary.at<uchar>(y,x) = 255;
            }
        }
    }
    UIImage *output = MatToUIImage(binary);
    return output;
}


// #####################################################################################
// PRIVATE METHODS
// #####################################################################################


+ (void) segmentFromBackground: (Mat &) src withDst: (Mat &) dst{
    
    // at first assume the background is one consistent color
    // later, we can try to detect this color.
    
    // alternatively, we could floodfill the background and invert it
    
    //src = 255-src;
    dst = Mat::zeros(src.size(), CV_8UC1);
    Mat gray;
    cvtColor(src,gray,CV_RGB2GRAY);
    
    
    //GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
    blur(gray, gray, cv::Size(5,5));
    threshold(gray,dst,60,255,THRESH_BINARY);
    blur(dst, dst, cv::Size(5,5));
    
    // second to last = neighborhood search, last number .. just leave it 0
    //adaptiveThreshold(gray, dst, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, 51, -10);
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    findContours(gray,contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
    
    
    // now find the largest contour.. assumed to be the background
    NSLog(@"Contours: %lu", contours.size());
    Mat contourOut = Mat::zeros(dst.size(),CV_8UC1);
    for (int i=0; i< 3; i++){
        //drawContours(contourOut, contours, i, 200, CV_FILLED, 8, hierarchy);
    }
    drawContours(contourOut, contours, 0, 200, CV_FILLED, 8, hierarchy);
    
    //dst = contourOut.clone();
    
    
    //dst = Mat::zeros(src.size(), CV_8UC1);
    
}


@end
