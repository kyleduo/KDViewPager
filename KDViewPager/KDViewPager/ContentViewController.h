//
//  ContentViewController.h
//  KDViewPager
//
//  Created by kyle on 16/4/19.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController
@property (nonatomic, assign) NSUInteger index;

-(instancetype)initWithIndex:(NSUInteger)index;

@end
