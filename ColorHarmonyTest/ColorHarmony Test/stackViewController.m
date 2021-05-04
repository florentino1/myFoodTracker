//
//  stackViewController.m
//  ColorHarmony Test
//
//  Created by 莫玄 on 2021/5/1.
//
#import "stackViewController.h"
#import "myUIImageView.h"
#import "colorArray.h"
#import "RGBColor.h"


#define WIDTH 28.0
#define HIGHT 28.0
#define IMAGECOUNT 20

@interface stackViewController()
@property (assign,nonatomic)NSUInteger tagtmp;//用于储存正在被拖动的imageView的初始tag；
@property (strong,nonatomic)NSMutableArray *color;//用于储存来自colorArray的随机颜色；
@end
@implementation stackViewController

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    self.tagtmp=101;
    [self setColorArray];
    [self setImages];
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    self.tagtmp=101;
    [self setColorArray];
    [self setImages];
    return self;
}
-(void)setColorArray
{
    colorArray *colorA=[colorArray sharedColorArray];
    if(self.tag==1001)
    {
        _color=colorA.firstColorArray;
    }
    else if(self.tag==1002)
    {
        _color=colorA.secondColorArray;
    }
    else if(self.tag==1003)
    {
        _color=colorA.thirdColorArray;
    }
}
-(void)setImages
{
    for(int i=0;i<IMAGECOUNT;i++)
    {
        //设置imageview的基本参数
        myUIImageView *image=[[myUIImageView alloc]init];
        [image.heightAnchor constraintEqualToConstant:HIGHT].active=true;
        [image.widthAnchor constraintEqualToConstant:WIDTH].active=true;

        //设置每个色块的颜色
        [self setSingleImageColorWithimageView:image Index:i ColorArray:_color];

        //设置每个色块的tag;
        [self imageSetTag:image withIndex:i];

        //设置手势识别器
        [self imageViewSetPanGesture:image];

        [self addArrangedSubview:image];
    }
}
-(void)imageViewSetPanGesture:(myUIImageView *)image
{
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]init];
    pan.maximumNumberOfTouches=1;
    pan.minimumNumberOfTouches=1;
    [pan addTarget:self action:@selector(panMove:)];
    [image addGestureRecognizer:pan];
}
-(void)imageSetTag:(myUIImageView *)image withIndex:(int)i
{
    image.tag=i;
    if(image.tag==0 || image.tag==19)
    {
        image.userInteractionEnabled=NO;
    }
    else
    {
        image.userInteractionEnabled=YES;
    }
}
-(void)setSingleImageColorWithimageView:(myUIImageView *)image Index:(int)i ColorArray:(NSMutableArray *)color
{
    RGBColor *rgbColor=color[i];
    CGFloat c[]={rgbColor.R/255.0,rgbColor.G/255.0,rgbColor.B/255.0,1.0};
    CGColorRef singleColor=CGColorCreate(CGColorSpaceCreateDeviceRGB(), c);
    image.backgroundColor=[UIColor colorWithCGColor:singleColor];
    image.colorInfo=rgbColor;
}
-(void)refreshSingleImageViewColor
{
    [self setColorArray];
    for(int i=0;i<IMAGECOUNT;i++)
    {
        myUIImageView *image=[self viewWithTag:i];
        [self setSingleImageColorWithimageView:image Index:i ColorArray:self.color];
    }
}
-(void)panMove:(UIPanGestureRecognizer *)sender
{
    myUIImageView *image=(myUIImageView *)sender.view;
    CGPoint trans=[sender translationInView:sender.view.superview];
    if(sender.state==UIGestureRecognizerStateBegan)
    {
        image.positionXForver=sender.view.center.x;
        image.positionX=sender.view.center.x;
        image.positionY=sender.view.center.y;
        image.positionXTEM=image.positionX;
        NSLog(@"当前正在移动的imageview 序号为：%lu,坐标为：%f,%f\n",(unsigned long)image.tag,image.positionX,image.positionY);

    }
   else if(sender.state==UIGestureRecognizerStateChanged)
    {
        NSUInteger index=image.tag;
        //CGFloat temx=trans.x+image.positionX;
        CGFloat distance=trans.x+image.positionX-image.positionXTEM;
        if(trans.x>=0 && distance>=0)
        {
            NSLog(@"色块向右移动:%f,总计移动：%f",trans.x,distance);
            int times=(int)distance/33;
            int res=(int)distance%33;
            if(res>=19)
                times+=1;
            for (NSUInteger i=1+index;i<=times+index; i++)
            {
                myUIImageView *imageNext=[self viewWithTag:i];
                image.tag=self.tagtmp;
                imageNext.tag=imageNext.tag-1;
                imageNext.positionX=imageNext.center.x-33.0;
                imageNext.positionY=imageNext.center.y;
                imageNext.positionXForver=imageNext.center.x-33.0;
                imageNext.positionXTEM=imageNext.positionX;
                imageNext.center=CGPointMake(imageNext.positionX, imageNext.positionY);
                NSLog(@"imageNext[%ld]移动到位置：%f,%f\n",(long)imageNext.tag,imageNext.positionX,imageNext.positionY);
                image.tag=i;
                image.positionX+=trans.x;
                sender.view.center=CGPointMake(image.positionX, image.positionY);
                image.positionXTEM+=33.0;
                [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
                trans.x=0;
                trans.y=0;
                NSLog(@"change 方法当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
            }
            image.positionX=image.positionX+trans.x;
            sender.view.center=CGPointMake(image.positionX, image.positionY);
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
            NSLog(@"当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
        }
        else if(trans.x>=0 && distance<0)
        {
            image.positionX=image.positionX+trans.x;
            sender.view.center=CGPointMake(image.positionX, image.positionY);
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
            NSLog(@"当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
        }
        else if(trans.x<0 && distance<=0)
        {
            NSLog(@"色块向左移动:%f,总计移动：%f",trans.x,distance);
            distance=distance*(-1);
            int res=(int)distance%33;
            int times=(int)distance/33;
            if(res>=19)
                times+=1;
            for(NSUInteger i=index-1;i>=index-times;i--)
            {
                myUIImageView *imageForward=[self viewWithTag:i];
                image.tag=self.tagtmp;
                imageForward.tag+=1;
                imageForward.positionX=imageForward.center.x+33.0;
                imageForward.positionY=imageForward.center.y;
                imageForward.positionXTEM=imageForward.positionX;
                imageForward.positionXForver=imageForward.center.x+33.0;
                imageForward.center=CGPointMake(imageForward.positionX, imageForward.positionY);
                NSLog(@"imageForward[%ld]移动到位置：%f,%f\n",(long)imageForward.tag,imageForward.positionX,imageForward.positionY);
                image.tag=i;
                image.positionX+=trans.x;
                sender.view.center=CGPointMake(image.positionX, image.positionY);
                image.positionXTEM-=33.0;
                trans.x=0;
                trans.y=0;
                [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
                NSLog(@"change 方法当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
            }
            image.positionX+=trans.x;
            sender.view.center=CGPointMake(image.positionX, image.positionY);
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
            NSLog(@"当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
        }
        else if(trans.x<0 && distance>0)
        {
            image.positionX+=trans.x;
            sender.view.center=CGPointMake(image.positionX, image.positionY);
            [sender setTranslation:CGPointMake(0, 0) inView:sender.view.superview];
            NSLog(@"当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
        }
    }
    else if(sender.state==UIGestureRecognizerStateCancelled || UIGestureRecognizerStateEnded)
    {
        CGFloat distance=image.positionX-image.positionXForver;
        if(distance>0)
        {
            int times=(int)distance/33;
            int res=(int)distance%33;
            if(res>=19)
                times+=1;
            image.positionX=times*33+image.positionXForver;
        }
        else
        {
            distance=distance *(-1);
            int times=(int)distance/33;
            int res=(int)distance%33;
            if(res>=19)
                times+=1;
            times=times*(-1);
            image.positionX=33*times+image.positionXForver;
        }
        sender.view.center=CGPointMake(image.positionX,image.positionY);
        image.positionXTEM=image.positionX;
        image.positionXForver=image.positionX;
        NSLog(@"当前imageView移动到位置：%f,%f\n",image.positionX,image.positionY);
    }

}
@end
