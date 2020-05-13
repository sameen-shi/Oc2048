//
//  ViewController.m
//  2048
//
//  Created by sameenshi on 2020/5/8.
//  Copyright © 2020 sameenshi. All rights reserved.
//

#import "ViewController.h"

//raymone:常量如果是只在本文件内使用，建议加上static修饰
//raymone:空格和换行要多使用
//raymone:代码架构的评析：
//  整体上，是把所有的业务逻辑都放到ViewController里面，是典型的MVC架构，有个弊端就是会让ViewController臃肿。
//  更好的方式是，把业务数据逻辑的处理放到另一个类中去处理。建议使用MVP或者MVVM的方式来写。
//      好处是:1、ViewController精简，只承担数据和View的桥梁作用
//            2、业务逻辑代码与UI分离，易于维护和扩展。即如果逻辑层有变(例如重构或者需求变更)，不需要对UI的类大动。
//            3、更易于对UI类型去写测试用例，可直接对业务逻辑类进行功能相关的测试用例覆盖。
static NSString * const reuseidentifier = @"cell";

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _flag = NO;
    _reserveZero = [[NSMutableArray alloc] initWithCapacity:16];
    [self initData];
    [self setupGestures];
    [self setupLines];
    [self setupCollectionView];
    [self.view addSubview:_my2048];
    
    _forGameOver = [[SnowView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [self.view addSubview:_forGameOver];
    
    [self createButton];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - init setup
//创建游戏结束的button
- (void)createButton {
     _toDisplay= [UIButton buttonWithType:UIButtonTypeSystem];
    [_toDisplay setFrame:CGRectMake(self.view.bounds.size.width/2.0-50, self.view.bounds.size.height/2.0-25, 100, 50)];
    [_toDisplay setTitle:@"restart" forState:UIControlStateNormal];
    [_toDisplay addTarget:self action:@selector(hideSnowView:) forControlEvents:UIControlEventTouchUpInside];
    _toDisplay.backgroundColor = [UIColor redColor];
    [self.view addSubview:_toDisplay];
    _toDisplay.hidden = YES;

}
//这个函数在游戏结束时调用，雪花飘的动画和restart按钮会出现
- (void)restart {
    _toDisplay.hidden = NO;
    [_forGameOver displayView];
}

//这个函数在restart按钮按下之后会执行，用来隐藏动画和按钮，同时重新给数组赋值，开始一轮新游戏
- (void)hideSnowView:(id)sender {
    [_forGameOver hideView];
    _toDisplay.hidden = YES;
    [self reInitData];
    [self.my2048 reloadData];
}
//这个函数用来注册手势
- (void)setupGestures {
    _recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    _recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    _recognizerUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    _recognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [_recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:_recognizerRight];
    [_recognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:_recognizerLeft];
    [_recognizerUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.view addGestureRecognizer:_recognizerUp];
    [_recognizerDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:_recognizerDown];
}
//这个函数用来初始化collectionview
- (void)setupCollectionView {
    UICollectionViewFlowLayout *myLayout = [[UICollectionViewFlowLayout alloc] init];
    myLayout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width-50)/4.0, ([UIScreen mainScreen].bounds.size.width-50)/4.0);
    myLayout.minimumInteritemSpacing = 10;
    myLayout.minimumLineSpacing = 10;
    self.my2048 = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width-20,
                                                                     [UIScreen mainScreen].bounds.size.width-20)
                                     collectionViewLayout:myLayout];
    //这两个循环用来给collectionview的cell之间添加一个分隔线，横向和纵向各三条
    for (int i = 0; i < 3; i++) {
        UIView *temp = [[UIView alloc]initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.width-50)/4.0*(i+1)+10*i,
                                                               [UIScreen mainScreen].bounds.size.width-20, 10)];
        temp.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        [self.my2048 addSubview:temp];
    }
    for (int i = 0; i < 3; i++) {
        UIView *temp = [[UIView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-50)/4.0*(i+1)+10*i, 0, 10,
                                                               [UIScreen mainScreen].bounds.size.width-20)];
        temp.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        [self.my2048 addSubview:temp];
    }
    [self.my2048 registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseidentifier];
    self.my2048.backgroundColor = [UIColor whiteColor];
    self.my2048.delegate = self;
    self.my2048.dataSource = self;
}
//这个函数用来给collectionview添加边框，横向和纵向各两条
- (void)setupLines {
    //raymone:临时变量名称的定义最好有一定的意义，能直观看出含义。
    UIView *leftVertical = [[UIView alloc] initWithFrame:CGRectMake(0,90,10,[UIScreen mainScreen].bounds.size.width)];
    leftVertical.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];

    UIView *rightVertical = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-10,90,10,[UIScreen mainScreen].bounds.size.width)];
    rightVertical.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    [self.view addSubview:leftVertical];
    [self.view addSubview:rightVertical];
    
    UIView *upLevel = [[UIView alloc]initWithFrame:CGRectMake(10,90,[UIScreen mainScreen].bounds.size.width-20,10)];
    upLevel.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [self.view addSubview:upLevel];
    
     UIView *downLevel = [[UIView alloc]initWithFrame:CGRectMake(10,80+[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-20,10)];
    downLevel.backgroundColor= [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [self.view addSubview:downLevel];
}


//这个函数用来初始化存储数字对应的颜色的字典，数字作为key，颜色作为value
- (NSDictionary *)colorDictionary
{
    UIColor *For2 = [UIColor colorWithRed:239/255.0 green:246/255.0 blue:224/255.0 alpha:1];
    UIColor *For4 = [UIColor colorWithRed:89/255.0 green:131/255.0 blue:146/255.0 alpha:1];
    UIColor *For8 = [UIColor colorWithRed:255/255.0 green:180/255.0 blue:162/255.0 alpha:1];
    UIColor *For16 = [UIColor colorWithRed:109/255.0 green:104/255.0 blue:117/255.0 alpha:1];
    UIColor *For32 = [UIColor colorWithRed:181/255.0 green:131/255.0 blue:141/255.0 alpha:1];
    UIColor *For64 = [UIColor colorWithRed:5/255.0 green:102/255.0 blue:141/255.0 alpha:1];
    UIColor *For128 = [UIColor colorWithRed:0/255.0 green:168/255.0 blue:150/255.0 alpha:1];
    UIColor *For256 = [UIColor colorWithRed:240/255.0 green:243/255.0 blue:189/255.0 alpha:1];
    UIColor *For512 = [UIColor colorWithRed:243/255.0 green:114/255.0 blue:44/255.0 alpha:1];
    UIColor *For1024 = [UIColor colorWithRed:219/255.0 green:205/255.0 blue:240/255.0 alpha:1];
    UIColor *For2048 = [UIColor colorWithRed:249/255.0 green:198/255.0 blue:201/255.0 alpha:1];
    
    NSDictionary *dict = @{
        @"2" : For2,
        @"4" : For4,
        @"8" : For8,
        @"16" : For16,
        @"32" : For32,
        @"64" : For64,
        @"128" : For128,
        @"256" : For256,
        @"512" :For512,
        @"1024" :For1024,
        @"2048" :For2048,
    };
    
    return dict;
}
//这个方法用来初始化cellList，isModified，reserveZero
- (void)initData {
    _cellList = [[NSMutableArray alloc] init];
    for (int i =0; i < 16; i++) {
        [_cellList addObject:@"0"];
        _reserveZero[i] = [NSString stringWithFormat:@"%d",i];
    }
    
    _isModified = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        [_isModified addObject:@"0"];
    }
    
    int tempOne = arc4random()%16;
    _cellList[tempOne] = @"2";
    [_reserveZero removeObject:[NSString stringWithFormat:@"%d",tempOne]];
    while (true)
    {
        int tempTwo = arc4random()%16;
        if (tempTwo != tempOne) {
            _cellList[tempTwo] = @"2";
            [_reserveZero removeObject:[NSString stringWithFormat:@"%d",tempTwo]];
            break;
        }
    }
    _numberToColor = [self colorDictionary];
}
//这个函数用来开始一轮新游戏的时候,重新给cellList，isModified，reserveZero赋值
- (void)reInitData {
    for (int i = 0;i < 16; i++) {
        _cellList[i] = @"0";
        _reserveZero[i] = [NSString stringWithFormat:@"%d", i];
    }
    
    int tempOne = arc4random()%16;
    _cellList[tempOne] = @"2";
    [_reserveZero removeObject:[NSString stringWithFormat:@"%d",tempOne]];
    while (true)
    {
        int tempTwo = arc4random()%16;
        if (tempTwo != tempOne){
            _cellList[tempTwo] = @"2";
            [_reserveZero removeObject:[NSString stringWithFormat:@"%d",tempTwo]];
            break;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cellList.count;
}
//cell的数字，颜色等，数字大于2048设置为黑色
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [_my2048 dequeueReusableCellWithReuseIdentifier:reuseidentifier forIndexPath:indexPath];
    if ([_cellList[indexPath.row] intValue] > 2048){
        [cell setupNum:_cellList[indexPath.row] setupColor:[UIColor blackColor]];
    } else {
        [cell setupNum:_cellList[indexPath.row] setupColor:[_numberToColor valueForKey:_cellList[indexPath.row]]];
    }
    return cell;
}

#pragma mark - other
 
//raymone:这里每个case内的处理都有抽出到一个方法中，避免圈复杂度过大。
//这四个函数是用来根据手势来找到某一行某一列的元素中间全部为0相距最远的元素为0的位置
//也就是说根据手势移动的时候，某一行某一列元素应该移到何处
- (NSInteger)downMove:(NSInteger)numberInRow {
    int i = 1;
    while ((numberInRow+4*i)/4 != 3)
    {
        if (![_cellList[numberInRow+4*i] isEqualToString:@"0"]) {
            return numberInRow + 4 * i - 4;
        }
        i++;
    }
    if ([_cellList[numberInRow+4*i] isEqualToString:@"0"]) {
        return numberInRow + 4 * i;
    } else {
        return numberInRow + 4 * i - 4;
    }
}

- (NSInteger)upMove:(NSInteger)numberInRow {
    int i = 1;
    while ((numberInRow-4*i)/4 != 0)
    {
        if (![_cellList[numberInRow-4*i] isEqualToString:@"0"]) {
            return numberInRow - 4 * i + 4;
        }
        i++;
    }
    if ([_cellList[numberInRow-4*i] isEqualToString:@"0"]){
        return numberInRow - 4 * i;
    } else {
        return numberInRow - 4 * i + 4;
    }
}

- (NSInteger)leftMove:(NSInteger)numberInRow {
    int i = 1;
    while ((numberInRow-i)%4 != 0){
        if (![_cellList[numberInRow-i] isEqualToString:@"0"]) {
            return numberInRow - i + 1;
        }
        i++;
    }
    if ([_cellList[numberInRow-i] isEqualToString:@"0"]) {
        return numberInRow - i;
    } else {
        return numberInRow - i + 1;
    }
}

- (NSInteger)rightMove:(NSInteger)numberInRow {
    int i = 1;
    while ((numberInRow+i)%4 != 3)
    {
        if (![_cellList[numberInRow+i] isEqualToString:@"0"]) {
            return numberInRow + i - 1;
        }
        i++;
    }
    if ([_cellList[numberInRow+i] isEqualToString:@"0"]){
        return numberInRow + i;
    } else {
        return numberInRow + i - 1;
    }
}

- (NSInteger)toFindLast:(NSInteger)numberInRow WithDirection:(NSString *)direction
{
    
    NSInteger result = 0;
    if ([direction isEqualToString:@"Down"])
    {
        //这里的实现抽出到方法中去
        result = [self downMove:numberInRow];
    }
    
    else if ([direction isEqualToString:@"Up"])
    {
        //这里的实现抽出到方法中去
        result = [self upMove:numberInRow];
    }
    
    else if ([direction isEqualToString:@"Left"])
    {
        //这里的实现抽出到方法中去
        result = [self leftMove:numberInRow];
        
    }
    
    else if ([direction isEqualToString:@"Right"])
    {
        //这里的实现抽出到方法中去
        result = [self rightMove:numberInRow];
        
    }
    return result;
}

//这个函数用来判断
//每个元素只需要和它右边，下边的元素对比，是否相等，全都不相等则返回true（第四列只需和下面的元素对比）
//并且只需判断前三行的元素
//所以游戏结束的条件是reserveZero为空并且该函数返回true
- (BOOL)isGameOver
{
    for (int i = 0; i < 12; i++)
    {
        if (i%4 == 3) {
            if ([_cellList[i] isEqualToString:_cellList[i+4]]) {
                return NO;
            }
        } else if ([_cellList[i] isEqualToString:_cellList[i+4]] || [_cellList[i] isEqualToString:_cellList[i+1]]) {
            return NO;
        }
    }
    
    return YES;
}

//raymone:方法的命名要以小写字母开头
//这个函数用来随机生成一个元素为0的index，然后cellList[index]赋值为2，同时从_reserveZero移除该index
- (void)randomGenerate {
    int temp = arc4random()%(_reserveZero.count);
    _cellList[[_reserveZero[temp] intValue]] = @"2";
    [_reserveZero removeObject:_reserveZero[temp]];
}
//这个方法根据手势作出相应的回应
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self handleDown];
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self handleUp];
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self handleLeft];
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self handleRight];
    }
    
    for (int i = 0; i < 16; i++) {
        if ([_isModified[i] isEqualToString:@"1"]) {
            _isModified[i]=@"0";
        }
    }
//在融合和移动结束之后，判断是否出现了元素融合或者移动，出现了的话要添加一个新的数字为2的元素
    if (self.flag) {
        [self randomGenerate];
        self.flag=NO;
    }
    
    [self.my2048 reloadData];
//判断是否游戏结束
    if (_reserveZero.count == 0 && [self isGameOver]) {
        [self restart];
    }
}
//处理手势向下的逻辑
- (void)handleDown
{
    //raymone:复杂的计算逻辑，可以添加注释来辅助说明，便于其他人理解。
    //先融合
    //从第一列开始，第一列从第三行开始，找到离自己最近的不为0的元素（就是toFindLast:WithDirection:这个函数的返回值加1）
    //与这个元素的数字对比，如果两个数字相等，那么处于下方的元素的数字就要翻倍，并且相应index的_isModified要置为1，
    //代表该元素已经发生过融合了，处于上方的元素的数字就要置为0
    for (int i = 0; i < 4; i++)
    {
        for (int j = 2; j >= 0; j--)
        {
            NSInteger temp = [self toFindLast:4*j+i WithDirection:@"Down"];
            if (temp < 12 && [_cellList[4*j+i] isEqualToString:_cellList[temp+4]] && [_isModified[temp+4] isEqualToString:@"0"]) {
                self.flag = YES;
                _cellList[temp+4] = [NSString stringWithFormat:@"%d",([_cellList[temp+4] intValue]*2)];
                _cellList[4*j+i] = @"0";
                _reserveZero[_reserveZero.count] = [NSString stringWithFormat:@"%d",4*j+i];
                _isModified[temp+4] = @"1";
            }
        }
    }
    //再移动
    //移动就是找到自己中间全部为0相距最远的元素为0的位置，代表着移动的时候应该移动到的位置，然后自己的位置置为0，找到的最远的位置置为自己的数字
    //这样做是因为第三行移动到第四行的时候，第二行可以移到第三行来。
    //也是每一列要先从第三行开始检查
    for (int i = 0; i < 4; i++)
    {
        for (int j = 2; j >= 0; j--)
        {
            if (![_cellList[4*j+i] isEqualToString:@"0"]) {
                NSInteger temp = [self toFindLast:4*j+i WithDirection:@"Down"];
                if (temp != 4*j+i) {
                    self.flag = YES;
                    NSString *tempString = _cellList[4*j+i];
                    _cellList[4*j+i]=@"0";
                    _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
                    _cellList[temp]=tempString;
                    [_reserveZero removeObject:[NSString stringWithFormat:@"%ld",(long)temp]];
                }
            }
        }
    }
}

//raymone:这里的代码空格和分行也按照上面的处理一下，复杂的逻辑用注释辅助说明
//下的处理逻辑和上一样，就是要先从第二行开始检查
- (void)handleUp
{
    for (int i=0;i<4;i++) {
        for (int j=1;j<4;j++) {
            NSInteger temp=[self toFindLast:4*j+i WithDirection:@"Up"];
            
                if (temp>3 && [_cellList[4*j+i] isEqualToString:_cellList[temp-4]] && [_isModified[temp-4] isEqualToString:@"0"])
                {
                self.flag=YES;
                _cellList[temp-4]=[NSString stringWithFormat:@"%d",([_cellList[temp-4] intValue]*2)];
                _cellList[4*j+i]=@"0";
                _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
                _isModified[temp-4]=@"1";
            }
        }
    }
    for (int i=0;i<4;i++) {
        for (int j=1;j<4;j++) {
             if (![_cellList[4*j+i] isEqualToString:@"0"]) {
                 NSInteger temp=[self toFindLast:4*j+i WithDirection:@"Up"];
                 if (temp!=4*j+i) {
                     self.flag=YES;
                     NSString *tempString=_cellList[4*j+i];
                     _cellList[4*j+i]=@"0";
                     _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
                     _cellList[temp]=tempString;
                     [_reserveZero removeObject:[NSString stringWithFormat:@"%ld",(long)temp]];
                }
            }
        }
    }
}

//raymone:这里的代码空格和分行也按照上面的处理一下，复杂的逻辑用注释辅助说明
//左的逻辑也和下的一样，就是要先从第二列检查
- (void) handleLeft{
    for (int i=1;i<4;i++) {
        for (int j=0;j<4;j++) {
            NSInteger temp=[self toFindLast:4*j+i WithDirection:@"Left"];
            if (temp%4!=0 && [_isModified[temp-1] isEqualToString:@"0"] && [_cellList[4*j+i] isEqualToString:_cellList[temp-1]])
            {
                self.flag=YES;
                _cellList[temp-1]=[NSString stringWithFormat:@"%d",([_cellList[temp-1] intValue]*2)];
                _cellList[4*j+i]=@"0";
                _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
                _isModified[temp-1]=@"1";
            }
        }
    }
    for (int i=1;i<4;i++) {
        for (int j=0;j<4;j++) {
             if (![_cellList[4*j+i] isEqualToString:@"0"]) {
                 NSInteger temp=[self toFindLast:4*j+i WithDirection:@"Left"];
                 if (temp!=4*j+i)
                 {
                     self.flag=YES;
                     NSString *tempString=_cellList[4*j+i];
                     _cellList[4*j+i]=@"0";
                     _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
                     _cellList[temp]=tempString;
                     [_reserveZero removeObject:[NSString stringWithFormat:@"%ld",(long)temp]];
                }
            }
        }
    }
}

//raymone:这里的代码空格和分行也按照上面的处理一下，复杂的逻辑用注释辅助说明
//右的逻辑和下的一样，就是要从第三列开始检查
- (void) handleRight{
    for (int i=2;i>=0;i--) {
        for (int j=0;j<4;j++) {
            NSInteger temp = [self toFindLast:4*j+i WithDirection:@"Right"];
            if (temp%4 != 3 && [_isModified[temp+1] isEqualToString:@"0"] && [_cellList[temp+1] isEqualToString:_cellList[4*j+i]])
            {
                self.flag=YES;
                _cellList[temp+1]=[NSString stringWithFormat:@"%d",([_cellList[temp+1] intValue]*2)];
                _isModified[temp+1]=@"1";
                _cellList[4*j+i]=@"0";
                _reserveZero[_reserveZero.count]=[NSString stringWithFormat:@"%d",4*j+i];
            }
        }
    }
    for (int i = 2;i >= 0;i--) {
        for (int j = 0;j < 4;j++) {
            if (![_cellList[4*j+i] isEqualToString:@"0"]) {
                NSInteger temp = [self toFindLast:4*j+i WithDirection:@"Right"];
                if (temp!=4*j+i) {
                    self.flag = YES;
                    NSString *tempString = _cellList[4*j+i];
                    _cellList[4*j+i] = @"0";
                    _reserveZero[_reserveZero.count] = [NSString stringWithFormat:@"%d",4*j+i];
                    _cellList[temp] = tempString;
                    [_reserveZero removeObject:[NSString stringWithFormat:@"%ld",(long)temp]];
                }
            }
        }
    }
}

@end
