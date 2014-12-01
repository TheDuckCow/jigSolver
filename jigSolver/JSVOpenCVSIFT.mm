//
//  JSVOpenCVSIFT.m
//  jigSolver
//
//  Created by Timothy Chong on 11/30/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVOpenCVSIFT.h"
#import "JSVopenCV.h"
#import "JSVpuzzlePiece.h"

#import <opencv2/opencv.hpp>
#import <opencv2/nonfree/features2d.hpp>
#import <algorithm>
//#import <opencv2/imgproc/imgproc.hpp>
//#import <opencv2/calib3d/calib3d.hpp>
//#import <opencv2/nonfree/nonfree.hpp>
//#import <opencv2/highgui/highgui.hpp>
//#import <opencv2/core/core.hpp>


using namespace cv;


static NSString * exceptionHeader = @"JSVOpenCVSIFT Error";

@implementation JSVOpenCVSIFT

+(UIImage *) matchPieceWithSolution:(JSVpuzzlePiece *) piece withSolution: (UIImage *) solution{
    
    NSArray * solutionArray = [JSVopenCV segmentPiecesFromBackground:solution];
    
    JSVpuzzlePiece * solutionPiece = [self largestPuzzlePieceInPieces:solutionArray];
    
    vector<KeyPoint> keyPointsPiece, keyPointsSolution;
	Mat descriptorPiece, descriptorSolution;
    
    [self extractSIFTDescriptors:piece withKeyPoints:keyPointsPiece descriptor: descriptorPiece];
    [self extractSIFTDescriptors:solutionPiece withKeyPoints:keyPointsSolution descriptor: descriptorSolution];
    
    //Finding good matches
    vector<Point2f> goodMatchPiece, goodMatchSolution;
    vector<DMatch> matches;
    
    [self findGoodMatchesWithDescriptorPiece:descriptorPiece descriptorSolution:descriptorSolution keyPointsPiece:keyPointsPiece keyPointsSolution:keyPointsSolution goodMatchPiece:goodMatchPiece goodMatchSolution:goodMatchSolution matches:matches];

    Mat img_matches;

    drawMatches(piece.originalImage, keyPointsPiece, solutionPiece.originalImage, keyPointsSolution, matches, img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(), DrawMatchesFlags::DEFAULT );
    
    
    return MatToUIImage(piece.originalImage.clone());
}


+ (void) extractSIFTDescriptors: (JSVpuzzlePiece *) puzzle withKeyPoints: (vector<KeyPoint> &) keypoints descriptor: (Mat &) descriptors {
    //Referencing from lab
    SiftFeatureDetector detector(0.05, 5.0);
    SiftDescriptorExtractor extractor (3.0);
    Mat beforeDescriptors;
    detector.detect(puzzle.originalImage, keypoints);
    extractor.compute(puzzle.originalImage, keypoints, beforeDescriptors);
    
    descriptors = beforeDescriptors;
    return;
    
    descriptors = Mat();
//    double rows = puzzle.mask.rows;
//    double cols = puzzle.mask.cols;
//    int x = -1;
//    int y = -1;
    
    //Removing edges
    vector<int> index_to_remove;
    for (int i = 0 ; i < keypoints.size(); i++) {
//        if (x < cols && y < rows) {
//            uchar color = puzzle.mask.at<Vec3b>(y,x)[0];
//            if (color == 0 || (x < cols * 0.05) || (x > cols * 0.95) || (y < rows * 0.05) || (y > rows * 0.95)) {
        NSLog(@"%f", pointPolygonTest(puzzle.contour, keypoints[i].pt, true));
            if (pointPolygonTest(puzzle.contour, keypoints[i].pt, false) <= 0){
                index_to_remove.push_back(i);
            }else {
                descriptors.push_back(beforeDescriptors.row(i));
            }
    }
    
    sort(index_to_remove.begin(), index_to_remove.end(), std::greater<int>());
    
    for(int i =0; i < index_to_remove.size(); i++) {
        keypoints.erase(keypoints.begin() + index_to_remove[i]);
    }
}


+ (void) findGoodMatchesWithDescriptorPiece:(Mat &) descriptorPiece descriptorSolution: (Mat &) descriptorSolution keyPointsPiece: (vector<KeyPoint> &) keyPointPiece keyPointsSolution: (vector<KeyPoint> &) keyPointSolution goodMatchPiece: (vector<Point2f> &) goodMatchPiece goodMatchSolution: (vector<Point2f> &) goodMatchSolution matches:(vector<DMatch> &) final_matches{
    
    FlannBasedMatcher matcher;
    vector<DMatch> matches;
    matcher.match(descriptorPiece, descriptorSolution, matches);
    
    float min_dist = 100;
    
    for (int i = 0; i < matches.size(); i++) {
        float dist = matches[i].distance;
        if (dist < min_dist) {
            min_dist = dist;
        }
    }
    
    //Filtering based on 3 times the match distance
    vector<DMatch> matches_location_filtered;
    vector<int> index_to_remove;
    min_dist = (3 * min_dist > 0.02) ? 3 * min_dist : 0.02;
    
    for (int i = 0; i < matches.size(); i++) {
        if (matches[i].distance > min_dist) {
            index_to_remove.push_back(i);
        }
    }
    
    sort(index_to_remove.begin(), index_to_remove.end(), std::greater<int>());
    
    //Removing points with too far match distance
    for(int i =0; i < index_to_remove.size(); i++) {
        matches.erase(matches.begin() + index_to_remove[i]);
    }
    
    
    //Calculating centroids and statistics for outlier
    vector<float> x, y;
    for (int i = 0; i < matches.size(); i ++) {
        x.push_back(keyPointSolution[matches[i].trainIdx].pt.x);
        y.push_back(keyPointSolution[matches[i].trainIdx].pt.y);
    }
    
    sort(x.begin(), x.end());
    sort(y.begin(), y.end());
    
    float median_x = -1, first_quartile_x = -1, second_quartile_x = -1;
    float median_y = -1, first_quartile_y = -1, second_quartile_y = -1;
    int size = (int) matches.size();
    if (size % 2) {
        // Odd
        median_x = x[size / 2];
        first_quartile_x = (x[size / 4] + x[size / 4 + 1]) / 2;
        second_quartile_x = (x[size / 4 + size / 2] + x[size / 4 + size / 2 + 1]) / 2;
        median_y = y[size / 2];
        first_quartile_y = (y[size / 4] + y[size / 4 + 1]) / 2;
        second_quartile_y = (y[size / 4 + size / 2] + y[size / 4 + size / 2 + 1]) / 2;
    } else {
        // Even
        median_x = (x[size / 2] + x[size / 2 + 1]) / 2;
        first_quartile_x = x[size / 4];
        second_quartile_x = x[size / 2 + size / 4];
        median_y = (y[size / 2] + y[size / 2 + 1]) / 2;
        first_quartile_y = y[size / 4];
        second_quartile_y = y[size / 2 + size / 4];
    }
    
    float inter_quartile_x = second_quartile_x - first_quartile_x;
    float inter_quartile_y = second_quartile_y - first_quartile_y;
    float max_x = median_x + 1.5 * inter_quartile_x;
    float min_x = median_x - 1.5 * inter_quartile_x;
    float max_y = median_y + 1.5 * inter_quartile_y;
    float min_y = median_y - 1.5 * inter_quartile_y;
    
    for (int i = 0; i < matches.size(); i ++) {
        Point2f point = keyPointSolution[matches[i].trainIdx].pt;
        float x = point.x;
        float y = point.y;
        if (x <= max_x && x >= min_x && y <= max_y && y >= min_y) {
            matches_location_filtered.push_back(matches[i]);
        }
    }
    
    //Returning the results
//    for (int i = 0; i < matches_location_filtered.size(); i ++) {
    for (int i = 0; i < matches_location_filtered.size(); i ++) {
        goodMatchPiece.push_back(keyPointPiece[matches_location_filtered[i].queryIdx].pt);
        goodMatchSolution.push_back(keyPointSolution[matches_location_filtered[i].trainIdx].pt);
    }
    
    final_matches = matches_location_filtered;
}



+(JSVpuzzlePiece *) largestPuzzlePieceInPieces:(NSArray *) pieces {
    
    JSVpuzzlePiece * result;
    if (pieces.count == 0)
        [NSException raise:exceptionHeader format:@"largestPuzzlePieces can't be found in empty pieces array"];
        
    if (pieces.count == 1)
        return pieces[0];
    
    //If more than one solution is found.
    //Take the one with the greatest area.
    
    int area = 0;
    for (JSVpuzzlePiece * piece in pieces) {
        Mat mask = piece.mask;
        int currentArea = mask.rows * mask.cols;
        if (currentArea > area) {
            area = currentArea;
            result = piece;
        }
    }
    
    if (result) return result;
    
    [NSException raise:exceptionHeader format:@"largestPuzzle Piece can't find a result."];
    return nil;
}




@end
