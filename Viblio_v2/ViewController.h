//
//  ViewController.h
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController
{
    __block int i ;
}
@property(nonatomic,retain)NSMutableArray *filteredVideoList;

@property(nonatomic, retain)NSMutableArray *chunks;

@property(nonatomic,strong)ALAsset *asset;
@end
