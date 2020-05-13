//
//  CollectionViewCell.h
//  2048
//
//  Created by sameenshi on 2020/5/8.
//  Copyright © 2020 sameenshi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell

-(void)setupView;
-(void)setupNum:(NSString *)num setupColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
