//
//  ViewController.m
//  CCComments
//
//  Created by admin on 2019/4/11.
//  Copyright © 2019 iBlocker. All rights reserved.
//

#import "ViewController.h"
#import "CCCommentsHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    commentsButton.frame = CGRectMake(100, 100, 100, 60);
    [commentsButton setTitle:@"评论"
                    forState:UIControlStateNormal];
    [commentsButton setBackgroundColor:UIColor.redColor];
    [commentsButton setTitleColor:UIColor.orangeColor
                         forState:UIControlStateNormal];
    [commentsButton addTarget:self
                       action:@selector(commentsButtonTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commentsButton];
}

- (void)commentsButtonTouchUpInside:(UIButton *)sender {
    [CCPopupComments commentsWithCommit:^(NSUInteger selectedIndex, NSArray<NSString *> * _Nonnull selectedTags, NSString * _Nonnull content) {
        NSLog(@"%zd --- %@ --- %@", selectedIndex, selectedTags, content);
    }];
}


@end
