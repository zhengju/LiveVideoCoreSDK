//
//  LiveShowViewController.m
//  LiveVideoCoreDemo
//
//  Created by Alex.Shi on 16/3/2.
//  Copyright © 2016年 com.Alex. All rights reserved.
//

#import "LiveShowViewController.h"
#import "XMNShareMenu.h"

@implementation LiveShowViewController
{
    UIView* _AllBackGroudView;
    UIButton* _ExitButton;
    UILabel*  _RtmpStatusLabel;
    UIButton* _FilterButton;
    UIButton* _CameraChangeButton;
    XMNShareView* _FilterMenu;
    
    Boolean _bCameraFrontFlag;
}
@synthesize RtmpUrl;

-(void) UIInit{
    double fScreenW = [UIScreen mainScreen].bounds.size.width;
    double fScreenH = [UIScreen mainScreen].bounds.size.height;
    
    _AllBackGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fScreenW, fScreenH)];
    [self.view addSubview:_AllBackGroudView];
    
    float fExitButtonW = 40;
    float fExitButtonH = 20;
    float fExitButtonX = fScreenW - fExitButtonW - 10;
    float fExitButtonY = fScreenH - fExitButtonH - 10;
    _ExitButton = [[UIButton alloc] initWithFrame:CGRectMake(fExitButtonX, fExitButtonY, fExitButtonW, fExitButtonH)];
    _ExitButton.backgroundColor = [UIColor blueColor];
    _ExitButton.layer.masksToBounds = YES;
    _ExitButton.layer.cornerRadius  = 5;
    [_ExitButton setTitle:@"退出" forState:UIControlStateNormal];
    [_ExitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _ExitButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    [_ExitButton addTarget:self action:@selector(OnExitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_ExitButton];
    
    float fRtmpStatusLabelW = 120;
    float fRtmpStatusLabelH = 20;
    float fRtmpStatusLabelX = 10;
    float fRtmpStatusLabelY = 30;
    _RtmpStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(fRtmpStatusLabelX, fRtmpStatusLabelY, fRtmpStatusLabelW, fRtmpStatusLabelH)];
    _RtmpStatusLabel.backgroundColor = [UIColor lightGrayColor];
    _RtmpStatusLabel.layer.masksToBounds = YES;
    _RtmpStatusLabel.layer.cornerRadius  = 5;
    _RtmpStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    [_RtmpStatusLabel setTextColor:[UIColor whiteColor]];
    _RtmpStatusLabel.text = @"RTMP状态: 未连接";
    [self.view addSubview:_RtmpStatusLabel];
    
    float fFilterButtonW = 50;
    float fFilterButtonH = 30;
    float fFilterButtonX = fScreenW/2-fFilterButtonW-5;
    float fFilterButtonY = fScreenH - fFilterButtonH - 10;
    _FilterButton = [[UIButton alloc] initWithFrame:CGRectMake(fFilterButtonX, fFilterButtonY, fFilterButtonW, fFilterButtonH)];
    _FilterButton.backgroundColor = [UIColor blueColor];
    _FilterButton.layer.masksToBounds = YES;
    _FilterButton.layer.cornerRadius  = 5;
    [_FilterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    [_FilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _FilterButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    [_FilterButton addTarget:self action:@selector(OnFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_FilterButton];
    
    float fCameraChangeButtonW = fFilterButtonW;
    float fCameraChangeButtonH = fFilterButtonH;
    float fCameraChangeButtonX = fScreenW/2+5;
    float fCameraChangeButtonY = fFilterButtonY;
    
    _CameraChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(fCameraChangeButtonX, fCameraChangeButtonY, fCameraChangeButtonW, fCameraChangeButtonH)];
    _CameraChangeButton.backgroundColor = [UIColor blueColor];
    _CameraChangeButton.layer.masksToBounds = YES;
    _CameraChangeButton.layer.cornerRadius  = 5;
    [_CameraChangeButton setTitle:@"后置镜头" forState:UIControlStateNormal];
    [_CameraChangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _CameraChangeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
    [_CameraChangeButton addTarget:self action:@selector(OnCameraChangeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_CameraChangeButton];
}

-(void) RtmpInit{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LiveVideoCoreSDK sharedinstance] LiveInit:RtmpUrl Preview:_AllBackGroudView VideSize:LIVE_VIEDO_SIZE_CIF BitRate:LIVE_BITRATE_500Kbps FrameRate:LIVE_FRAMERATE_20];
        [LiveVideoCoreSDK sharedinstance].delete = self;
        
        [[LiveVideoCoreSDK sharedinstance] connect];
        NSLog(@"Rtmp[%@] is connecting", self.RtmpUrl);
        
        [self.view addSubview:_ExitButton];
        [self.view addSubview:_RtmpStatusLabel];
        [self.view addSubview:_FilterButton];
        [self.view addSubview:_CameraChangeButton];
    });
}

-(void) OnCameraChangeClicked:(id)sender{
    _bCameraFrontFlag = !_bCameraFrontFlag;
    [[LiveVideoCoreSDK sharedinstance] setCameraFront:_bCameraFrontFlag];
    if (_bCameraFrontFlag) {
        [_CameraChangeButton setTitle:@"前置镜头" forState:UIControlStateNormal];
    }else{
        [_CameraChangeButton setTitle:@"后置镜头" forState:UIControlStateNormal];
    }
}

-(void) OnFilterClicked:(id)sender{
    NSArray *shareAry = @[@{kXMNShareImage:@"original_Image",
                            kXMNShareHighlightImage:@"original_Image",
                            kXMNShareTitle:@"原始"},
                          @{kXMNShareImage:@"beauty_Image",
                          kXMNShareHighlightImage:@"beauty_Image",
                          kXMNShareTitle:@"美颜"},
                          @{kXMNShareImage:@"fugu_Image",
                            kXMNShareHighlightImage:@"fugu_Image",
                            kXMNShareTitle:@"复古"},
                          @{kXMNShareImage:@"black_Image",
                            kXMNShareHighlightImage:@"fugu_Image",
                            kXMNShareTitle:@"黑白"},];
    //自定义头部
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 21, headerView.frame.size.width-32, 15)];
    label.textColor = [UIColor colorWithRed:94/255.0 green:94/255.0 blue:94/255.0 alpha:1.0];;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"滤镜:";
    [headerView addSubview:label];
    
    _FilterMenu = [[XMNShareView alloc] init];
    //设置头部View 如果不设置则不显示头部
    _FilterMenu.headerView = headerView;
    [_FilterMenu setSelectedBlock:^(NSUInteger tag, NSString *title) {
        NSLog(@"\ntag :%lu  \ntitle :%@",(unsigned long)tag,title);

        switch(tag) {
            case 0://原图像
                NSLog(@"设置无滤镜...");
                [[LiveVideoCoreSDK sharedinstance] setFilter:LIVE_FILTER_ORIGINAL];
                break;
            case 1://美颜
                NSLog(@"设置美艳滤镜...");
                [[LiveVideoCoreSDK sharedinstance] setFilter:LIVE_FILTER_BEAUTY];
                break;
            case 2://复古
                NSLog(@"设置复古滤镜...");
                [[LiveVideoCoreSDK sharedinstance] setFilter:LIVE_FILTER_ANTIQUE];
                break;
            case 3://黑白
                NSLog(@"设置黑白滤镜...");
                [[LiveVideoCoreSDK sharedinstance] setFilter:LIVE_FILTER_BLACK];
                break;
            default:
                break;
        }
    }];
    
    //计算高度 根据第一行显示的数量和总数,可以确定显示一行还是两行,最多显示2行
    [_FilterMenu setupShareViewWithItems:shareAry];
    
    [_FilterMenu showUseAnimated:YES];
}

-(void) OnExitClicked:(id)sender{
    NSLog(@"Rtmp[%@] is ended", self.RtmpUrl);
    [[LiveVideoCoreSDK sharedinstance] disconnect];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self UIInit];
    
    [self RtmpInit];
    
    _bCameraFrontFlag = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//rtmp status delegate:
- (void) LiveConnectionStatusChanged: (LIVE_VCSessionState) sessionState{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (sessionState) {
            case LIVE_VCSessionStatePreviewStarted:
                _RtmpStatusLabel.text = @"RTMP状态: 预览未连接";
                break;
            case LIVE_VCSessionStateStarting:
                _RtmpStatusLabel.text = @"RTMP状态: 连接中...";
                break;
            case LIVE_VCSessionStateStarted:
                _RtmpStatusLabel.text = @"RTMP状态: 已连接";
                break;
            case LIVE_VCSessionStateEnded:
                _RtmpStatusLabel.text = @"RTMP状态: 未连接";
                break;
            case LIVE_VCSessionStateError:
                _RtmpStatusLabel.text = @"RTMP状态: 错误";
                break;
            default:
                break;
        }
    });
}

@end
