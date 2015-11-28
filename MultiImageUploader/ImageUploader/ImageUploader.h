//
//  ImageUploader.h
//  MultiImageUploader
//
//  Created by Pawan on 11/28/15.
//  Copyright © 2015 Pawan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageUploaderDelegate <NSObject>

@end

@interface ImageUploader : NSObject
@property (weak, nonatomic) id <ImageUploaderDelegate> delegate;

//
+(instancetype)shareImageUploader;
-(void)uploadToURLWithImages:(NSArray*)imagesArray;
@end
