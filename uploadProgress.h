//
//  uploadProgress.h
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface uploadProgress : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *uploadThumbnail;
@property (weak, nonatomic) IBOutlet UIView *vwUploadProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadProgress;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnResume;

@property(nonatomic, strong) ALAsset *asset;
@property(nonatomic, strong) Videos *video;

@end
