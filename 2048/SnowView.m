//
//  snowView.m
//  2048
//
//  Created by sameenshi on 2020/5/9.
//  Copyright © 2020 sameenshi. All rights reserved.
//

#import "SnowView.h"

@interface SnowView ()

@property(nonatomic,strong) CAEmitterLayer *snowLayer;
@property(nonatomic,strong) CAGradientLayer *gradientLayer;
//@property(nonatomic,strong) UIButton *toDisplay;

@end

@implementation SnowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createGradientLayer];
        [self createSnowLayer];
        //[self createButton];
    }
    self.hidden=YES;
    return self;
}

- (void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _gradientLayer.frame = self.bounds;
    _snowLayer.frame = self.bounds;
    [CATransaction commit];

    [super layoutSubviews];
}

- (void)createGradientLayer
{
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.startPoint = CGPointMake(1, 0.5);
    _gradientLayer.endPoint = CGPointMake(0, 0.5);
    _gradientLayer.colors = @[ (__bridge id)[UIColor colorWithRed:0 green:0.63 blue:1 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:1].CGColor ];
    _gradientLayer.locations = @[ @(0.0f), @(1.0f) ];
    [self.layer addSublayer:_gradientLayer];
}

- (void)createSnowLayer
{
    _snowLayer = [CAEmitterLayer layer];
    _snowLayer.frame = self.bounds;
    _snowLayer.masksToBounds = YES;
    _snowLayer.emitterPosition = CGPointMake(self.frame.size.width / 2.0, -30);
    _snowLayer.emitterSize = CGSizeMake(self.frame.size.width, 0);
    _snowLayer.emitterShape = kCAEmitterLayerLine;
    _snowLayer.emitterMode = kCAEmitterLayerSurface;
    _snowLayer.renderMode = @"oldestLast";

    CAEmitterCell* snowflake = [CAEmitterCell emitterCell];

    snowflake.birthRate = 2; 
    snowflake.lifetime = 120;
    snowflake.alphaRange = 1;
    snowflake.scaleRange = 0.5;
    snowflake.lifetimeRange = 20;
    snowflake.velocity = 0;
    snowflake.velocityRange = 100;
    snowflake.xAcceleration = 0;
    snowflake.yAcceleration = 0;
    snowflake.emissionRange = 0.5 * M_PI;

    snowflake.contents = (id)[UIImage imageNamed:@"snow.png"].CGImage;

    _snowLayer.emitterCells = [NSArray arrayWithObject:snowflake];
    [self.layer insertSublayer:_snowLayer above:_gradientLayer];
}

//-(void) createButton{
//     _toDisplay= [UIButton buttonWithType:UIButtonTypeRoundedRect];
//     [_toDisplay setFrame:CGRectMake(60, 300, 200, 40)];
//     [_toDisplay setTitle:@"restart" forState:UIControlStateNormal];
//     [_toDisplay addTarget:self action:@selector(hideSnowView:)
//    forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_toDisplay];
//}
//-(IBAction)hideSnowView:(id)sender{
//    self.hidden=YES;
//}
-(void)displayView{
    self.hidden=NO;
}
-(void)hideView{
    self.hidden=YES;
}
@end
