//
//  listTableCell.m
//  Viblio_v2
//
//  Created by Vinay on 1/28/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "listTableCell.h"

@implementation listTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnPlayClicked:(id)sender {
    
  //  NSString *mediaPath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:@"understandingoilcost_1500kbps.mov"];
    
    DLog(@"Log : the url is - %@", self.asset.defaultRepresentation.url);
    
    NSURL *url = [NSURL URLWithString:@"assets-library://asset/asset.MOV?id=70AA4AA8-E3B9-4FBF-8877-A48515DB6B82&ext=MOV"];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url]; //self.asset.defaultRepresentation.url];
    
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    self.moviePlayer.view.frame = self.btnImage.frame;
    
    [self.superview addSubview:self.moviePlayer.view];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.scalingMode= MPMovieScalingModeFill;
    self.moviePlayer.controlStyle =MPMovieControlStyleNone;
    
    [self.moviePlayer play];
}


- (IBAction)imfThumbTapped:(id)sender {
}

- (IBAction)btnShareClicked:(id)sender {
}

- (IBAction)btnStopClicked:(id)sender {
}
@end
