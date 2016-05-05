//
//  ViewController.m
//  btn_AnimationShow
//
//  Created by Little.Daddly on 16/5/4.
//  Copyright © 2016年 Little.Daddly. All rights reserved.
//

#import "ViewController.h"
#define centerX _currentBtn.frame.origin.x //_currentBtn 的X
#define centerY _currentBtn.frame.origin.y //_currentBtn 的Y
#define btnWHalf btnW / 2
#define adjushY  20.
#define space 10.  //子btn 间距
#define margin 20. //子、父btn 距离
#define btnW 20.
#define btnCount 5
#define LeftCount 2
typedef void (^createPointLeft)(BOOL, NSInteger index);
typedef void (^createPointRight)(BOOL, NSInteger index);
@interface ViewController ()
@property (nonatomic, strong)NSMutableArray *btnMarr;
@property (nonatomic, strong)UIButton *currentBtn;
@property (nonatomic, assign)NSTimeInterval currentTime;
@property (nonatomic, copy)createPointLeft pointLeft;
@property (nonatomic, copy)createPointRight pointRight;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:0];
    btn.backgroundColor = [UIColor orangeColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitle:@"Up" forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.center.x, self.view.center.y +adjushY, btnW, btnW);
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = animationTypeShowUp;
    _currentBtn = btn;
    [self.view addSubview:btn];
    [self setUpBtns];
    [self.view bringSubviewToFront:_currentBtn];
}
- (void)setUpBtns{
    NSMutableArray *marr = [NSMutableArray array];
    for (NSInteger i = 0; i < btnCount; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.backgroundColor = [UIColor redColor];
        btn.frame = CGRectMake(_currentBtn.frame.origin.x, _currentBtn.frame.origin.y, btnW, btnW);
        [btn setTitle:[NSString stringWithFormat:@"%ld", i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        btn.layer.cornerRadius = btnW / 2.;
        btn.layer.masksToBounds = YES;
        [self.view addSubview:btn];
        [marr addObject:btn];
    }
    _btnMarr = marr;
}
- (void)click:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    if(sender.tag >= animationTypeShowUp){
        sender.enabled = NO;
        [self showAnimation];
    }else NSLog(@"tag %ld,设置你的代理吧！", sender.tag);

}

- (void)showAnimation{
    _currentTime = CACurrentMediaTime();
    for (int  i = 0; i< _btnMarr.count; i++) {
        UIButton *btn=_btnMarr[i];
        [btn.layer removeAllAnimations];
        NSDictionary *pointDic = [self returnStartPoint:_currentBtn.tag withIndex:i];

        CGPoint startPoint = [(NSValue *)pointDic[@"startPoint"] CGPointValue];
        CGPoint endPoint = [(NSValue *)pointDic[@"endPoint"] CGPointValue];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration=.3;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
        positionAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
        
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.additive = YES;
        scaleAnimation.values = @[@0,@(-1),@0];
        scaleAnimation.keyTimes =_currentBtn.isSelected ? @[@0,@0,@1] : @[@0,@1,@1];
        scaleAnimation.duration=.3;
        CAAnimationGroup *animationGG = [CAAnimationGroup animation];
        animationGG.duration = .3;
        animationGG.repeatCount = 1;
        animationGG.animations = @[positionAnimation, scaleAnimation];
        animationGG.fillMode = kCAFillModeBoth;
        animationGG.removedOnCompletion = YES;
        animationGG.beginTime =  _currentTime + (0.3/(float)_btnMarr.count * (float)i);
        [btn.layer addAnimation:animationGG forKey:nil];
        btn.layer.position = endPoint;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((0.5/(float)_btnMarr.count * (float)_btnMarr.count )) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _currentBtn.enabled = YES;
    });

}
- (NSDictionary *)returnStartPoint:(animationType)type withIndex:(NSInteger)index{
    __block CGPoint startPoint = CGPointZero;
    __block CGPoint endPoint = CGPointZero;
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    self.pointLeft = ^(BOOL sure, NSInteger index){
        startPoint = _currentBtn.isSelected ? CGPointMake(centerX -btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX -btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf);
        endPoint = _currentBtn.isSelected ? CGPointMake(centerX - btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
    };
    self.pointRight = ^(BOOL sure, NSInteger index){
        startPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnW, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnW + index * (btnW + space) + margin + btnWHalf, centerY +adjushY - btnWHalf);
        endPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnW + index * (btnW + space) + margin + +btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
    };
    switch (type) {
        case animationTypeShowUp:
            startPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY - index * (btnW + space) - btnW - margin +adjushY);
            endPoint = _currentBtn.isSelected ? CGPointMake(centerX +btnWHalf, centerY - index * (btnW + space) - btnW - margin +adjushY) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
            break;
        case animationTypeShowLeft:{
            self.pointLeft(YES,index);
            break;
        }
        case animationTypeShowRight:{
            self.pointRight(YES,index);
            break;
        }
        case animationTypeShowLevel:
            if (index <= LeftCount) {
                self.pointLeft(YES,index);
            }else{
                self.pointRight(YES,index - LeftCount - 1);
            }
            break;
        default:
            break;
    }
    [mdic setObject:[NSValue valueWithCGPoint:startPoint] forKey:@"startPoint"];
    [mdic setObject:[NSValue valueWithCGPoint:endPoint] forKey:@"endPoint"];
    return [mdic copy];
}
- (IBAction)chooseAnimationType:(UIButton *)sender {
    if (!_currentBtn) return;
    switch (sender.tag) {
        case animationTypeShowUp:
            _currentBtn.tag = animationTypeShowUp;
            [_currentBtn setTitle:@"Up" forState:UIControlStateNormal];
            break;
        case animationTypeShowLeft:
            _currentBtn.tag = animationTypeShowLeft;
            [_currentBtn setTitle:@"Le" forState:UIControlStateNormal];
            break;
        case animationTypeShowRight:
            _currentBtn.tag = animationTypeShowRight;
            [_currentBtn setTitle:@"Ri" forState:UIControlStateNormal];
            break;
        case animationTypeShowLevel:
            _currentBtn.tag = animationTypeShowLevel;
            [_currentBtn setTitle:@"Le" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    _currentBtn.selected = NO;
}
- (void)setAnimationType:(animationType)animationType{
    _currentBtn.tag = animationType;
    [_currentBtn setTitle:[NSString stringWithFormat:@"%ldT", animationType] forState:UIControlStateNormal];
}

@end
