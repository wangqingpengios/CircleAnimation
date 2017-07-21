//
//  ALCircleAnimation.m
//  自定义转场动画
//
//  Created by home on 2017/7/21.
//  Copyright © 2017年 王庆鹏. All rights reserved.
//

#import "ALCircleAnimation.h"


@interface ALCircleAnimation ()<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

/**
 */
///动画是呈现还是解除
@property(nonatomic,assign)BOOL isPresented;

/**
 保存动画上下文(必须要弱引用，如果强引用则会导致循环引用，内存泄露)
 */
@property(nonatomic,weak)id <UIViewControllerContextTransitioning>transitionContext;

@end

@implementation ALCircleAnimation

#pragma mark -UIViewControllerTransitioningDelegate

///告诉控制器谁来提供展现转场动画
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresented = YES;
    return self;
}

///告诉控制器谁来提供解除转场动画
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresented = NO;
    return self;
}



/**
 返回动画时长
 
 @param transitionContext 转场上下文
 @return 动画时长
 */
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}


/**
 转场动画最核心的方法-由程序员提供自己的动画实现
 
 @param transitionContext 转场上下文-提供转场动画的所有细节
 
 * 容器视图-转场动画表演的舞台
 * 转场上下文会对展现的控制器强引用
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //1.获取容器视图
    UIView *containerView = transitionContext.containerView;
    //2.获取目标视图,如果是展现取toView，如果是解除，取fromView
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView *view = self.isPresented?toView:fromView;
    
    NSLog(@"%@----%@",fromView,toView);
    
    //3.添加目标视图到容器视图
    [containerView addSubview:toView];
    
    //4.动画
    [self layerAnimationWithView:view];
    
    //5.！！！一定要完成转场，如果不完成，系统会一直等待转场完成，就无法接收用户的任何交互
    
    //应该在动画完成之后再通知系统转场结束
    //    [transitionContext completeTransition:YES];
    
    self.transitionContext = transitionContext;
    
    
    
}

- (void)layerAnimationWithView:(UIView *)view
{
    //1.实例化图层
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    //2.设置图层属性
    
    //使用贝塞尔曲线绘制圆形路径
    
    //直径
    CGFloat radius = 50;
    
    CGFloat margin = 20;
    
    CGFloat viewWidth = view.bounds.size.width;
    CGFloat viewHeight = view.bounds.size.height;
    
    //动画起始路径
    
    CGRect rect = CGRectMake(viewWidth - radius - margin, margin, radius, radius);
    //
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    //动画结束路径
    
    
    //计算屏幕对角线
    CGFloat endRadius = sqrt(viewWidth*viewWidth + viewHeight*viewHeight);
    
    //使用缩进   --第一个参数：原始大小  第二个参数：X轴缩进（-放大  +缩小）
    CGRect endRect = CGRectInset(rect, -endRadius, -endRadius);
    
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
    
    //填充颜色
    //    layer.fillColor = [UIColor redColor].CGColor;
    
    
    layer.path = path.CGPath;
    
    //3.将图层添加到View的图层-（不会裁切视图，在视图的图层上显示路径的内容）
    //    [self.view.layer addSublayer:layer];
    
    //4.设置图层的遮罩-(会裁切视图，只显示路径包含范围内的内容，视图本质上没有发生任何的变化)
    //一旦设置了mask遮罩，填充颜色就会失效
    view.layer.mask = layer;
    
    
    //5.动画 -如果要做layer视图的动画，不能使用UIView的动画，应该使用核心动画
    //    [UIView animateWithDuration:3 animations:^{
    //                //设置图层的路径
    //        layer.path = endPath.CGPath;
    //
    //    }];
    //（1）实例化动画对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    //(2)设置动画属性
    //时长
    animation.duration = [self transitionDuration:self.transitionContext];
    
    //判断是展现还是解除
    if(self.isPresented)
    {
        //formValue
        animation.fromValue = (__bridge id _Nullable)(path.CGPath);
        //toValue
        animation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    }
    else
    {
        //formValue
        animation.fromValue = (__bridge id _Nullable)(endPath.CGPath);
        //toValue
        animation.toValue = (__bridge id _Nullable)(path.CGPath);
    }
    
    
    //设置向前填充模式
    animation.fillMode = kCAFillModeForwards;
    //完成之后不删除
    animation.removedOnCompletion = NO;
    
    //设置动画代理  必须要写在添加动画到图层的前面，否则代理不会调用（一旦将动画添加到图层，动画已经开启，在设置代理已经来不及了）
    animation.delegate = self;
    
    //(3)将动画添加到图层  -shapheLayer,让哪个图层执行动画就应该将动画添加到哪个图层
    [layer addAnimation:animation forKey:nil];
    
}


///动画完成
/**
 监听动画完成
 
 @param anim 动画
 @param flag 完成
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.transitionContext completeTransition:YES];
    
    
}


@end
