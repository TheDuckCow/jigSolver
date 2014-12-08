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
#import <vector>

using namespace cv;

struct ResultMatch {
    int index;
    double std;
    Point2f centroid;
};

struct MatchDistance {
    double distance;
    Point2d pt;
};

static NSString * exceptionHeader = @"JSVOpenCVSIFT Error";

@implementation JSVOpenCVSIFT

+(void) matchPieces:(NSArray *) pieces withSolution: (UIImage *) solution col: (int) col row:(int) row result:(Mat &) finalResult{
    
    NSArray * solutionArray = [JSVopenCV segmentPiecesFromBackground:solution];
    
    JSVpuzzlePiece * solutionPiece = [self largestPuzzlePieceInPieces:solutionArray];
    
    int solution_cols = solutionPiece.mask.cols;
    int solution_rows = solutionPiece.mask.rows;
    
    //Finding keypoints for Solution image
    vector<KeyPoint> keyPointsSolution;
	Mat descriptorSolution;
    
    [self extractSIFTDescriptors:solutionPiece withKeyPoints:keyPointsSolution descriptor: descriptorSolution];
    
    vector<ResultMatch> results;
    
    for(int i = 0 ; i < pieces.count; i++){
        
        JSVpuzzlePiece * piece = pieces[i];
        
        //Finding keypoints for piece
        vector<KeyPoint> keyPointsPiece;
        Mat descriptorPiece;
        [self extractSIFTDescriptors:piece withKeyPoints:keyPointsPiece descriptor: descriptorPiece];
        
        //Matching keypoints between piece and solution
        vector<DMatch> matches;
        [self findGoodMatchesWithDescriptorPiece:descriptorPiece descriptorSolution:descriptorSolution keyPointsPiece:keyPointsPiece keyPointsSolution:keyPointsSolution matches:matches];
        
        Point2f centroid;
        
        double std = [self computeNormalizedStandDeviationWithMatches:matches keyPointsPiece:keyPointsPiece keyPointsSolution:keyPointsSolution solutionCentroid:centroid];
        
        ResultMatch item;
        
        item.centroid = centroid;
        item.std = std;
        item.index = i;
        results.push_back(item);
    }
    
    sort(results.begin(), results.end(), compareResultMatch);
    
    double piece_width = (double) solution_cols / col;
    double piece_height = (double) solution_rows / row;
    
    finalResult = Mat(row, col, CV_8SC1, -1);
    
    
    NSLog(@"From least distance to highest distance:");
    for (int i = 0; i < results.size(); i ++ ){
        ResultMatch item = results[i];
        double x = item.centroid.x / piece_width;
        double y = item.centroid.y / piece_height;
        
        if( finalResult.at<char>((int) x, (int)y) == -1){
            
            finalResult.at<char>(x,y) = item.index;
        } else {
            
            //Find free neighbors
            vector <MatchDistance> neighbors;
            for (int j = (int) x - 1; j <= x + 1; j++) {
                for (int k = (int) y - 1; k <= y + 1; k++) {
                    if (j >= 0 && k >= 0 && j < finalResult.cols && k < finalResult.rows && finalResult.at<char>(j,k) == -1) {
                        MatchDistance matchDistance;
                        matchDistance.pt = Point2d(j,k);
                        matchDistance.distance = sqrt( (j - x) * (j - x) + (k - x) * (k - x));
                        neighbors.push_back(matchDistance);
                    }
                }
            }
            nth_element(neighbors.begin(), neighbors.begin(), neighbors.end(), compareNeighbor);
            
            if (neighbors.size() != 0){
                MatchDistance closest  = neighbors[0];
                finalResult.at<char>(closest.pt.x, closest.pt.y) = item.index;
            }
        }
        
//        printf("%d %d\n", (int)y, (int)x);
//        for(int i = 0 ; i < finalResult.rows; i ++ ) {
//            for(int j =0; j < finalResult.cols; j++ ){
//                printf("%d ", finalResult.at<char>(i, j));
//            }
//            printf("\n");
//        }
    }

    //Finding good matches
//    Mat img_matches;
//    Mat img1, img2;
//    cvtColor(piece.originalImage, img1, CV_BGRA2BGR);
//    cvtColor(solutionPiece.originalImage, img2, CV_BGRA2BGR);

//    drawMatches(img1, keyPointsPiece, img2, keyPointsSolution, matches, img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );
//    drawMatches(piece.originalImage, keyPointsPiece, solutionPiece.originalImage, keyPointsSolution, matches, img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
//    drawMatches(img1, keyPointsPiece, img2, keyPointsSolution, matches, img_matches, Scalar(0,0,0), Scalar::all(-1), vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
//    drawMatches(piece.originalImage, keyPointsPiece, solutionPiece.originalImage, keyPointsSolution, matches, img_matches, Scalar::all(-1), Scalar::all(-1), vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
//    return MatToUIImage(img_matches.clone());
}
bool compareNeighbor(const MatchDistance & a, const MatchDistance & b){
    return a.distance < b.distance;
}

bool compareResultMatch(const ResultMatch & a, const ResultMatch & b){
    return a.std < b.std;
}


+ (void) extractSIFTDescriptors: (JSVpuzzlePiece *) puzzle withKeyPoints: (vector<KeyPoint> &) keypoints descriptor: (Mat &) descriptors {
    //Referencing from lab
    SiftFeatureDetector detector(0, 1);
    SiftDescriptorExtractor extractor (10.0);
    Mat beforeDescriptors;
    detector.detect(puzzle.originalImage, keypoints);
    extractor.compute(puzzle.originalImage, keypoints, beforeDescriptors);
    
    descriptors = Mat();
    
    //Removing edges
    vector<int> index_to_remove;
    for (int i = 0 ; i < keypoints.size(); i++) {
            if (pointPolygonTest(puzzle.contour, keypoints[i].pt, true) <= 30){
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


+ (void) findGoodMatchesWithDescriptorPiece:(Mat &) descriptorPiece descriptorSolution: (Mat &) descriptorSolution keyPointsPiece: (vector<KeyPoint> &) keyPointPiece keyPointsSolution: (vector<KeyPoint> &) keyPointSolution matches:(vector<DMatch> &) final_matches{
    
    FlannBasedMatcher matcher;
    vector<DMatch> matches;
    matcher.match(descriptorPiece, descriptorSolution, matches);
    
    [self filterBestDistanceWithMatches:matches bestNum:100];
    
    
    [self filterBasedOnOrientations:matches keyPointsPiece:keyPointPiece keyPointsSolution:keyPointSolution];
    
    [self filterLocationOutliers:matches keyPointsPiece:keyPointPiece keyPointsSolution:keyPointSolution];
    
    final_matches = matches;
}

+ (double) computeNormalizedStandDeviationWithMatches:(vector<DMatch> &) matches keyPointsPiece: (vector<KeyPoint> &) keyPointPiece keyPointsSolution: (vector<KeyPoint> &) keyPointSolutionvector solutionCentroid: (Point2f &) solutionCentroid{
    
    vector<Point2f> piecePoints, solutionPoints;
    
    for(int i= 0; i < matches.size(); i++) {
        piecePoints.push_back(keyPointPiece[matches[i].queryIdx].pt);
        solutionPoints.push_back(keyPointSolutionvector[matches[i].trainIdx].pt);
    }
    Point2f trash;

    double stdPiece = [self computeStandardDeviationWithPoints:piecePoints centroid:trash];
    double stdSolution = [self computeStandardDeviationWithPoints:solutionPoints centroid:solutionCentroid];
    
    return stdSolution / stdPiece;
}


+ (double) computeStandardDeviationWithPoints:(vector<Point2f> &) points centroid: (Point2f &) centroid{
    double result = 0;
    double mean_x = 0, mean_y = 0;
    
    for (int i = 0; i < points.size(); i++) {
        mean_x += points[i].x;
        mean_y += points[i].y;
    }
    
    mean_x /= points.size();
    mean_y /= points.size();
    
    centroid.x = mean_x;
    centroid.y = mean_y;
    
    for (int i = 0; i < points.size(); i++){
        result += ((points[i].x - mean_x) * (points[i].x - mean_x) + (points[i].y - mean_y) * (points[i].y - mean_y));
    }
    result /= points.size();
    result = sqrt(result);
    
    return result;
}

+(void) filterBestDistanceWithMatches:(vector<DMatch> &) matches bestNum: (int) top_num {
    vector<int> index_to_remove;
    vector <float> distances;
    for (int i = 0; i < matches.size(); i++) {
        distances.push_back(matches[i].distance);
    }
    
    if (distances.size() > top_num) {
        nth_element(distances.begin(), distances.begin() + top_num, distances.end());
        
        float max_distance = distances[top_num];
        
        for (int i = 0; i < matches.size(); i++) {
            if (matches[i].distance > max_distance) {
                index_to_remove.push_back(i);
            }
        }
    }
    removeIndexFromVector(matches, index_to_remove);
}

+(void) filterLocationOutliers: (vector<DMatch> &) matches keyPointsPiece: (vector<KeyPoint> &) keyPointPiece keyPointsSolution: (vector<KeyPoint> &) keyPointSolution{
    
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
    float scale = 1.5;
    
    float inter_quartile_x = second_quartile_x - first_quartile_x;
    float inter_quartile_y = second_quartile_y - first_quartile_y;
    float max_x = median_x + scale * inter_quartile_x;
    float min_x = median_x - scale * inter_quartile_x;
    float max_y = median_y + scale * inter_quartile_y;
    float min_y = median_y - scale * inter_quartile_y;
    
    vector<int> index_to_remove;
    for (int i = 0; i < matches.size(); i ++) {
        Point2f point = keyPointSolution[matches[i].trainIdx].pt;
        float x = point.x;
        float y = point.y;
        if (!(x <= max_x && x >= min_x && y <= max_y && y >= min_y)) {
            index_to_remove.push_back(i);
        }
    }
    
    removeIndexFromVector(matches, index_to_remove);
}


+(void) filterBasedOnOrientations: (vector<DMatch> &) matches keyPointsPiece: (vector<KeyPoint> &) keyPointPiece keyPointsSolution: (vector<KeyPoint> &) keyPointSolution{
    
    const double threshold = 20.0 / 180 * M_PI;
    vector<double> averages;
    vector<int> toBeDeleted;
    
    double totalAverage = 0;
    for(int i = 0; i < matches.size(); i++ ) {
        Point2f originalPointSource = keyPointPiece[matches[i].queryIdx].pt;
        Point2f solutionPointSource = keyPointSolution[matches[i].trainIdx].pt;
        double angleDiffAverage = 0;
        for (int j = 0; j < matches.size(); j++) {
            if (i == j)
                continue;
            Point2f originalPointDest = keyPointPiece[matches[j].queryIdx].pt;
            Point2f solutionPointDest = keyPointSolution[matches[j].trainIdx].pt;
            
            double deltaXOriginal = originalPointDest.x - originalPointSource.x;
            double deltaYOriginal = originalPointDest.y - originalPointSource.y;
            double angleOriginal = atan2(deltaYOriginal, deltaXOriginal);
            
            double deltaXSolution = solutionPointDest.x - solutionPointSource.x;
            double deltaYSolution = solutionPointDest.y - solutionPointSource.y;
            double angleSolution = atan2(deltaYSolution, deltaXSolution);
            
            double angleDiff = angleSolution - angleOriginal;
            angleDiff += (angleDiff > 180) ? -360 : (angleDiff < -180) ? 360 : 0;
            angleDiffAverage += angleDiff;
        }
        
        angleDiffAverage /= matches.size() - 1;
        totalAverage += angleDiffAverage;
        averages.push_back(angleDiffAverage);
    }
    totalAverage /= matches.size();
    
    for(int i = 0; i < averages.size(); i++ ) {
        if (fabs(averages[i] - totalAverage) > threshold) {
            toBeDeleted.push_back(i);
        }
    }
    removeIndexFromVector(matches, toBeDeleted);
}

template<typename T>
void removeIndexFromVector(vector<T> & array, vector<int> & indeces){
        sort(indeces.begin(), indeces.end(), std::greater<int>());
        //Removing points with too far match distance
        for(int i =0; i < indeces.size(); i++) {
            array.erase(array.begin() + indeces[i]);
        }
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

+(void) combineImageLeftRight:(Mat &) left right: (Mat &) right result:(Mat &) result{
    result = Mat:: zeros(max(left.rows, right.rows), left.cols + right.cols, left.type());
    for (int i = 0; i < result.cols; i++) {
        if (i < left.cols) {
            for(int j = 0; j < result.rows; j++) {
                if (j < left.rows) {
                    result.at<Vec4b>(j, i) = left.at<Vec4b>(j, i);
                }
            }
        } else {
            for(int j = 0; j < result.rows; j++) {
                if (j < right.rows) {
                    result.at<Vec4b>(j, i) = right.at<Vec4b>(j,  i - left.cols);
                }
            }
        }
    }
}


+(void) combineImageTopBottm: (Mat &) top bottom: (Mat &) bottom result:(Mat &) result{
    result = Mat:: zeros(top.rows + bottom.rows, max(top.cols, bottom.cols), top.type());
    for (int i = 0; i < result.rows; i++) {
        if (i < top.rows) {
            for(int j = 0; j < result.cols; j++) {
                if (j < top.cols) {
                    result.at<Vec4b>(i, j) = top.at<Vec4b>(i, j);
                }
            }
        } else {
            for(int j = 0; j < result.cols; j++) {
                if (j < bottom.cols) {
                    result.at<Vec4b>(i, j) = bottom.at<Vec4b>(i - top.rows, j);
                }
            }
        }
    }
}



+(void) combineResul:(NSArray *) segmentedPieces withFinalMatches:(cv::Mat &) solutionMatch result:(cv::Mat &) finalResult{
    
    for(int i = 0 ; i < solutionMatch.rows; i ++ ) {
        Mat rowResult;
        for(int j =0; j < solutionMatch.cols; j++ ){

            int index = solutionMatch.at<char>(j, i);
            if (index == -1) continue;
            
            JSVpuzzlePiece * image = segmentedPieces[index];
            Mat temp = image.originalImage.clone();
            if (rowResult.empty()) {
                rowResult = temp.clone();
                NSLog(@"Empty");
        
            } else {
                Mat clone = rowResult.clone();
                [JSVOpenCVSIFT combineImageLeftRight:clone right:temp result:rowResult];
                NSLog(@"not empty");
            }
        }
        if (finalResult.empty()) {
            finalResult = rowResult;
        } else {
            Mat clone = finalResult.clone();
            [JSVOpenCVSIFT combineImageTopBottm:clone bottom:rowResult result:finalResult];
        }
        printf("\n");
    }
    
}

@end
