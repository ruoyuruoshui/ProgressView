//
//  LTProgressSlider.m
//  LTProgressSlider
//
//  Created by 陈记权 on 11/16/15.
//  Copyright © 2015 陈记权. All rights reserved.
//

#import "LTProgressSlider.h"

#define kNeedDisplayKey @"ltProgress"

static CGFloat const kSliderIconWidth = 50.0f;

void addRoundRectPathInContext(CGContextRef context, CGRect rect, CGFloat radius)
{
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    
    CGContextClosePath(context);
}

void strokeRoundedRectInContext(CGContextRef context, CGRect rect, CGFloat lineWidth, CGFloat radius)
{
    CGContextSetLineWidth(context, lineWidth);
    addRoundRectPathInContext(context, rect, radius);
    CGContextStrokePath(context);
}

void fillRoundedRectInContext(CGContextRef context, CGRect rect , CGFloat radius)
{
    addRoundRectPathInContext(context, rect, radius);
    CGContextFillPath(context);
}

@interface LTProgressSliderLayer : CAShapeLayer
{
    CAShapeLayer *m_sliderLayer;
    CAShapeLayer *m_imageLayer;
}

@property (nonatomic, assign) CGFloat ltProgress;
@property (nonatomic, assign) CGFloat horizontallyInset;
@property (nonatomic, assign) CGFloat verticalInset;
@property (nonatomic, strong) UIColor *progressBgColor;
@property (nonatomic, strong) UIColor *outerBorderColor;
@property (nonatomic, assign) CGFloat outerBorderWidth;
@property (nonatomic, assign) CGFloat progressInset;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, assign) BOOL suportDoubleProgress;
@property (nonatomic, assign) CGFloat anotherProgress;
@property (nonatomic, assign) CGFloat anotherProgressInset;
@property (nonatomic, strong) UIColor *anotherTrackColor;

- (void)setStateLayerImage:(NSString *)image;
- (void)setDecorateLayerImage:(NSString *)image;

@end

@implementation LTProgressSliderLayer

@dynamic progressBgColor;
@dynamic verticalInset;
@dynamic horizontallyInset;
@dynamic outerBorderWidth;
@dynamic outerBorderColor;

@dynamic progressInset;
@dynamic trackColor;

@dynamic suportDoubleProgress;
@dynamic anotherProgressInset;
@dynamic anotherTrackColor;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:kNeedDisplayKey] ? YES : [super needsDisplayForKey:key];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        m_sliderLayer = [CAShapeLayer layer];
        m_sliderLayer.frame = CGRectMake(0, 0, kSliderIconWidth, kSliderIconWidth);
        
        [self addSublayer:m_sliderLayer];
        
        m_imageLayer = [CAShapeLayer layer];
        
        [self addSublayer:m_imageLayer];
        
        [self setDecorateLayerImage:@"progress_decorate_normal"];
        [self setStateLayerImage:@"progress_pause_icon"];
    }
    return self;
}

- (void)setStateLayerImage:(NSString *)image
{
    m_imageLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:image].CGImage);
}

- (void)setDecorateLayerImage:(NSString *)image
{
    m_sliderLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:image].CGImage);
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    CGRect drawRect = [self getDrawRect];
    CGFloat radius = 0;
    
    if (self.outerBorderColor && self.outerBorderWidth > 0 ) {
        CGFloat hlw = self.outerBorderWidth / 2.0f;
        drawRect = CGRectInset(drawRect, hlw, hlw);
        radius = CGRectGetHeight(drawRect) / 2.0f;
        CGContextSetStrokeColorWithColor(ctx, self.outerBorderColor.CGColor);
        strokeRoundedRectInContext(ctx, drawRect, self.outerBorderWidth, radius);
        drawRect = CGRectInset(drawRect, hlw, hlw);
    }
    
    if(self.progressBgColor){
        radius = CGRectGetHeight(drawRect) / 2.0f;
        CGContextSetFillColorWithColor(ctx, self.progressBgColor.CGColor);
        fillRoundedRectInContext(ctx, drawRect, radius);
    }
    
    if (self.suportDoubleProgress && self.anotherTrackColor) {
        CGRect anotherTrackRect = CGRectInset(drawRect, self.anotherProgressInset, self.anotherProgressInset);
        CGFloat progressWidth = (CGRectGetWidth(anotherTrackRect) - CGRectGetHeight(anotherTrackRect)) * self.anotherProgress + CGRectGetHeight(anotherTrackRect);
        anotherTrackRect.size.width = progressWidth;
        radius = CGRectGetHeight(anotherTrackRect) / 2.0f;
        CGContextSetFillColorWithColor(ctx, self.anotherTrackColor.CGColor);
        fillRoundedRectInContext(ctx, anotherTrackRect, radius);
    }
    
    if (self.trackColor) {
        CGRect trackRect = CGRectInset(drawRect, self.progressInset, self.progressInset);
        CGFloat progressWidth = (CGRectGetWidth(trackRect) - CGRectGetHeight(trackRect)) * self.ltProgress + CGRectGetHeight(trackRect);
        trackRect.size.width = progressWidth;
        radius = CGRectGetHeight(trackRect) / 2.0f;
        CGContextSetFillColorWithColor(ctx, self.trackColor.CGColor);
        fillRoundedRectInContext(ctx, trackRect, radius);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        m_sliderLayer.position = CGPointMake(CGRectGetMaxX(trackRect) - radius, CGRectGetHeight(self.bounds) / 2.0f);
        m_imageLayer.bounds = CGRectMake(0, 0, ceil(2 * radius) + 1 , ceil(2 * radius) + 1);
        m_imageLayer.position = CGPointMake(CGRectGetMaxX(trackRect) - radius, CGRectGetHeight(self.bounds) / 2.0f);
        [CATransaction commit];
    }
}

- (CGRect)getDrawRect
{
    CGRect o_bounds = self.bounds;
    o_bounds =  CGRectInset(o_bounds, self.horizontallyInset * 2, self.verticalInset * 2);
    return o_bounds;
}

@end

@interface LTProgressSlider ()
{
    LTPeogressSliderState m_preState;
}

@end

@implementation LTProgressSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self defaultInit];
}

- (void)defaultInit
{
    self.horizontallyInset = 4.0f;
    self.verticalInset = 4.0f;
    self.outerBorderColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    self.outerBorderWidth = 4.0f;
    
    self.trackColor = [UIColor yellowColor];
    self.anotherTrackColor = [UIColor colorWithWhite:0.9 alpha:0.7];
}

- (CGFloat)horizontallyInset
{
    return self.progressLayer.horizontallyInset;
}

- (void)setHorizontallyInset:(CGFloat)horizontallyInset
{
    if (self.horizontallyInset != horizontallyInset) {
        self.progressLayer.horizontallyInset = horizontallyInset;
        [self.progressLayer setNeedsDisplay];
    }
}

- (CGFloat)verticalInset
{
    return self.progressLayer.verticalInset;
}

- (void)setVerticalInset:(CGFloat)verticalInset
{
    if (self.verticalInset != verticalInset) {
        self.progressLayer.verticalInset = verticalInset;
        [self.progressLayer setNeedsDisplay];
    }
}

- (UIColor *)progressBgColor
{
    return self.progressLayer.progressBgColor;
}

- (void)setProgressBgColor:(UIColor *)progressBgColor
{
    if (![self.progressBgColor isEqual:progressBgColor]) {
        self.progressLayer.progressBgColor = progressBgColor;
        [self.progressLayer setNeedsDisplay];
    }
}

- (UIColor *)outerBorderColor
{
    return self.progressLayer.outerBorderColor;
}

- (void)setOuterBorderColor:(UIColor *)outerBorderColor
{
    if (![self.outerBorderColor isEqual:outerBorderColor]) {
        self.progressLayer.outerBorderColor = outerBorderColor;
        [self.progressLayer setNeedsDisplay];
    }
}

- (CGFloat)outerBorderWidth
{
    return self.progressLayer.outerBorderWidth;
}

- (void)setOuterBorderWidth:(CGFloat)outerBorderWidth
{
    if (self.outerBorderWidth != outerBorderWidth) {
        self.progressLayer.outerBorderWidth = outerBorderWidth;
        [self.progressLayer setNeedsDisplay];
    }
}

- (CGFloat)progressInset
{
    return [self progressLayer].progressInset;
}

- (void)setProgressInset:(CGFloat)progressInset
{
    if (self.progressInset != progressInset) {
        self.progressLayer.progressInset = progressInset;
        [self.progressLayer setNeedsDisplay];
    }
}

- (UIColor *)trackColor
{
    return self.progressLayer.trackColor;
}

- (void)setTrackColor:(UIColor *)trackColor
{
    if (![self.trackColor isEqual:trackColor]) {
        self.progressLayer.trackColor = trackColor;
        [self.progressLayer setNeedsDisplay];
    }
}

- (CGFloat)anotherProgressInset
{
    return [self progressLayer].anotherProgressInset;
}

- (void)setAnotherProgressInset:(CGFloat)anotherProgressInset
{
    if (self.anotherProgressInset != anotherProgressInset) {
        self.progressLayer.anotherProgressInset = anotherProgressInset;
        [self.progressLayer setNeedsDisplay];
    }
}

- (UIColor *)anotherTrackColor
{
    return self.progressLayer.anotherTrackColor;
}

- (void)setAnotherTrackColor:(UIColor *)anotherTrackColor
{
    if (![self.trackColor isEqual:anotherTrackColor]) {
        self.progressLayer.anotherTrackColor = anotherTrackColor;
        [self.progressLayer setNeedsDisplay];
    }
}

- (BOOL)suportDoubleProgress
{
    return self.progressLayer.suportDoubleProgress;
}

- (void)setSuportDoubleProgress:(BOOL)suportDoubleProgress
{
    if (self.suportDoubleProgress != suportDoubleProgress) {
        self.progressLayer.suportDoubleProgress = suportDoubleProgress;
        [self.progressLayer setNeedsDisplay];
    }
}

- (void)didMoveToWindow
{
    self.progressLayer.contentsScale = self.window.screen.scale;
}

+ (Class)layerClass
{
    return [LTProgressSliderLayer class];
}

- (LTProgressSliderLayer *)progressLayer
{
    return (LTProgressSliderLayer *)self.layer;
}

- (CGFloat)progress
{
    return self.progressLayer.ltProgress;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self.progressLayer removeAnimationForKey:kNeedDisplayKey];
    
    CGFloat pinnedProgress = fmaxf(0.0f, fminf(1.0f, progress));
    if (pinnedProgress != self.progress) {
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kNeedDisplayKey];
            animation.duration = 0.025;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.fromValue = [NSNumber numberWithFloat:self.progress];
            animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
            [self.progressLayer addAnimation:animation forKey:kNeedDisplayKey];
        } else {
            [self.progressLayer setNeedsDisplay];
        }
        self.progressLayer.ltProgress = pinnedProgress;
    } else {
        [self.progressLayer setNeedsDisplay];
    }
}

- (void)setAnotherProgress:(CGFloat)anotherProgress
{
    [self.progressLayer removeAnimationForKey:kNeedDisplayKey];
    CGFloat pinnedProgress = fmaxf(0.0f, fminf(1.0f, anotherProgress));
    self.progressLayer.anotherProgress = pinnedProgress;
    [self.progressLayer setNeedsDisplay];
}

- (CGFloat)getDeltaProgressWithOffset:(CGFloat)deltaOffset
{
    CGFloat progressLength = CGRectGetWidth(self.bounds) - 2 * (self.horizontallyInset + self.outerBorderWidth);
    
    CGFloat deltaProgress = deltaOffset / progressLength;
    return deltaProgress;
}

static BOOL shouldBeighSlide = NO;

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL beign = [super beginTrackingWithTouch:touch withEvent:event];
    shouldBeighSlide = NO;
    
    CGPoint hitPoint = [touch locationInView:self.superview];
    CALayer *hitLayer = [self.progressLayer.presentationLayer hitTest:hitPoint];
    if (hitLayer && ![hitLayer isKindOfClass:[LTProgressSliderLayer class]]) {
        shouldBeighSlide = YES;
        [self saveState];
        self.lt_state = LTPeogressSliderStateDefault;
    }
    return beign;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL ct = [super continueTrackingWithTouch:touch withEvent:event];
    if (shouldBeighSlide) {
        CGPoint prePoint = [touch previousLocationInView:self];
        CGPoint location = [touch locationInView:self];
        CGFloat deltaProgress = [self getDeltaProgressWithOffset:(location.x - prePoint.x)];
        
        self.lt_state = LTPeogressSliderStateSliding;
        CGFloat progress = MAX(MIN(self.progress + deltaProgress, 1), 0.0f) ;
        [self setProgress:progress];
        if (_slidingBlock) {
            _slidingBlock(progress);
        }
    }
    
    return ct;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    if (_lt_state != LTPeogressSliderStateSliding) {
        [self recorverState];
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self recorverState];
    }
    
    shouldBeighSlide = NO;
}

- (void)saveState
{
    if (_lt_state != LTPeogressSliderStateSliding && _lt_state != LTPeogressSliderStateDefault) {
        m_preState = _lt_state;
    }
}

- (void)recorverState
{
    self.lt_state = m_preState;
    m_preState = LTPeogressSliderStateDefault;
}

- (void)setLt_state:(LTPeogressSliderState)lt_state
{
    if (_lt_state != lt_state) {
        _lt_state = lt_state;
        [self changeImageWithState:_lt_state];
    }
}

- (void)changeImageWithState:(LTPeogressSliderState)state
{
    switch (state) {
        case LTPeogressSliderStateSliding:
        {
            [self.progressLayer setDecorateLayerImage:@"progress_decorate_highlighted"];
            [self.progressLayer setStateLayerImage:@"progress_sliding_icon"];
        }
            break;
        case LTPeogressSliderStatePlaying:
        {
            [self.progressLayer setDecorateLayerImage:@"progress_decorate_normal"];
            [self.progressLayer setStateLayerImage:@"progress_play_icon"];
        }
            break;
            
        case LTPeogressSliderStatePaused:
        {
            [self.progressLayer setDecorateLayerImage:@"progress_decorate_normal"];
            [self.progressLayer setStateLayerImage:@"progress_pause_icon"];
        }
            break;
            
        default:
        {
            [self.progressLayer setDecorateLayerImage:@"progress_decorate_normal"];
            [self.progressLayer setStateLayerImage:@"progress_pause_icon"];
        }
            break;
    }
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}

+ (UIColor *)defaultBarColor
{
    return [UIColor yellowColor];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (event) {
        return;
    }
    [super sendAction:action to:target forEvent:event];
}

@end
