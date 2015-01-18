//
//  ViewController.h
//  AEye
//
//  Created by Ishaan Gulrajani on 1/17/15.
//  Copyright (c) 2015 Ishaan Gulrajani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, strong) UIImagePickerController *picker;
@property(nonatomic, strong) UILabel *label;
@end

