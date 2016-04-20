//
//  ViewController.m
//  KDViewPager
//
//  Created by kyle on 16/4/19.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

#import "ViewController.h"
#import "KDViewPager.h"
#import "ContentViewController.h"

@interface ViewController () <KDViewPagerDatasource, KDViewPagerDelegate>
@property (nonatomic, strong) KDViewPager *pager;
@property (nonatomic, assign) NSUInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	self.count = 0;
	
	_pager = [[KDViewPager alloc] initWithController:self inView:_contentView];
	_pager.datasource = self;
	_pager.delegate = self;
	
	[self performSelector:@selector(reload) withObject:nil afterDelay:3];
}

-(void)setCount:(NSUInteger)count {
	_count = count;
	_pagerControl.maximumValue = MAX(0, _count - 1);
}

-(void)reload {
	self.count = 5;
	[_pager reload];
}

#pragma mark - control
- (IBAction)controlChanged:(id)sender {
	UIStepper *stepper = (UIStepper *)sender;
	_pager.currentPage = (NSUInteger)stepper.value;
}
- (IBAction)controlBounce:(id)sender {
	UISwitch *sw = (UISwitch *)sender;
	if (sw.isOn != _pager.bounces) {
		_pager.bounces = sw.isOn;
	}
}
- (IBAction)mannuallySelect:(id)sender {
	_pager.currentPage = 2;
}

#pragma mark - datasource
-(UIViewController *)kdViewPager:(KDViewPager *)viewPager controllerAtIndex:(NSUInteger)index cachedController:(UIViewController *)cachedController {
	if (cachedController == nil) {
		cachedController = [[ContentViewController alloc] initWithIndex:index];
	}
	return cachedController;
}

-(NSUInteger)numberOfPages:(KDViewPager *)viewPager {
	return _count;
}

#pragma mark - delegate
-(void)kdViewpager:(KDViewPager *)viewPager didSelectPage:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
	NSLog(@"didSelectpage: %lu direction: %lu", index, direction);
	_pagerControl.value = index;
	_delegateLabel.text = [NSString stringWithFormat:@"Current page index: %lu", index];
}
-(void)kdViewpager:(KDViewPager *)viewPager willSelectPage:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
	NSLog(@"willSelectPage: %lu direction: %lu", index, direction);
}

@end
