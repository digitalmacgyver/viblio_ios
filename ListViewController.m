//
//  ListViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/24/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ListViewController.h"
#define ROW_COUNT @"12"

@interface ListViewController ()

@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.address = [[NSMutableDictionary alloc]init];
    self.dateStamp = [[NSMutableDictionary alloc]init];
    self.faceIndexes = [[NSMutableDictionary alloc]init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playClicked:) name:playVideo object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self.addressesArray removeAllObjects];
    self.address = nil;
    self.dateStamp = nil;
    self.faceIndexes = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Table View Delegate Mehods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    DLog(@"Log : Coming here .....%@", VCLIENT.cloudVideoList);
    return VCLIENT.cloudVideoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"listCells";
    
    listTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    Videos *assetVideo = [DBCLIENT listTheDetailsOfObjectWithURL:[[VCLIENT.filteredVideoList[indexPath.row] defaultRepresentation] url].absoluteString];
//    ALAsset *asset = VCLIENT.filteredVideoList[indexPath.row];
//    cell.asset = asset;
//    cell.video = assetVideo;
//    
//    cell.lblUploadNow.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
    
    [cell.btnImage setImage:nil forState:UIControlStateNormal];
    if( indexPath.row < VCLIENT.cloudVideoList.count )
    {
        cloudVideos *video = [VCLIENT.cloudVideoList objectAtIndex:indexPath.row];
//        UIImageView *imgVw = [[UIImageView alloc]init];
//        [imgVw setImageWithURL:[NSURL URLWithString:video.url]];
        cell.video = video;
        [cell.imgVwThumbnail setImageWithURL:[NSURL URLWithString:video.url]];
        //cell.tag = indexPath.row;
        cell.btnPlay.tag = indexPath.row;
        self.btnPlay.tag = indexPath.row;
//        [ViblioHelper downloadImageWithURLString:video.url completion:^(UIImage *image, NSError *error)
//        {
//            [cell.btnImage setImage:image forState:UIControlStateNormal];
//        }];
        
//        [cell.btnImage setImage:imgVw.image forState:UIControlStateNormal];
//        [cell setNeedsLayout];
//        imgVw = nil;
    }
    
    [cell.lblUploadNow setHidden:YES];
    [cell.lblShareNow setHidden:YES];
    [cell.btnPlay setHidden:NO];
    [cell.btnShare setHidden:NO];
    
    cell.lblInfo.text = nil;
    
    
    if( (indexPath.row == VCLIENT.cloudVideoList.count-1) && VCLIENT.totalRecordsCount > VCLIENT.cloudVideoList.count )
    {
        DLog(@"Log : Lazy load next set of records...");
        [APPCLIENT getTheListOfMediaFilesOwnedByUserWithOptions:@"poster" pageCount:[NSString stringWithFormat:@"%d",(int)((indexPath.row+1)/ROW_COUNT.integerValue)+1] rows:ROW_COUNT success:^(NSMutableArray *result)
         {
             //NSArray *res = [NSArray arrayWithArray:result];
             VCLIENT.cloudVideoList = [[VCLIENT.cloudVideoList arrayByAddingObjectsFromArray:result ] mutableCopy];
             [self.listView reloadData];
         }failure:^(NSError *error)
         {
             DLog(@"Log : Error description - %@", error.localizedDescription);
         }];
    }
    
    
    
    // Logic for filling the information data in list view here
    NSArray *faceImgList = @[cell.face1, cell.face2, cell.face3, cell.face4];
    for( UIImageView *face in faceImgList )
    {
        face.image = nil;
        [face setHidden:YES];
    }
    
    
    
    DLog(@"Log : The dictionaries are - %@", self.address);
    DLog(@"Log : The date stamp dictionary is - %@", self.dateStamp);
    DLog(@"Log : Faces dictionary is - %@", self.faceIndexes);
    
    if( self.address[[NSString stringWithFormat:@"%d",indexPath.row]] != nil )
    {
        DLog(@"Log : Show address for index path - %d   ---    %@", indexPath.row, self.address[[NSString stringWithFormat:@"%d",indexPath.row]]);
        // Already a cached address for the index exists. Need not make a web service call
        cell.lblInfo.text = self.address[[NSString stringWithFormat:@"%d",indexPath.row]];
        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
    }
    else if( self.faceIndexes[[NSString stringWithFormat:@"%d", indexPath.row]]  != nil )
    {
        DLog(@"LOg : Faces aleady cached.. Do not do anything..");
        
        NSArray *facesList = self.faceIndexes[[NSString stringWithFormat:@"%d", indexPath.row]];
        for( int i = 0; i < facesList.count; i++ )
        {
            [((UIImageView*)faceImgList[i]).layer setCornerRadius:((UIImageView*)faceImgList[i]).frame.size.width/2];
            ((UIImageView*)faceImgList[i]).clipsToBounds = YES;
            [((UIImageView*)faceImgList[i]) setImageWithURL:[NSURL URLWithString:facesList[i]]];
            [((UIImageView*)faceImgList[i]) setHidden:NO];
        }
        facesList = nil;
    }
    else if (self.dateStamp[[NSString stringWithFormat:@"%d", indexPath.row]] != nil)
    {
        DLog(@"Log : Show date time for index path - %d", indexPath.row);
        cell.lblInfo.text = self.dateStamp[[NSString stringWithFormat:@"%d", indexPath.row]];
        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:16 isBold:NO];
    }
    else
    {
        [APPCLIENT getFacesInAMediaFileWithUUID:cell.video.uuid success:^(NSArray *facesList)
         {
             DLog(@"Log : The faces list obtained is - %@", facesList);
             
             // If faces list is empty then make a call to reverse geo coding of address
             
             if( facesList != nil && facesList.count > 0 )
             {
                 [cell.lblInfo setHidden:YES];
                 [cell.scrlFaces setHidden:NO];
                 
                 [self.faceIndexes setValue:facesList forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 
                 for( int i = 0; i < facesList.count; i++ )
                 {
                     [((UIImageView*)faceImgList[i]).layer setCornerRadius:((UIImageView*)faceImgList[i]).frame.size.width/2];
                     ((UIImageView*)faceImgList[i]).clipsToBounds = YES;
                     [((UIImageView*)faceImgList[i]) setImageWithURL:[NSURL URLWithString:facesList[i]]];
                     [((UIImageView*)faceImgList[i]) setHidden:NO];
                 }
                 //cell.lblInfo.text = @"Faces found";
                
             }
             else
             {
                 // Check wheteher latitude and longitude info available or not
                 
                 [cell.lblInfo setHidden:NO];
                 [cell.scrlFaces setHidden:YES];
                 
                 if( [cell.video.lat isValid] && [cell.video.longitude isValid] )
                 {
                     DLog(@"Log : Faces returned an empty set.. Fetching the lat and longitude now");

                         // We do not have cached address. Make a web service call to get the address
                         [APPCLIENT getAddressWithLat:cell.video.lat andLong:cell.video.longitude success:^(NSString *address)
                          {
                              cell.lblInfo.text = address;
                              [self.address setValue:address forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                              cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:12 isBold:NO];
                          }failure:^(NSError *error)
                          {
                              
                          }];
                 }
                 else
                 {
                     DLog(@"Log : No Faces and No lat and Long found.. Displaying the created date field now...");
                     cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:16 isBold:NO];
                     cell.lblInfo.text = cell.video.createdDate;
                     [self.dateStamp setValue:cell.video.createdDate forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
                 }
             }
         }failure:^(NSError *error)
         {
             
         }];
        
        faceImgList = nil;
    }
    

    
    
//    if( [assetVideo.sync_status  isEqual: @(0)] && !APPMANAGER.activeSession.autoSyncEnabled.integerValue )
//    {
//        DLog(@"Log : Sync not initialised..");
//        [cell.lblUploadNow setHidden:NO];
//        [cell.btnPlay setHidden:YES];
//        [cell.btnShare setHidden:YES];
//        [cell.lblInfo setHidden:YES];
//    }
//    else
//    {
//        DLog(@"Log : Sync already in progress...");
//        [cell.lblShareNow setHidden:YES];
//        [cell.lblUploadNow setHidden:YES];
//        [cell.btnPlay setHidden:NO];
//        [cell.btnShare setHidden:NO];
//        [cell.lblInfo setHidden:NO];
//        
//        NSString *dateString = [NSDateFormatter localizedStringFromDate:[cell.asset valueForProperty:ALAssetPropertyDate]
//                                                              dateStyle:NSDateFormatterShortStyle
//                                                              timeStyle:NSDateFormatterFullStyle];
//        dateString = (NSString*)[[dateString componentsSeparatedByString:@" "] firstObject];
//        cell.lblInfo.text = dateString;
//        cell.lblInfo.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
//        dateString = nil;
//    }
    
    return cell;
}


- (IBAction)playClicked:(NSNotification*)notification {
    
    DLog(@"Log : In play clicked");
    listTableCell *cell = (listTableCell*)notification.object;
    
    //listTableCell *cell = (listTableCell*)[self.listView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.btnPlay.tag inSection:0]];
    //DLog(@"Log : The index of the cell clicked is  - %d", cell.btnPlay.tag);
    
    [self.spinningWheel startAnimating];
    DLog(@"Log : Play clicked");
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(moviePlayerPlaybackStateDidChange:)  name:MPMoviePlayerPlaybackStateDidChangeNotification  object:nil];
    
    [self registerForMovieNotifications];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    DLog(@"Log : The uuid obtained of the cell is - %@", cell.video.uuid);
    [APPCLIENT getTheCloudUrlForVideoStreamingForFileWithUUID:cell.video.uuid success:^(NSString *cloudURL)
     {
         DLog(@"Log : Cloud url obtained is - %@", cloudURL);
         self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:cloudURL]]; //self.asset.defaultRepresentation.url];
         self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
         self.moviePlayer.view.frame = cell.btnImage.frame;
         [cell addSubview:self.moviePlayer.view];
         //[self.moviePlayer.view addSubview:self.spinningWheel];
         [cell addSubview:self.spinningWheel];
         
         [self.spinningWheel startAnimating];
         //[self bringSubviewToFront:self.moviePlayer.view];
         
         //        self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
         //        self.moviePlayer.shouldAutoplay = YES;
         //        self.moviePlayer.scalingMode= MPMovieScalingModeFill;
         //        self.moviePlayer.controlStyle =MPMovieControlStyleNone;
         
         //        // Registering tap gesture on Movie Player
         //        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playInFullScreen)];
         //        tapGestureRecognizer.numberOfTapsRequired = 1;
         //        [self.moviePlayer.view addGestureRecognizer:tapGestureRecognizer];
         //        self.moviePlayer.view.userInteractionEnabled = YES;
         //        tapGestureRecognizer.delegate = self;
         
         
         // Register for the playback finished notification
         [[NSNotificationCenter defaultCenter] addObserver:self // the object listening / "observing" to the notification
                                                  selector:@selector(myMovieFinishedCallback:) // method to call when the notification was pushed
                                                      name:MPMoviePlayerPlaybackDidFinishNotification // notification the observer should listen to
                                                    object:self.moviePlayer];
         
         [self.moviePlayer play];
         
         [self.btnPlay setHidden:YES];
         //    [self.btnStop setHidden:NO];
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error in streaming the video....");
     }];
    
}

// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


-(void)playInFullScreen
{
    DLog(@"Log : The movie has to be played in full screen...");
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.scalingMode = MPMovieScalingModeNone;
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
}


-(void)myMovieFinishedCallback:(id)sender
{
    DLog(@"Log : Movie finished...");
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self.btnPlay setHidden:NO];
    [self.btnStop setHidden:YES];
}


- (void)registerForMovieNotifications {
    //movie is ready to play notifications
    if ([self.moviePlayer respondsToSelector:@selector(loadState)]) {
        //this is a 3.2+ device
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self.moviePlayer prepareToPlay];
    }
    
    //movie has finished notification
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}


- (void)moviePlayerLoadStateChanged:(NSNotification*)notification {
    DLog(@"load state changed");
    
    //unless state is unknown, start playback
    if ([self.moviePlayer loadState] != MPMovieLoadStateUnknown) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        //        self.moviePlayer.view.frame = self.vwShare.frame;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        //        self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        [self addSubview:self.moviePlayer.view];
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer play];
    }
}



- (void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    DLog(@"playbackDidChanged");
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    if(playbackState == MPMoviePlaybackStateStopped) {
        DLog(@"MPMoviePlaybackStateStopped");
    } else if(playbackState == MPMoviePlaybackStatePlaying) {
        DLog(@"MPMoviePlaybackStatePlaying");
        [self.spinningWheel stopAnimating];
    } else if(playbackState == MPMoviePlaybackStatePaused) {
        [self.spinningWheel startAnimating];
        DLog(@"MPMoviePlaybackStatePaused");
    } else if(playbackState == MPMoviePlaybackStateInterrupted) {
        DLog(@"MPMoviePlaybackStateInterrupted");
    } else if(playbackState == MPMoviePlaybackStateSeekingForward) {
        DLog(@"MPMoviePlaybackStateSeekingForward");
    } else if(playbackState == MPMoviePlaybackStateSeekingBackward) {
        DLog(@"MPMoviePlaybackStateSeekingBackward");
    }
}


- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = notification.object;
    NSMutableString *loadState = [NSMutableString new];
    MPMovieLoadState state = moviePlayerController.loadState;
    if (state & MPMovieLoadStatePlayable)
    {
        [self.spinningWheel startAnimating];
        [loadState appendString:@" | Playable"];
    }
    //[loadState appendString:@" | Playable"];
    if (state & MPMovieLoadStatePlaythroughOK)
    {
        [self.spinningWheel stopAnimating];
        [loadState appendString:@" | Playthrough OK"];
    }
    //[loadState appendString:@" | Playthrough OK"];
    if (state & MPMovieLoadStateStalled)
    {
        [self.spinningWheel startAnimating];
        [loadState appendString:@" | Stalled"];
    }
    //[loadState appendString:@" | Stalled"];
    
    DLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



@end
