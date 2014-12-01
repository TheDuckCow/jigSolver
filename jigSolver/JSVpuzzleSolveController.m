//
//  JSVpuzzleSolveController.m
//  jigSolver
//
//  Created by Patrick W. Crawford on 11/30/14.
//  Copyright (c) 2014 tDC. All rights reserved.
//

#import "JSVpuzzleSolveController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JSVpuzzleSolveController ()
- (IBAction)useCamera:(id)sender;
@property BOOL newMedia;
@end

@implementation JSVpuzzleSolveController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // imgView is the main UIimage 
    
    
}


////////////////// live camera feed stuff...

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
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


