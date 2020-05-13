//
//  ViewController.h
//  2048
//
//  Created by sameenshi on 2020/5/8.
//  Copyright © 2020 sameenshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCell.h"
#import "SnowView.h"

@interface ViewController : UIViewController

//raymone:属性的定义要添加注释，注释规范见oc规范
//raymone:空格和换行要多使用

//2048的view
@property (nonatomic, strong) UICollectionView *my2048;
//游戏结束时的动画
@property (nonatomic, strong) SnowView *forGameOver;
//用来存储每个cell应该显示的数字，0就不显示，所以初始化随机选择两个index初始化为2，其他为0
@property (nonatomic, strong) NSMutableArray *cellList;
//用来存储每个数字对应的背景颜色
@property (nonatomic, strong) NSDictionary *numberToColor;
//以下四个为手势
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerRight;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerUp;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerDown;
//在检测到有滑动手势时，逻辑是先融合，后移动
//根据滑动手势来找到哪些可以融合，比如向下滑动的时候，第三行第一列可以和第四行第一列发生融合，（第三行应该是第一个被检查的，
//然后再检查第二行，然后再检查第一行）于是第三行第一列的元素和第四行第一列的元素发生融合，第四行第一列的数字翻倍，此时有个问题，
//当检查到第二行的时候，如果第二行第一列的数字可以和已经翻倍的第四行第一列的元素融合，这是不应该的，应该记录下来第四行第一列的元素已经
//融合过了，那么第二行第一列的元素就不会再和第四行第一列的元素融合了，所以这个数组是用来存储相应index上的元素是否融合过
@property (nonatomic, strong) NSMutableArray *isModified;
//这个数组是用来存储_cellList哪些index的元素为0，因为在发生融合或者有元素移动位置的时候要添加一个元素，如果直接在0-15之间随机
//生成一个数字作为index来将index相应的元素置为2或4，那么就得判断这个随机生成的index，cellList[index]元素是否为0，不为0需要
//重新生成，所以用一个数组把cellList中所有元素为0的index存储下来，这样需要添加一个元素时，随机生成0-reserveZero.count-1的数字，
//将这个数字作为index取出reserveZero[index]，而reserveZero[index]是cellList中元素为0的index，将该index相应的元素置为2和4即可
@property (nonatomic, strong) NSMutableArray *reserveZero;
//这个button在游戏结束的时候会显示出来
@property (nonatomic, strong) UIButton *toDisplay;
//raymone:@property要添加上修饰符
//这个用来定义是否发生了元素移动或者融合
@property (nonatomic, assign) BOOL flag;

//raymone:方法的定义要添加注释
//这个方法用来初始化cellList，isModified，reserveZero
-(void)initData;
//这个方法根据手势作出相应的回应
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
@end

