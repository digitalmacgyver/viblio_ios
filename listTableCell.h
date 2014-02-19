//
//  listTableCell.h
//  Viblio_v2
//
//  Created by Vinay on 1/28/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface listTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUploadNow;
@property (weak, nonatomic) IBOutlet UILabel *lblShareNow;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlFaces;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;

@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong)cloudVideos *video;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;
@property (weak, nonatomic) IBOutlet UIImageView *imgVwThumbnail;
@property (weak, nonatomic) IBOutlet UIView *vwShareBtns;

//@property(nonatomic, strong)ALAsset *asset;
//@property(nonatomic, strong)Videos *video;
@property (weak, nonatomic) IBOutlet UIImageView *face1;
@property (weak, nonatomic) IBOutlet UIImageView *face2;
@property (weak, nonatomic) IBOutlet UIImageView *face3;
@property (weak, nonatomic) IBOutlet UIImageView *face4;

@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnFB;
@property (weak, nonatomic) IBOutlet UIButton *btnGoogle;
@property (weak, nonatomic) IBOutlet UIButton *btnMail;

@property NSString * addressBookNum;

-(void)removeShareVw;
- (IBAction)sharingVideoClicked:(id)sender;

@end
