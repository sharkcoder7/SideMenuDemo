//
//  SideMenu.m
//  SideMenu
//
//  Created by iOSHero on 1/20/16.
//  Copyright © 2016 iOSHero. All rights reserved.
//

#import "SideMenu.h"
#import <Accelerate/Accelerate.h>

@interface SideMenu ()

@property (strong, nonatomic) UISwipeGestureRecognizer  *leftSwipe;
@property (strong, nonatomic) UISwipeGestureRecognizer  *rightSwipe;
@property (strong, nonatomic) UITapGestureRecognizer    *tap;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBackground;

@property (assign, nonatomic) BOOL isOpen;

- (IBAction)menuAction:(id)sender;
- (UIImage *)imageWithColor:(UIColor*)color;

@end

@implementation SideMenu

- (void)awakeFromNib
{
    _isOpen = NO;
}

- (BOOL)isOpenSideMenu
{
    return _isOpen;
}

- (void)setBarStatus:(BOOL)bOpen
{
    _isOpen  = bOpen;
}

- (IBAction)menuAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapMenuItem:)])
        [self.delegate tapMenuItem:(SideMenuItem)tag];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)selectedMenuItem:(SideMenuItem)selectedItem
{
    switch (selectedItem) {
        case MENU_MYACCOUNT:
        {
        }
            break;
        case MENU_MYTOKENS:
        {
        }
            break;
        case MENU_GETFREETOKENS:
        {
        }
            break;
        case MENU_LOGOUT:
        {
        }
            break;
        default:
            break;
    }
}

- (void)hide
{
    self.leftLayoutConstraint.constant = -self.frame.size.width;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setBarStatus:![self isOpenSideMenu]];
    }];
}

- (void)show
{
    self.leftLayoutConstraint.constant = 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setBarStatus:![self isOpenSideMenu]];
    }];
}

- (void)initSwipeGesture:(UIViewController *)viewController
{
    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [viewController.view addGestureRecognizer:_leftSwipe];
    
    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(show)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [viewController.view addGestureRecognizer:_rightSwipe];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [viewController.view addGestureRecognizer:_tap];
    
    UIImage *screenshot = [viewController.view screenshot];
    UIImage *blurredImage = [screenshot blurredImageWithRadius:10.0f iterations:5 tintColor:nil];
    _imageViewBackground.image = blurredImage;
}

- (IBAction)menuItemAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    SideMenuItem selectedItem = (SideMenuItem)button.tag;
    [self selectedMenuItem:selectedItem];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapMenuItem:)])
        [self.delegate tapMenuItem:selectedItem];
}

@end

@implementation UIView (Screenshot)

-(UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.8, [UIScreen mainScreen].bounds.size.height), NO, [UIScreen mainScreen].scale);
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        
        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:
                               [self methodSignatureForSelector:
                                @selector(drawViewHierarchyInRect:afterScreenUpdates:)]];
        [invoc setTarget:self];
        [invoc setSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)];
        CGRect arg2 = self.bounds;
        BOOL arg3 = YES;
        [invoc setArgument:&arg2 atIndex:2];
        [invoc setArgument:&arg3 atIndex:3];
        [invoc invoke];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIImage (BlurredImageWithRadius)

- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    
    return image;
}

@end
