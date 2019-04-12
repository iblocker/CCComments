//
//  CCTagsView.h
//  CCComments
//
//  Created by admin on 2019/4/11.
//  Copyright © 2019 iBlocker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCTagState) {
    CCTagStateDeSelected,
    CCTagStateSelected
};

@interface CCTagsView : UIView
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@property (nonatomic, copy) void(^didSelectedBlock)(NSArray<NSString *> *selectedTags);
@end

NS_ASSUME_NONNULL_END
