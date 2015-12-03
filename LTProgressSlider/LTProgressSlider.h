//
//  LTProgressSlider.h
//  LTProgressSlider
//
//  Created by 陈记权 on 11/16/15.
//  Copyright © 2015 陈记权. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LTPeogressSliderState) {
    LTPeogressSliderStateDefault,
    LTPeogressSliderStateSliding,
    LTPeogressSliderStatePlaying,
    LTPeogressSliderStatePaused
};

typedef void(^ProgressSlidingBlock)(CGFloat progress) ;

@interface LTProgressSlider : UIControl

/**
 *  progress
 */
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CGFloat horizontallyInset;
@property (nonatomic, assign) CGFloat verticalInset;

/**
 *  progress view background color
 */
@property (nonatomic, strong) UIColor *progressBgColor;

@property (nonatomic, strong) UIColor *outerBorderColor;
@property (nonatomic, assign) CGFloat outerBorderWidth;

@property (nonatomic, assign) CGFloat progressInset;
@property (nonatomic, strong) UIColor *trackColor;
/**
 *  是否支持双进度.
 *      default is NO;
 */
@property (nonatomic, assign) BOOL suportDoubleProgress;

/**
 *  another progress for double progress suport.
 */
@property (nonatomic, assign) CGFloat anotherProgress;
@property (nonatomic, assign) CGFloat anotherProgressInset;
@property (nonatomic, strong) UIColor *anotherTrackColor;

@property (nonatomic, copy) ProgressSlidingBlock slidingBlock;
@property (nonatomic, assign) LTPeogressSliderState lt_state;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
