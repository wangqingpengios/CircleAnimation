//
//  DemoVC.m
//  CircleAnimation
//
//  Created by home on 2017/7/21.
//  Copyright © 2017年 qingpengwang. All rights reserved.
//

#import "DemoVC.h"


// 1.导入头文件
#import "ALCircleAnimation.h"

@interface DemoVC ()

//2.声明属性
@property (nonatomic, strong) ALCircleAnimation *cirleAnimation;

@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    //3..初始化
    
    //1.设置展现样式为自定义
    self.modalPresentationStyle = UIModalPresentationCustom;
    //初始化
    self.cirleAnimation = [[ALCircleAnimation alloc] init];
    //2.设置转场动画代理
    self.transitioningDelegate = self.cirleAnimation;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //4.解除
    
    //！别忘记告诉控制器 转场结束
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
