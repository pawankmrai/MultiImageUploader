//
//  ImageUploader.m
//  MultiImageUploader
//
//  Created by Pawan on 11/28/15.
//  Copyright © 2015 Pawan. All rights reserved.
//

#import "ImageUploader.h"
#import "AppDelegate.h"
static NSString *Upload_URL =  @"http://nickelodeon.sirconrad.com/main/me.json";
static NSString *BackgroundSessionIdentifier = @"com.nick.BackgroundTransfer.BackgroundSession";

@interface ImageUploader ()< NSURLSessionDelegate, NSURLSessionTaskDelegate>
@end

@implementation ImageUploader

+(instancetype)shareImageUploader {
    
    static ImageUploader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageUploader alloc] init];
    });
    return sharedInstance;
}

-(void)uploadToURLWithImages:(NSArray *)imagesArray {
    
    //
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:[imagesArray count]];
    
    //
    for (UIImage *image in imagesArray) {
        NSDate *date = [NSDate date];
        NSString *uniqueImageName = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
        NSString *imageName=[NSString stringWithFormat:@"%@_image%lu.jpg",uniqueImageName,(unsigned long)[imagesArray indexOfObject:image]];
        NSData *data = UIImageJPEGRepresentation(image, 0);
        [jsonDictionary addEntriesFromDictionary:@{imageName: data}];
    }
    
    NSURLRequest *request = [self convertToRequestWithDictionary:jsonDictionary];
    
    // Define the Upload task
    NSURLSessionDataTask *dataTask = [[self backgroundSession] dataTaskWithRequest:request];
    
    // Run it!
    [dataTask resume];
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:BackgroundSessionIdentifier];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

- (NSURLRequest *)convertToRequestWithDictionary:(NSDictionary *)dictionary {
    
    NSURL *url = [NSURL URLWithString:Upload_URL];
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"6"        forHTTPHeaderField:@"multi"];
    
    NSMutableData *postbody = [NSMutableData data];
    NSString *postData = [self getHTTPBodyParamsFromDictionary:dictionary boundary:boundary];
    [postbody appendData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if(obj != nil) {
            //
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *contentString=[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"",key];
            [postbody appendData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[NSData dataWithData:obj]];
        }
    }];
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    return request;
}

-(NSString *)getHTTPBodyParamsFromDictionary: (NSDictionary *)params boundary:(NSString *)boundary {
    
    NSMutableString *tempVal = [[NSMutableString alloc] init];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [tempVal appendFormat:@"\r\n--%@\r\n", boundary];
        [tempVal appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@",key,obj];
    }];
    
    return [tempVal description];
}

#pragma mark NSURLSession Delegate Methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received String %@",str);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    NSLog(@"didSendBodyData: %lld, totalBytesSent: %lld, totalBytesExpectedToSend: %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != NULL) NSLog(@"Error: %@",[error localizedDescription]);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"All tasks are finished");
}

@end
