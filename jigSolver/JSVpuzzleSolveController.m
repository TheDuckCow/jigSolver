//
//  JSVpuzzleSolveController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/30/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVpuzzleSolveController.h"
#import "JSVopenCV.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JSVpuzzleSolveController ()
- (IBAction)generalButton:(id)sender;
- (IBAction) showCameraUI;
- (IBAction)solveAction:(id)sender;
- (IBAction)backButton:(id)sender;
@property int state;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSOL;
@property (strong, nonatomic) IBOutlet UIImageView * imgViewORIG;
@property (strong, nonatomic) IBOutlet UIImageView * imgView;
@property (strong, nonatomic) IBOutlet UILabel * bottomLabel;
@property (strong, nonatomic) NSString * state1;
@property (strong, nonatomic) NSString * state2;
@property (strong, nonatomic) NSString * state3;
@property (strong, nonatomic) NSString * state4;


@end

@implementation JSVpuzzleSolveController

- (void)viewDidLoad {
    [super viewDidLoad];

    // hard coded string setup.
    self.state1 = @"First, take a picture of the solution (the box image!)";
    self.state2 = @"Now, take a picture of all the puzzle pieces in one view";
    self.state3 = @"Now press solve to see the results";
    self.state4 = @"Results are shown - now you can solve that puzzle or try another set!";
    
    // initially state = 0, need to take picture of background
    self.helpLabel.text = self.state1;
    self.state = 0;
    
    
}

- (IBAction)solve{
    // first check we are in the correct state, ie have both images and solution:
    if (self.state==2){
        
        self.helpLabel.text = self.state4;
        // Solve the puzzle!
        //self.imgView.image =
        self.imgView.image = [JSVopenCV solvePuzzle:self.imgViewORIG.image withOriginal: self.imgViewSOL.image];
        self.state=3;
        
    }
    else{
        NSLog(@"Need both solution and puzzle piece shots");
    }
    
}

// solve the puzzle
- (IBAction)solveAction:(id)sender {
    [self solve];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)generalButton:(id)sender {
    
    if (self.state <= 1){
        [self showCameraUI];
    }
    else if(self.state==2){
        [self solve];
    }
    else if (self.state == 3){
        self.state=2;
        [self showCameraUI];
    }
}

////////////////// live camera feed stuff...



- (IBAction) showCameraUI {
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
}



- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    cameraUI.allowsEditing = NO;

    //cameraUI.cameraCaptureMode // ?
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// repsond to "accept"
// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        //editedImage = (UIImage *) [info objectForKey:
        //                           UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        
        if (self.state==0){
            self.imgViewSOL.image = originalImage;
            self.helpLabel.text = self.state2;
            self.state=1;
            
        }
        else{
            //self.imgView.image = originalImage;
            self.imgViewORIG.image = originalImage;
            self.helpLabel.text = self.state3;
            self.state = 2;
            
            
        }
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//////////////////


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end


