//
//  CCComments.h
//  CCComments
//
//  Created by admin on 2019/4/11.
//  Copyright © 2019 iBlocker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPopupComments : UIView
/**
 初始化评论视图
 
 @param commit 提交信息
 @return 初始化
 */
+ (instancetype)commentsWithCommit:(void(^)(NSUInteger selectedIndex, NSArray<NSString *> *selectedTags, NSString *content))commit;
@end

NS_ASSUME_NONNULL_END
