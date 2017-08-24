//
//  ViewController2.h
//  codecControllerTest
//
//  Created by liucairong on 15/10/9.
//  Copyright (c) 2015年 znv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyView.h"

@interface ViewController2 : UIViewController<MyViewDelegate>

@property (nonatomic, retain) IBOutlet MyView *xibView;
//@property (nonatomic, retain) NSString *urlstr;
@end
