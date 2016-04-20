//
//  ContentViewController.m
//  KDViewPager
//
//  Created by kyle on 16/4/19.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@property (nonatomic, strong) UILabel *indexLabel;
@end

@implementation ContentViewController

-(void)setIndex:(NSUInteger)index {
	_index = index;
	
	if (_indexLabel) {
		_indexLabel.text = [NSString stringWithFormat:@"index: %lu", index];
	}
}

-(instancetype)initWithIndex:(NSUInteger)index
{
	self = [super init];
	if (self) {
		NSLog(@"init index (%lu)", index);
		self.edgesForExtendedLayout = UIRectEdgeNone;
		
		CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
		CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
		CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
		UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
		self.view.backgroundColor = color;
		
		_indexLabel = [[UILabel alloc] init];
		_indexLabel.text = [NSString stringWithFormat:@"index: %lu", index];
		_indexLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		[_indexLabel sizeToFit];
		
		[self.view addSubview:_indexLabel];
		_indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_indexLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
		[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[label]" options:0 metrics:nil views:@{@"label":_indexLabel}]];
	}
	return self;
}

@end
