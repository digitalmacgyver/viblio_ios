//
//  listTableCell.h
//  Viblio_v2
//
//  Created by Vinay on 1/28/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface listTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUploadNow;
@property (weak, nonatomic) IBOutlet UILabel *lblShareNow;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlFaces;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;

@property(nonatomic, strong)ALAsset *asset;
@property(nonatomic, strong)Videos *video;

@end
