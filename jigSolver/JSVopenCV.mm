//
//  JSVopenCV.mm
//  jigSolver
//

#import "JSVopenCV.h"
#import "opencv2/highgui/ios.h"
#import <opencv2/opencv.hpp>
#import "JSVpuzzlePiece.h"
#import "JSVsingleton.h"
#import "JSVOpenCVSIFT.h"
using namespace cv;
using namespace std;

@implementation JSVopenCV



// #####################################################################################
// PUBLIC METHODS
// #####################################################################################


//////////////////
// This function is the main processing call,
// takes input of scrambled pieces and original intact image
// outputs the moves to make
+ (UIImage *)solvePuzzle:(UIImage *)input withOriginal: (UIImage *) original{
    
    // First, segment out the background and the individual pieces
    Mat inputM;
    Mat sansBackground;
    UIImageToMat(input,inputM);
    UIImageToMat(input,sansBackground);
    NSMutableArray *puzzlePieces = [[NSMutableArray alloc]init];
    
    
    // test (yes, the below works as it should....)
    //JSVpuzzlePiece *test = [[JSVpuzzlePiece alloc] init];
    //[puzzlePieces addObject: test];
    
    
    // should segment and create individual puzzlePiece objects for each puzle piece
    
    [self segmentPiecesFromBackground:inputM withPieces:puzzlePieces withDst: sansBackground];
    JSVpuzzlePiece *piece = puzzlePieces[0];
    sansBackground = piece.originalImage.clone();
    
    
    // now for each of these found puzzle pieces, create the edge objects/information
    // and figure out their geometry
    //sansBackground = Mat::zeros(inputM.size(), CV_8U);
    for (int i=0; i< [puzzlePieces count]; i++){
//    for (int i=0; i<1; i++){
        NSLog(@"Output puzzle peice #%i",i);
        // draw the contour from here...
        
    }
     
    
    // now do whatever it is to "solve" the puzzle, ie template matching using the innerRectable Mat
    // of each puzzle piece, and verifying the geometry matches etc.
    
    // return the result
    return MatToUIImage(sansBackground);
}


// test bench program, servers no final purpose, change/delete as desired
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

// not currently used...
+(NSMutableArray *) arrayOfPieces: (NSMutableArray *) pieces{
    
    NSMutableArray *output = [[NSMutableArray alloc]init];
    for (int i=0; i< [pieces count]; i++){
        JSVpuzzlePiece *piece = pieces[i];
        [output addObject:MatToUIImage(piece.originalImage)];
    }
    
    return output;
}

+ (NSArray *) segmentPiecesFromBackground: (UIImage *) input isSolution:(BOOL)isSolution{
    
    Mat inputM;
    Mat sansBackground;
    UIImageToMat(input,inputM);
    //[self segmentPiecesFromBackground:inputM withPieces:puzzlePieces withDst: sansBackground];
    [self createPiecesFromImage:input isSolution:isSolution];
    
    if (isSolution) {
        NSArray * temp = @[[JSVsingleton sharedObj].solution];
        return temp;
    }else {
        NSArray *tmp = [[NSArray alloc] initWithArray:[JSVsingleton sharedObj].pieces];
        return tmp;
        
    }

}


// #####################################################################################
// PRIVATE METHODS
// #####################################################################################

// call for in selectPieces, raw segmenting the background
+ (UIImage *) createPiecesFromImage: (UIImage *) src isSolution:(BOOL) isSolution{
    
    Mat srcMat;
    Mat dst;
    UIImageToMat(src,srcMat);
    
    //pre-segmentation
    Mat gray;
    cvtColor(srcMat,gray,CV_RGB2GRAY);
    blur(gray, gray, cv::Size(5,5));
    
    // dynamic threshold of some kind?
    Mat tmp;
    // attempting dynamic thresholding.. it's worse actually!
    
    // OLD WAY OF THRESHOLD
    threshold(gray,dst,65,255,THRESH_BINARY);
    //threshold(gray,dst,10,255,CV_THRESH_BINARY | CV_THRESH_OTSU);
    //adaptiveThreshold(gray, dst,255,ADAPTIVE_THRESH_GAUSSIAN_C,THRESH_BINARY, 37, -4);
    blur(dst, dst, cv::Size(5,5));
    
    // dilate to fill any "holes"
    int erosion_size = 2;
    Mat element = getStructuringElement( MORPH_RECT,
                                        cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                        cv::Point( erosion_size, erosion_size ) );
    dilate(dst, dst, element, cv::Point(-1, -1), 1);
    
    
    ///////// NEW custom method of segmentation
    // doesn't really work all that well... sigh.
    Mat tmp2;
    cvtColor(srcMat,tmp2,CV_RGB2HSV);
    dst = Mat::zeros(tmp2.size(),CV_8UC1);
    for (int x=0; x< dst.rows; x++){
        for (int y=0; y< dst.cols; y++){
            Vec3b col = tmp2.at<Vec3b>(x,y);
            //if (col[2] > 60 && col[1] > 20){
            if (col[2] > 60){
                dst.at<uchar>(x,y) = 255;
            }
        }
    }
    erode(dst, dst, element, cv::Point(-1, -1), 1);
    dilate(dst, dst, element, cv::Point(-1, -1), 2);
    
    ///////// NEW custom method of segmentation </end>
    
    
    // Contours part
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    findContours(dst,contours, hierarchy, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
    
    NSMutableArray * solutionContours;
    // before finding pieces, remove all from the singleton
    if (!isSolution) {
        [[JSVsingleton sharedObj].pieces removeAllObjects];
    } else {
        solutionContours = [NSMutableArray new];
    }
    
    // now find the largest contour.. assumed to be the background
    Mat contourOut = Mat::zeros(dst.size(),CV_8UC1);
    for (int i=0; i< contours.size(); i++){
        int area = contourArea(contours[i]);
        // this seems SUPER arbitrary.
        //if (area >500000){
        if (area >50000){
            drawContours(contourOut, contours, i, 255, CV_FILLED, 8, hierarchy);
            
            // CREATE the puzzle piece. long winded process.
            JSVpuzzlePiece *piece = [[JSVpuzzlePiece alloc] init];
            
            // now HERE crop the piece down to the bounding box of just the contour filled area,
            // find the smallest and largest x and y values in the contour list of points
            int x_lo = contours[i][0].x;
            int x_hi = contours[i][0].x;
            int y_lo = contours[i][0].y;
            int y_hi = contours[i][0].y;
            
            for (int j=0; j< contours[i].size(); j++){
                //NSLog(@"x:%i %i,y: %i %i",x_lo,x_hi,y_lo,y_hi);
                int tmp = contours[i][j].x;
                if (tmp < x_lo){
                    x_lo = tmp;
                }
                else if (tmp > x_hi){
                    x_hi = tmp;
                }
                tmp = contours[i][j].y;
                if (tmp < y_lo){
                    y_lo = tmp;
                }
                else if (tmp > y_hi){
                    y_hi = tmp;
                }
                
            }
            
            //now set the relative offsets
            piece.offset_x = x_lo;
            piece.offset_y = y_lo;
            NSLog(@" OUT PIECE: %i %i",piece.offset_x,piece.offset_y);
            
            // now create the mask and cropped image based on these new points
            piece.mask = Mat::zeros(cv::Size(x_hi-x_lo,y_hi-y_lo),CV_8UC1); // check if off by one??
            
            
            // adjust the mask/image size so it has the correct bounds
            for (int j=0; j<piece.contour.size(); j++){
                piece.contour[j].x -= x_lo;
                piece.contour[j].y -= y_lo;
            }
            
            
            // set the image
            cv::Rect myROI(x_lo, y_lo, x_hi-x_lo, y_hi-y_lo);
            piece.originalImage = srcMat(myROI);
            
            Mat tmp = contourOut.clone();
            piece.mask = tmp(myROI);
            //piece.mask = Mat::zeros(piece.originalImage.size(), CV_8UC1);
            
            // now REDO the contours
            vector<vector<cv::Point>> contoursB;
            vector<Vec4i> hierarchyB;
            
            findContours(piece.mask,contoursB, hierarchyB, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
            
            piece.mask = Mat::zeros(piece.mask.size(), CV_8UC1);
            
            drawContours(piece.mask, contoursB, 0, 255, CV_FILLED, 8, hierarchyB);
            
            // FINAL contours and add piece to array
            piece.contour = contoursB[0];
            
            // initialize the solution locations
            piece.guess_x = -1;
            piece.guess_y = -1;
            
            if (isSolution) {
                [solutionContours addObject:piece];
            } else {
                [[JSVsingleton sharedObj].pieces addObject:piece];
            }
            
        }
    }
    
    if (isSolution){
        
        [JSVsingleton sharedObj].solution = [JSVOpenCVSIFT largestPuzzlePieceInPieces:solutionContours];
    }
    // ultiamtely, should save puzzle peice objects to singleton and have intermediate
    // image shown here
    return MatToUIImage(contourOut);
}



// #####################################################################################
// OLD METHODS
// #####################################################################################


// the OLD method for semgenting pieces, returns/creates list of puzzle piece objects
+ (void) segmentPiecesFromBackground: (Mat &) src withPieces: (NSMutableArray *) puzzleArray withDst: (Mat &) dst{
    
    // at first assume the background is one consistent color
    // later, we can try to detect this color.
    // alternatively, we could floodfill the background and invert it

    dst = Mat::zeros(src.size(), CV_8UC1);
    Mat gray;
    cvtColor(src,gray,CV_RGB2GRAY);
    
    
    //GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
    blur(gray, gray, cv::Size(5,5));
    threshold(gray,dst,60,255,THRESH_BINARY);
    blur(dst, dst, cv::Size(5,5));
    
    int erosion_size = 4;
    Mat element = getStructuringElement( MORPH_RECT,
                                        cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                        cv::Point( erosion_size, erosion_size ) );
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    findContours(dst,contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
    
    
    // now find the largest contour.. assumed to be the background
    NSLog(@"Contours: %lu", contours.size());
    Mat contourOut = Mat::zeros(dst.size(),CV_8UC1);
    for (int i=0; i< contours.size(); i++){
        //drawContours(contourOut, contours, i, 200, CV_F@enuILLED, 8, hierarchy);
        int area = contourArea(contours[i]);
        if (area >100000){
            drawContours(contourOut, contours, i, 255, CV_FILLED, 8, hierarchy);
        }
    }
    dilate(contourOut, contourOut, element, cv::Point(-1, -1), 4);
    // over erode to bring in the boundary
    erode(contourOut, contourOut, element, cv::Point(-1, -1), 5);
    // quick blur before FINAL contours
    blur(contourOut, contourOut, cv::Size(3,3));
    
    
    // final finding of contours, number of contours here = number of pieces
    findContours(contourOut,contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
    
    
    // NOW do the final drawing of contours, should really only hav eindividual pieces contours.
    NSLog(@"Contours final (number of pieces): %lu", contours.size());
    contourOut = Mat::zeros(dst.size(),CV_8UC1);
    for (int i=0; i< contours.size(); i++){
        int area = contourArea(contours[i]);
        if (area >50000){
            drawContours(contourOut, contours, i, 255, CV_FILLED, 8, hierarchy);
        } 
        
        // now create the additional PuzzlePiece objects.
        JSVpuzzlePiece *piece = [[JSVpuzzlePiece alloc] init];
        piece.contour = contours[i];
        [puzzleArray addObject: piece]; // THIS IS THE BAD LINE, something isn't right...
        
        
        // now HERE crop the piece down to the bounding box of just the contour filled area,
        // find the smallest and largest x and y values in the contour list of points
        int x_lo = piece.contour[0].x;
        int x_hi = piece.contour[0].x;
        int y_lo = piece.contour[0].y;
        int y_hi = piece.contour[0].y;
        
        for (int j=0; j< piece.contour.size(); j++){
            
            //NSLog(@"x:%i %i,y: %i %i",x_lo,x_hi,y_lo,y_hi);
            int tmp = piece.contour[j].x;
            if (tmp < x_lo){
                x_lo = tmp;
            }
            else if (tmp > x_hi){
                x_hi = tmp;
            }
            
            tmp = piece.contour[j].y;
            if (tmp < y_lo){
                y_lo = tmp;
            }
            else if (tmp > y_hi){
                y_hi = tmp;
            }
            
        }
        
        
        // now create the mask and cropped image based on these new points
        piece.mask = Mat::zeros(cv::Size(x_hi-x_lo,y_hi-y_lo),CV_8UC1); // check if off by one??
        
        // adjust the mask/image size so it has the correct bounds
        for (int j=0; j<piece.contour.size(); j++){
            piece.contour[j].x -= x_lo;
            piece.contour[j].y -= y_lo;
        }
        
        // set the image
        cv::Rect myROI(x_lo, y_lo, x_hi-x_lo, y_hi-y_lo);
        piece.originalImage = src(myROI);
        piece.mask = contourOut(myROI);
        
        
        // now REDO the contours
        
        vector<vector<cv::Point>> contoursB;
        vector<Vec4i> hierarchyB;
        
        findContours(piece.mask,contoursB, hierarchyB, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
        piece.mask = Mat::zeros(piece.mask.size(), CV_8UC1);
        drawContours(piece.mask, contoursB, 0, 255, CV_FILLED, 8, hierarchyB);
        
        // FINAL contours.
        piece.contour = contoursB[0];
        
        // output for debugging, not actually meant to reaturn mat objects
        dst = piece.originalImage.clone();
        
        // that's it! We set the contour list, cropped image, and mask image for the piece;
        // do the edge calculations and whatnot in another function.
        
        
    }
    
    // OLD output was an image, this is what it would be segmented
    //dst = contourOut.clone(); // would replace output dst image with new threshold
    
}




@end
