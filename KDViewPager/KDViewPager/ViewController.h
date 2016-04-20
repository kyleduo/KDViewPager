//
//  ViewController.h
//  KDViewPager
//
//  Created by kyle on 16/4/19.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIStepper *pagerControl;
@property (weak, nonatomic) IBOutlet UILabel *delegateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *boundceControl;


@end

