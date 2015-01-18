//
//  ViewController.m
//  AEye
//
//  Created by Ishaan Gulrajani on 1/17/15.
//  Copyright (c) 2015 Ishaan Gulrajani. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:36.0];
    self.label.textColor = [UIColor whiteColor];

    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
    
    [self.view addSubview:self.label];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openCamera];
    });
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)openCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://54.82.210.184" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(chosenImage, 0.5)
                                    name:@"file" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [[[UIAlertView alloc] initWithTitle:@":(" message:[[error userInfo] description] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
        } else {
            NSString *responseText = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:responseText];
            utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
            [[[AVSpeechSynthesizer alloc] init] speakUtterance:utterance];
            
            self.label.text = responseText;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self openCamera];
            });
        }
    }];
    
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Recognizing."];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    [[[AVSpeechSynthesizer alloc] init] speakUtterance:utterance];

    
    self.label.text = @"recognizing...";
    
    [uploadTask resume];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
}

@end
