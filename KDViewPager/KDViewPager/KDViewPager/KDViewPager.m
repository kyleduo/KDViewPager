//
//  KDViewPager.m
//  KDViewPager
//
//  Created by kyle on 16/4/19.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

#import "KDViewPager.h"

@interface KDViewPager() <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>
@property (nonatomic, weak) UIViewController *hostController;
@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, strong) UIPageViewController *pager;
@property (nonatomic, strong) NSMutableDictionary *viewControllers;
@end

@implementation KDViewPager

-(instancetype)initWithController:(UIViewController *)controller {
	return [self initWithController:controller inView:nil];
}

-(instancetype)initWithController:(UIViewController *)controller configView:(void(^)(UIView *hostView, UIView *pagerView))configBlock {
	return [self initWithController:controller inView:nil configView:configBlock];
}

-(instancetype)initWithController:(UIViewController *)controller inView:(UIView *)hostView {
	return [self initWithController:controller inView:hostView configView:^(UIView *hostView, UIView *pagerView) {
		NSDictionary *dict = @{@"view":pagerView};
		[pagerView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[hostView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:dict]];
		[hostView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:dict]];
	}];
}


-(instancetype)initWithController:(UIViewController *)controller inView:(UIView *)hostView configView:(void(^)(UIView *hostView, UIView *pagerView))configBlock {
	self = [super init];
	if (self) {
		self.hostController = controller;
		self.hostView = hostView ? hostView : self.hostController.view;
		[self commonInit:configBlock];
	}
	return self;
}


/**
 * Common method to initial view pager.
 */
-(void)commonInit:(void(^)(UIView *, UIView *))configViewBlock {
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMin]
														forKey:UIPageViewControllerOptionSpineLocationKey];
	_pager = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
	_pagerView = _pager.view;
	_pager.edgesForExtendedLayout = UIRectEdgeNone;
	_pager.delegate = self;
	_pager.dataSource = self;
	// support no-bounce effect
	for (UIView *view in _pager.view.subviews) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			((UIScrollView *)view).delegate = self;
			break;
		}
	}
	[_hostController addChildViewController:_pager];
	[_pager didMoveToParentViewController:_hostController];
	if (_hostView) {
		[_hostView addSubview:_pager.view];
		if (configViewBlock) {
			configViewBlock(_hostView, _pager.view);
		}
	}
	
	// bounces is ON by default.
	_bounces = YES;
}


#pragma mark - getter & setter
-(NSMutableDictionary *)viewControllers {
	if (!_viewControllers) {
		NSUInteger capacity = 10;
		if (self.datasource) {
			NSUInteger count = [self.datasource numberOfPages:self];;
			capacity = count > 0 ? count : 1;
		}
		_viewControllers = [NSMutableDictionary dictionaryWithCapacity:capacity];
	}
	return _viewControllers;
}

-(void)setDelegate:(id<KDViewPagerDelegate>)delegate {
	_delegate = delegate;
	
}

-(void)setDatasource:(id<KDViewPagerDatasource>)datasource {
	_datasource = datasource;
	
	if (_datasource) {
		[self reload];
	}
}

-(void)setCurrentPage:(NSUInteger)currentPage {
	[self setCurrentPage:currentPage animated:YES];
}

-(void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated {
	NSUInteger count = [self.datasource numberOfPages:self];
	if (count == 0) {
		_currentPage = 0;
		return;
	}
	if (currentPage == _currentPage) {
		return;
	}
	if (currentPage >= count - 1) {
		currentPage = count - 1;
	}
	
	UIViewController *vc = [self controllerAtIndex:currentPage];
	if (vc != nil) {
		BOOL forward = currentPage > _currentPage;
		NSArray *viewControllers = @[vc];
		__weak typeof(self) weakSelf = self;
		[_pager setViewControllers:viewControllers
						 direction:forward ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
						  animated:animated
						completion:^(BOOL finished) {
							if (finished) {
								_currentPage = currentPage;
								if (weakSelf.delegate) {
									[weakSelf.delegate kdViewpager:weakSelf didSelectPage:currentPage direction:forward];
								}
							}
						}];
	}
}

-(void)reload {
	UIViewController *vc0 = [self controllerAtIndex:0];
	if (vc0 != nil) {
		NSArray *viewControllers = @[vc0];
		[_pager setViewControllers:viewControllers
						 direction:UIPageViewControllerNavigationDirectionForward
						  animated:NO
						completion:nil];
	}
}

#pragma mark - private
-(NSUInteger)indexOfViewController:(UIViewController *)viewController {
	NSArray *keys = [self.viewControllers allKeysForObject:viewController];
	if (keys == nil || keys.count == 0) {
		return NSNotFound;
	} else if (keys.count == 1) {
		return ((NSNumber *)keys.firstObject).unsignedIntegerValue;
	} else {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"View controller should be unique" userInfo:nil];
	}
}

-(UIViewController *)getViewControllerAfter:(BOOL)after viewController:(UIViewController *)viewController {
	NSUInteger index = viewController == nil ? NSNotFound : [self indexOfViewController:viewController];
	if (NSNotFound == index) {
		index = after ? 0 : -1;
	} else {
		index += after ? 1 : -1;
	}
	NSUInteger count = [self.datasource numberOfPages:self];
	if (index >= count) {
		return nil;
	}
	
	return [self controllerAtIndex:index];
}

-(UIViewController *)controllerAtIndex:(NSUInteger)index {
	NSUInteger count = [self.datasource numberOfPages:self];
	UIViewController *cached = [self.viewControllers objectForKey:@(index)];
	UIViewController *controller = nil;
	
	if (count > 0) {
		controller = [self.datasource kdViewPager:self controllerAtIndex:index cachedController:cached];
		
		if (controller != nil) {
			[self.viewControllers setObject:controller forKey:@(index)];
		}
	}
	
	return controller;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_bounces) {
		return;
	}
	NSUInteger count = [self.datasource numberOfPages:self];
	if (_currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
		scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
	}
	if ((count == 0 || _currentPage >= count - 1) && scrollView.contentOffset.x > scrollView.bounds.size.width) {
		scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
	}
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (_bounces) {
		return;
	}
	NSUInteger count = [self.datasource numberOfPages:self];
	if (_currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
		*targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
	}
	if ((count == 0 || _currentPage >= count - 1) && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
		*targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
	}
}

#pragma mark - delegate

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
	if(completed) {
		NSUInteger index = [self indexOfViewController:[pageViewController.viewControllers objectAtIndex:0]];
		if (index != NSNotFound) {
			if (_delegate) {
				[_delegate kdViewpager:self didSelectPage:index direction:_currentPage < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse];
			}
			_currentPage = index;
		}
	}
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
	if (_delegate) {
		NSUInteger index = [self indexOfViewController:[pendingViewControllers objectAtIndex:0]];
		if (index != NSNotFound) {
			[_delegate kdViewpager:self willSelectPage:index direction:_currentPage < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse];
		}
	}
}

#pragma mark - datasource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	return [self getViewControllerAfter:YES viewController:viewController];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	return [self getViewControllerAfter:NO viewController:viewController];
}

@end
