//
//  SideMenu.h
//  SideMenu
//
//  Created by iOSHero on 1/20/16.
//  Copyright © 2016 iOSHero. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum {
    MENU_MYACCOUNT = 0,
    MENU_MYTOKENS,
    MENU_GETFREETOKENS,
    MENU_LOGOUT
} SideMenuItem;

@interface UIView (Screenshot)

- (UIImage *)screenshot;

@end

@interface UIImage (BlurredImageWithRadius)
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;
@end

@protocol SideMenuDelegate <NSObject>

@optional
- (void)tapMenuItem:(SideMenuItem)selectedItem;

@end

@interface SideMenu : UIView

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property (assign, nonatomic) id <SideMenuDelegate> delegate;

- (BOOL)isOpenSideMenu;
- (void)setBarStatus:(BOOL)bOpen;
- (void)selectedMenuItem:(SideMenuItem)selectedItem;

- (void)hide;
- (void)show;

- (void)initSwipeGesture:(UIViewController *)viewController;

@end
