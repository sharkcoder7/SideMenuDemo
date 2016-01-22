//
//  DemoNavigationController.m
//  SideMenu
//
//  Created by iOSHero on 1/22/16.
//  Copyright © 2016 iOSHero. All rights reserved.
//

#import "DemoNavigationController.h"
#import "SideMenu.h"

@interface DemoNavigationController () <SideMenuDelegate>

@property (strong, nonatomic) SideMenu *sideMenu;

- (void)initSideMenuBar;

@end

@implementation DemoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSideMenuBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initSideMenuBar
{
    _sideMenu = [[[NSBundle mainBundle] loadNibNamed:@"SideMenu" owner:self options:nil] objectAtIndex:0];
    _sideMenu.translatesAutoresizingMaskIntoConstraints = NO;
    _sideMenu.delegate = self;
    [_sideMenu initSwipeGesture:self];
    [self.view addSubview:_sideMenu];
    
    CGRect rt = self.view.frame;
    CGFloat width = rt.size.width * 0.8;
    _sideMenu.leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:_sideMenu
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:-width];
    
    [self.view addConstraint:_sideMenu.leftLayoutConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sideMenu
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sideMenu
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.8
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sideMenu
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view updateConstraints];
}

- (void)menuAction:(id)sender
{
    if ([_sideMenu isOpenSideMenu])
        [_sideMenu hide];
    else
        [_sideMenu show];
}

@end
