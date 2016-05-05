//
//  ViewController.h
//  btn_AnimationShow
//
//  Created by Little.Daddly on 16/5/4.
//  Copyright © 2016年 Little.Daddly. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, animationType){
      animationTypeShowUp = 100,
      animationTypeShowLeft,
      animationTypeShowRight,
      animationTypeShowLevel
}btnAnimationType;
@interface ViewController : UIViewController
@property (nonatomic, assign)animationType animationType;

@end

