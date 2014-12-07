//
//  takePictures.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 12/6/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "takePictures.h"

@interface takePictures ()
@property (strong, nonatomic) IBOutlet UIImageView *solutionImg;
@property (strong, nonatomic) IBOutlet UIImageView *piecesImg;
@property int state;

- (IBAction)navBack:(id)sender;
- (IBAction)takeSolPic:(id)sender;
- (IBAction)takePiecesPic:(id)sender;
- (IBAction)useIncluded:(id)sender;
- (IBAction)navNext:(id)sender;

@end

@implementation takePictures

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.state = 0; // shouldn't be necessary
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)navBack:(id)sender {
    //NSLog(@"Go back");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)takeSolPic:(id)sender {
    self.state = 0;
    [self showCameraUI];
}

- (IBAction)takePiecesPic:(id)sender {
    self.state = 1;
    [self showCameraUI];
}

- (IBAction)useIncluded:(id)sender {
    
    // DEBUG for setting the images for each thing based on built in, faster debug
    self.solutionImg.image = [UIImage imageNamed:@"IMG_2774.png"];
    [JSVsingleton sharedObj].piecesImg = [UIImage imageNamed:@"IMG_2774.png"];
    
    self.piecesImg.image = [UIImage imageNamed:@"IMG_2775.JPG"];
    //self.piecesImg.image = [UIImage imageNamed:@"IMG_2785.png"];
    [JSVsingleton sharedObj].piecesImg = [UIImage imageNamed:@"IMG_2775.JPG"];
    
}

- (IBAction)navNext:(id)sender {
    
    if (self.solutionImg.image != nil && self.piecesImg.image != nil){
        UIViewController *nextView =[self.storyboard instantiateViewControllerWithIdentifier:@"selectPictures"];
        //[self presentModalViewController:nextView animated:YES];
        //[self presentViewController:nextView animated:YES completion:nil];
        [self.navigationController pushViewController:nextView animated:YES];
    }
}


- (IBAction) showCameraUI {
    BOOL response = [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
    NSLog(@"has camera: %i",response);
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
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    //[controller presentModalViewController: cameraUI animated: YES];
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
        
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        
        if (self.state==0){
            self.solutionImg.image = originalImage;
            self.state=1;
            
            // save image to singleton
            [JSVsingleton sharedObj].solutionImg = originalImage;
            
        }
        else{
            //self.imgView.image = originalImage;
            self.piecesImg.image = originalImage;
            self.state = 0;
            
            // sage image to singleton
            [JSVsingleton sharedObj].piecesImg = originalImage;
            
            
            
        }
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



@end
