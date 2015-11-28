//
//  ViewController.m
//  MultiImageUploader
//
//  Created by Pawan on 11/22/15.
//  Copyright © 2015 Pawan. All rights reserved.
//

#import "ViewController.h"
#import "ImageUploader/ImageUploader.h"

@interface ViewController () <ImageUploaderDelegate>
- (IBAction)startUploadingImages:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startUploadingImages:(id)sender {
    
    NSArray *allImagesArray = @[[UIImage imageNamed:@"image1"],
                                [UIImage imageNamed:@"image2"],
                                [UIImage imageNamed:@"image2"],
                                [UIImage imageNamed:@"image4"],
                                [UIImage imageNamed:@"image5"],
                                [UIImage imageNamed:@"image6"],
                                [UIImage imageNamed:@"image7"],
                                [UIImage imageNamed:@"image8"],
                                [UIImage imageNamed:@"image9"],
                                [UIImage imageNamed:@"image10"],
                                ];
    
    //
    [[ImageUploader shareImageUploader] uploadToURLWithImages:allImagesArray];
}



@end
