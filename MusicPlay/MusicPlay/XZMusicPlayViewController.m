//
//  XZMusicPlayViewController.m
//  XiaoZhu
//
//  Created by LM on 2017/4/18.
//  Copyright © 2017年 孙亚锋. All rights reserved.
//

#import "XZMusicPlayViewController.h"
#import "CALayer+PauseAimate.h"
#import "XZAllMusicModel.h"
#import "AudioStreamer.h"
#import "MusciScrollView.h"
#import "LrcLabel.h"
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
@interface XZMusicPlayViewController ()<AVAudioPlayerDelegate,UIGestureRecognizerDelegate>
{
    UILabel *titleLab;
    UIImageView *musicImg;
    UIImageView *backImgView;
    UIButton *playBtn;
    UISlider *mySlider;
    
    UILabel *timeLab;
    UILabel *allTimeLab;
    
    NSTimer *_timer;
    UITapGestureRecognizer *_tapGesture;
    XZAllMusicModel *dataModel;
    MusciScrollView *LrcScrollView;
    BOOL isHave;
    
}

@property (nonatomic,strong)AVAudioPlayer *musicPlayer;
@property (nonatomic,strong)AudioStreamer *streamer;;

//@property (nonatomic,strong)MusciScrollView *LrcScrollView;
//@property (nonatomic,strong)LrcLabel *LrcLabel;
/** 歌词的定时器*/
@property(nonatomic,strong)CADisplayLink *lrcTimer;

@end

@implementation XZMusicPlayViewController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer=nil;
    [self removeLrcTimer];
    if (self.streamer) {
        [self.streamer stop];
    }
    if (self.musicPlayer) {
        [self.musicPlayer stop];
    }
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self.view endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    NSLog(@"shahe---%@",NSHomeDirectory());
    isHave = NO;
    [self createBackAndTitleView];
    
    [self createImgViewWithImg];
    
    // 获取音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 设置会话类别为后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 激活会话
    [session setActive:YES error:nil];

    [self createBottomView];
    //3.将 lrcscrollview的lrclabel设置为主控制器的Label
    //    self.LrcScrollView = [[MusciScrollView alloc]initWithFrame:CGRectMake(50, 100, kScreenWidth-100, 310)];
    LrcScrollView = [[MusciScrollView alloc]initWithFrame:CGRectMake(0, 360, self.view.frame.size.width, 60)];
    //    self.LrcScrollView.lrcLab = self.LrcLabel;
    LrcScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 60);
    [self.view addSubview:LrcScrollView];

    [self createMusicPlayer];
    
    
    
    
}
- (void)createMusicPlayer{
    //1判断本地是否存在这首歌
    //2存在的话直接取播放  不存在 流媒体播放 异步缓存本地
    //3点击上一首 下一首的时候 判断本地是否存在 执行2
    
    dataModel = self.dataArr[self.currrntCell];
    
    mySlider.value = 0;
    timeLab.text = @"00:00";
    
    //将数据保存到本地指定位置
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //music文件夹
    NSString *createPath = [NSString stringWithFormat:@"%@/music", docDirPath];
    
    //music地址
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", createPath ,dataModel.musicName];
    NSString *filePath1 = [NSString stringWithFormat:@"%@/%@.lrc", createPath ,dataModel.musicName];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_queue_t serialQueue = dispatch_queue_create("com.dispatch.serial", DISPATCH_QUEUE_SERIAL);
        dispatch_async(serialQueue, ^{
            
            NSString *urlStr =
            ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                   nil,
                                                                                   (CFStringRef)dataModel.songUrl,
                                                                                   NULL,
                                                                                   NULL,
                                                                                   kCFStringEncodingUTF8)) ;
            ;
            NSURL *url = [[NSURL alloc]initWithString:urlStr];
            NSData * audioData = [NSData dataWithContentsOfURL:url];
            NSString *filePath1 = [NSString stringWithFormat:@"%@/%@.mp3", createPath ,dataModel.musicName];
            [audioData writeToFile:filePath1 atomically:YES];
            
        });
        
        NSString *lrcStr =
        ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                               nil,
                                                                               (CFStringRef)dataModel.lyricsUrl,
                                                                               NULL,
                                                                               NULL,
                                                                               kCFStringEncodingUTF8)) ;
        ;
        NSURL *url1 = [[NSURL alloc]initWithString:lrcStr];
        NSData * audioData1 = [NSData dataWithContentsOfURL:url1];
        NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.lrc", createPath ,dataModel.musicName];
        [audioData1 writeToFile:filePath2 atomically:YES];
        
        isHave = NO;
        
//        if (!streamer) {
            [self createStreamer];
//        }
        if (_timer==nil) {
            _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        }
        [self.streamer start];
        
        // 3.2设置歌词
        LrcScrollView.lrcName = [NSString stringWithFormat:@"%@.lrc",dataModel.musicName];
        // 3.3 设置歌曲总时长
        LrcScrollView.totlaDurtion = self.streamer.duration;
        
        [self removeLrcTimer ];
        [self addLrcTimer];
        
    } else {
        NSLog(@"FileDir is exists.");
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath1]) {
            NSLog(@"不存在");
        }else{
            NSLog(@"存在");
        }
        
        isHave = YES;
        //播放本地音乐
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        self.musicPlayer.delegate = self;
        if (_timer==nil) {
            _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            
            [self.musicPlayer play];
            
        }
        
        // 3.2设置歌词
        LrcScrollView.lrcName = [NSString stringWithFormat:@"%@.lrc",dataModel.musicName];
        // 3.3 设置歌曲总时长
        LrcScrollView.totlaDurtion = self.musicPlayer.duration;
        
        [self removeLrcTimer ];
        [self addLrcTimer];
        
    }
    
    
    
    
    [self updateView];

}
//更新界面
- (void)updateView{
    titleLab.text = dataModel.musicName;
    allTimeLab.text = dataModel.time;
//    [musicImg sd_setImageWithURL:[NSURL URLWithString:dataModel.img] placeholderImage:placeholderImg];
//    [backImgView sd_setImageWithURL:[NSURL URLWithString:dataModel.img] placeholderImage:placeholderImg];
    
    [self beginRotation];
    
}
#pragma mark - 对歌词定时器的处理
-(void)addLrcTimer{
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcInfo)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}
-(void)removeLrcTimer{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}
#pragma mark - - 更新歌词进度
-(void)updateLrcInfo{
    if (isHave) {
//        NSLog(@"----%f",self.musicPlayer.currentTime);
        LrcScrollView.currentTime = self.musicPlayer.currentTime;
        
    }else{
        LrcScrollView.currentTime = self.streamer.progress;
    }
    
}
-(void)onTimer:(NSTimer *)oneTimer{
    if (isHave) {
        mySlider.value= self.musicPlayer.currentTime/self.musicPlayer.duration;
        timeLab.text = [self getFormatTimeWithTimeInterval:self.musicPlayer.currentTime];
    }else{

        mySlider.value= self.streamer.progress/self.streamer.duration;
        timeLab.text = [self getFormatTimeWithTimeInterval:self.streamer.progress];
//        NSLog(@"mySlider.value==%f",mySlider.value);
//        NSLog(@"streamer.progress==%f",self.streamer.progress);
//        NSLog(@"streamer.duration==%f",self.streamer.duration);
//        if (streamer.progress>0 && streamer.duration>0 && streamer.duration - streamer.progress < 1 ) {
//            mySlider.value = 1;
//            timeLab.text = dataModel.time;
//            streamer = nil;
//            //下一首？
//            self.currrntCell++;
//            if (self.currrntCell > _dataArr.count-1) {
//                self.currrntCell = 0;
//            }
//            [self createMusicPlayer];
//        }
    }
    
}
#pragma mark - 播放结束
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_timer invalidate];
    _timer=nil;
    self.musicPlayer = nil;
    self.currrntCell++;
    if (self.currrntCell > _dataArr.count-1) {
        self.currrntCell = 0;
    }
    [self createMusicPlayer];
}
#pragma mark - 点击进度条
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:mySlider];
    CGFloat value = (mySlider.maximumValue - mySlider.minimumValue) * (touchPoint.x / mySlider.frame.size.width );
    [mySlider setValue:value animated:YES];
    if (_timer==nil) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        
        [self.musicPlayer play];
    }
    self.musicPlayer.currentTime = mySlider.value*self.musicPlayer.duration;
    timeLab.text = [self getFormatTimeWithTimeInterval:self.musicPlayer.currentTime];
}
#pragma mark - 拖动进度条
- (void)touchUp{
    
}
- (void)valueChange:(UISlider *)sender {
    // 获取当前播放的音乐信息数据模型
    
    // 计算当前播放的时间
    
    // 修改已经播放时长的label
//    timeLab.text = [self getFormatTimeWithTimeInterval:180*sender.value];
    timeLab.text = [self getFormatTimeWithTimeInterval:self.musicPlayer.currentTime];
    self.musicPlayer.currentTime = mySlider.value*self.musicPlayer.duration;
//    NSLog(@"222");
}
#pragma mark - 播放事件
- (void)playBtnClick:(UIButton *)clickBtn{

    
    if (clickBtn.selected == YES) {
        
        [playBtn setImage:[UIImage imageNamed:@"music_icon_pause"] forState:0];
        [clickBtn setSelected:NO];
        if (isHave) {
            [self.musicPlayer stop];
           
            //暂停 关闭定时器 不浪费资源
            [_timer invalidate];
            _timer=nil;
        }else{
            [self.streamer pause];
            [_timer invalidate];
            _timer=nil;
        }
        // 暂停动画
         [self pauseRotation];
        
        
    }else{
        [playBtn setImage:[UIImage imageNamed:@"music_icon_play"] forState:0];
        [clickBtn setSelected:YES];
        
        if (isHave) {
            if (_timer==nil) {
                _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
                
                [self.musicPlayer play];
            }else{
                [self.musicPlayer play];
            }
        }else{
            if (_timer==nil) {
                _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
                
                [self.streamer start];
            }else{
                [self.streamer start];
            }
            
        }
        //恢复动画
        [self resumeRotation];
        
        
    }
}
#pragma mark - 下一首事件
- (void)nextBtnClick:(UIButton *)clickBtn{
    
    [_timer invalidate];
    _timer=nil;
    timeLab.text = @"00:00";
    mySlider.value = 0;
    
    [playBtn setImage:[UIImage imageNamed:@"music_icon_play"] forState:0];
    [playBtn setSelected:YES];
    
    
    if (self.streamer) {
//        self.streamer = nil;
        
//        [self.streamer pause];
        [self.streamer stop];
        
    }if (self.musicPlayer) {
//        self.musicPlayer = nil;
        [self.musicPlayer stop];
    }
    

    self.currrntCell++;
    if (self.currrntCell > _dataArr.count-1) {
        self.currrntCell = 0;
    }
    [self createMusicPlayer];
    

    
}
- (void)dealloc{
    if (self.streamer) {
        [self.streamer pause];
        [self.streamer stop];
        self.streamer = nil;
        
    }if (self.musicPlayer) {
        [self.musicPlayer stop];
        self.musicPlayer = nil;
    }
}
#pragma mark - 上一首事件
- (void)lastBtnClick:(UIButton *)clickBtn{
    
    [playBtn setImage:[UIImage imageNamed:@"music_icon_play"] forState:0];
    [playBtn setSelected:YES];
    
    [_timer invalidate];
    _timer=nil;
    timeLab.text = @"00:00";
    mySlider.value = 0;
    
    if (self.streamer) {
        [self.streamer stop];
        
    }if (self.musicPlayer) {
        [self.musicPlayer stop];
    }
    
    
    
    self.currrntCell--;
    if (self.currrntCell < 0) {
        self.currrntCell = self.dataArr.count - 1;
    }
    [self createMusicPlayer];
    
    
}
#pragma mark - 随机
- (void)randomBtnClick:(UIButton *)clickBtn{
    if (clickBtn.selected == YES) {
        [clickBtn setImage:[UIImage imageNamed:@"music_icon_repeatonce"] forState:0];
        [clickBtn setSelected:NO];
    
        if (isHave) {
            if (self.musicPlayer) {
                [self.musicPlayer setNumberOfLoops:-1];
            }
        }
        
    }else{
        [clickBtn setImage:[UIImage imageNamed:@"music_icon_randompLay"] forState:0];
        [clickBtn setSelected:YES];
        if (isHave) {
            if (self.musicPlayer) {
                [self.musicPlayer setNumberOfLoops:0];
            }
        }
    }
}
- (void)createImgViewWithImg{
    musicImg = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-206)/2, 145, 206, 206)];
    // 设置歌手头像为圆形
    musicImg.layer.cornerRadius = musicImg.frame.size.width * 0.5;
    musicImg.layer.masksToBounds = YES;
    musicImg.layer.borderWidth = 3.0;
    musicImg.layer.borderColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor;
    musicImg.image = [UIImage imageNamed:@"dzq@2x.jpg"];
    
    
    [self.view addSubview:musicImg];
}
/**
 *  开始旋转
 */
- (void)beginRotation
{
    [musicImg.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    animation.duration = 30;
    animation.keyPath = @"transform.rotation.z";
    animation.repeatCount = NSIntegerMax;
    animation.removedOnCompletion = NO;
    [musicImg.layer addAnimation:animation forKey:@"rotation"];
}

/**
 *  暂停旋转(此处的实现, 是使用到了一个CALayer分类, 来暂停核心动画)
 */
- (void)pauseRotation
{
    [musicImg.layer pauseAnimate];
}

/**
 *  继续旋转(此处的实现, 是使用到了一个CALayer分类, 来暂停核心动画)
 */
- (void)resumeRotation
{
    [musicImg.layer resumeAnimate];
}
- (void)createBackAndTitleView{
    
    backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backImgView.image = [UIImage imageNamed:@"dzq@2x.jpg"];
    backImgView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backImgView];
#pragma mark - -添加毛玻璃
    UIToolbar * toolbar = [[UIToolbar alloc]init];
    
    [backImgView addSubview:toolbar];
    
    toolbar.barStyle = UIBarStyleBlack;
    
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(backImgView);
    }];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"b返回"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(15, 32, 20*88/36, 20);
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 200, 30)];
//    titleLab.center.x = self.view.center.x;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"名字";
    titleLab.textColor = [UIColor whiteColor];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.userInteractionEnabled = YES;
//    [titleBtn addTarget:self action:@selector(changeAllOrMy) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backBtn];
    [self.view addSubview:titleLab];
}

- (void)createBottomView{
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.selected = YES;
    playBtn.frame = CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height-100, 40, 40);
    [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setImage:[UIImage imageNamed:@"music_icon_play"] forState:0];
    [self.view addSubview:playBtn];
    
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(self.view.frame.size.width/2+20+40, self.view.frame.size.height-100+2.5, 35, 35);
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageNamed:@"music_icon_next"] forState:0];
    [self.view addSubview:nextBtn];
    
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lastBtn.frame = CGRectMake(self.view.frame.size.width/2-20-40-35, self.view.frame.size.height-100+2.5, 35, 35);
    [lastBtn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [lastBtn setImage:[UIImage imageNamed:@"music_icon_last"] forState:0];
    [self.view addSubview:lastBtn];
    
    UIButton *randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    randomBtn.frame = CGRectMake(15,self.view.frame.size.height-100, 40, 40);
    randomBtn.selected = YES;
    [randomBtn addTarget:self action:@selector(randomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [randomBtn setImage:[UIImage imageNamed:@"music_icon_randompLay"] forState:0];
    [self.view addSubview:randomBtn];
    

    mySlider = [[UISlider alloc]initWithFrame:CGRectMake(55, self.view.frame.size.height-100-25-30,self.view.frame.size.width - 110, 30)];
    mySlider.tintColor = [UIColor blueColor];
    mySlider.enabled = YES;
    mySlider.continuous = YES;
    mySlider.userInteractionEnabled = YES;
    [mySlider setThumbImage:[UIImage imageNamed:@"按钮-是"] forState:UIControlStateNormal];
    [mySlider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [mySlider addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
//    [mySlider addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mySlider];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    _tapGesture.delegate = self;
    [mySlider addGestureRecognizer:_tapGesture];
    
    timeLab = [[UILabel alloc]initWithFrame:CGRectMake(15, self.view.frame.size.height-100-25-23, 37, 15)];
    timeLab.text = @"00:00";
    timeLab.textColor = [UIColor whiteColor];
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:timeLab];
    
    allTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-15-37, self.view.frame.size.height-100-25-23, 37, 15)];
    allTimeLab.text = @"03:27";
    allTimeLab.textColor = [UIColor whiteColor];
    allTimeLab.font = [UIFont systemFontOfSize:12];
    allTimeLab.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:allTimeLab];
    
}
//流媒体播放
- (void)createStreamer
{
    [self destroyStreamer];
    
    NSString *escapedValue =
    ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                           nil,
                                                                           (CFStringRef)dataModel.songUrl,
                                                                           NULL,
                                                                           NULL,
                                                                           kCFStringEncodingUTF8)) ;
    ;
    NSURL *url = [NSURL URLWithString:escapedValue];
    self.streamer = [[AudioStreamer alloc] initWithURL:url];
    
}

- (void)destroyStreamer
{
    if (self.streamer)
    {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:self.streamer];
        
        [self.streamer stop];
    }
}


- (NSString *)getFormatTimeWithTimeInterval:(NSTimeInterval)timeInterval
{
    // 获取分钟数
    NSInteger min = timeInterval / 60;
    // 获取秒数
    NSInteger sec = (NSInteger)timeInterval % 60;
    // 返回计算后的数值
    return [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
}
- (void)backClick{
    [_timer invalidate];
    _timer=nil;
    if (self.streamer) {
        [self.streamer stop];
    }
    if (self.musicPlayer) {
        [self.musicPlayer stop];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
