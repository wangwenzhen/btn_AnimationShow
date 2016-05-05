# btn_AnimationShow
按钮弹出收复动画

![动画效果.gif](http://upload-images.jianshu.io/upload_images/1517349-a896026633fa4a9c.gif?imageMogr2/auto-orient/strip)


```oc
#define centerX _currentBtn.frame.origin.x //_currentBtn 的X
#define centerY _currentBtn.frame.origin.y //_currentBtn 的Y
#define btnWHalf btnW / 2
#define adjushY  20.
#define space 10.  //子btn 间距
#define margin 20. //子、父btn 距离
#define btnW 20.
#define btnCount 5
#define LeftCount 2
```
####写的有点 匆忙 ，没有单独封装到UIView上，所以大家 将就 用宏代替接口吧！！！哈哈哈
`centerY和centerX`来设置 父 按钮 origin的x和y，
通过改变它 会改变 所有子 按钮originx和y。`btnCount`是子 按钮的总数，`LeftCount `则是影响水平子按钮左右显示的数量。
```oc
typedef void (^createPointLeft)(BOOL, NSInteger index);
typedef void (^createPointRight)(BOOL, NSInteger index);
```
###### 定义两个没有返回值的block用来保存要重用的代码，`左弹出 、右弹出`的动画效果我们是要在`水平弹出`中复用的。
`@property (nonatomic, assign)NSTimeInterval currentTime;`用来保存每次执行动画前的当前时间，以便确定每个按钮动画执行的时机。


```oc
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((0.5/(float)_btnMarr.count * (float)_btnMarr.count )) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _currentBtn.enabled = YES;
    });
```
* 这段代码为的是解决按钮快速点击，导致动画未执行完成，再次生成动画的bug。按钮点下后取消点击时间，延长的时间略长于动画组执行的时间。而后激活点击事件。

```oc
self.pointLeft = ^(BOOL sure, NSInteger index){
        startPoint = _currentBtn.isSelected ? CGPointMake(centerX -btnWHalf, centerY +adjushY - btnWHalf) : CGPointMake(centerX -btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf);
        endPoint = _currentBtn.isSelected ? CGPointMake(centerX - btnWHalf - index * (btnW + space) - margin, centerY +adjushY - btnWHalf) : CGPointMake(centerX +btnWHalf, centerY +adjushY - btnWHalf);
    };
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

```
* 以上代码截图，显示的是block代码保存区的复用。block 执行前要给予空间。之后执行，空间中的代码，并传入参数。

###动画分明细
```oc
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

```
* 按钮点击位移与 缩放同时进行。`timingFunction`意味着位移起始点、结束点之间运动的时间函数。代码中的函数 ，表示的是加速度越来越快。
* 缩放 使用帧动画 无论 弹出还是 收复，我们的形变都是缩小到无回复到正常。`additive`将动画添加到mode当前显示层，以便复用。`values`形变值。`keyTimes`每次形变值处在的时间轴。`fillMode`结束的动画样式我们要保留。保留样式选择头尾保留，这里的动画首位不一致呢。`removedOnCompletion`动画结束后删除 渲染。防止动画再次执行重复的添加。
    * `btn.layer.position = endPoint;`改变控件 frame ，保持动画结束 后与 视图显示 的一致性。

####这里强调一点`position`对应的是视图在父视图中锚点所处的位置而 我们的锚点默认的是{0.5,0.5}
###github源代码
* 代码下载地址 : [btn_AnimationShow](https://github.com/wangwenzhen/btn_AnimationShow) 

##有问题反馈
在使用中有任何问题，欢迎反馈给我，可以用以下联系方式跟我交流

* QQ: 575385842@qq.com
