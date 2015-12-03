//
//  ViewController.m
//  LTProgressSlider
//
//  Created by 陈记权 on 11/16/15.
//  Copyright © 2015 陈记权. All rights reserved.
//

#import "ViewController.h"
#import "LTProgressSlider.h"

@interface ViewController ()
{
    LTProgressSlider *m_progress;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //LTProgressSlider *progress = [[LTProgressSlider alloc]init];
    LTProgressSlider *progress = [[LTProgressSlider alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    progress.center = self.view.center;
    progress.backgroundColor = [UIColor grayColor];
    progress.suportDoubleProgress = YES;
    [progress addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [progress addTarget:self action:@selector(progressChanges:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:progress];
    m_progress = progress;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progress) userInfo:nil repeats:YES];
    
}

- (void)touchUpInside
{
    m_progress.lt_state = (m_progress.lt_state == LTPeogressSliderStatePaused) ? LTPeogressSliderStatePlaying : LTPeogressSliderStatePaused;
    NSLog(@"%s", sel_getName(_cmd));
}

- (void)progressChanges:(id)target
{
    if ([target isKindOfClass:[LTProgressSlider class]]) {
        LTProgressSlider *progressSlider = (LTProgressSlider *)target;
        NSLog(@"%@", @(progressSlider.progress));
    }
}

static CGFloat progress = 0.0f;
static CGFloat downP = 0.0f;
- (void)progress
{
    progress = m_progress.progress;
    progress += 0.005;
    downP += 0.1f;
    
    [m_progress setProgress:progress animated:YES];
    [m_progress setAnotherProgress:downP];
    //progressView.progress = [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] floatValue]/100;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
