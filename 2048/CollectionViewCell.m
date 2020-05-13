//
//  CollectionViewCell.m
//  2048
//
//  Created by sameenshi on 2020/5/8.
//  Copyright © 2020 sameenshi. All rights reserved.
//

#import "CollectionViewCell.h"
@interface CollectionViewCell  ()
@property(nonatomic,strong) UILabel *number;
@end

@implementation CollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        [self setupView];
    }
    return self;
}
-(void)setupView{
    _number=[[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/6.0,self.bounds.size.height/6.0, self.bounds.size.width/3.0*2, self.bounds.size.height/3.0*2)];
    //_number.text=@"0";
    [self.contentView addSubview:_number];
}

- (void)setupNum:(NSString *)num setupColor:(UIColor *)color
{
    self.number.text=num;
    self.backgroundColor=color;
    self.hidden=NO;
    if([self.number.text isEqualToString:@"0"]){
        self.hidden=YES;
    }
}

@end
