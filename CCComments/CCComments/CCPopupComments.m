//
//  CCComments.m
//  CCComments
//
//  Created by admin on 2019/4/11.
//  Copyright © 2019 iBlocker. All rights reserved.
//

#import "CCPopupComments.h"
#import "CCCommentsHeader.h"
#import "DQStarView.h"
#import "UIView+Extension.h"
#import "YYText.h"
#import "CCTagsView.h"

@interface CCPopupComments () <DQStarViewDelegate>
// 背景视图
@property (nonatomic, strong) UIView *backgroundView;
// 弹出视图
@property (nonatomic, strong) UIView *popupView;
// 左边取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
// 右边确定按钮
@property (nonatomic, strong) UIButton *commitButton;
// 中间标题
@property (nonatomic, strong) UILabel *titleLabel;
// 分割线视图
@property (nonatomic, strong) UIView *lineView;
/** 星星*/
@property (nonatomic, strong) DQStarView *starView;
/** 标签选择*/
@property (nonatomic, strong) CCTagsView *tagsView;
/** 评价输入框*/
@property (nonatomic, strong) YYTextView *textView;
/** Tags DataSource*/
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *tagsDataSource;

@property (nonatomic, copy) void(^commitBlock)(NSUInteger selectedIndex, NSArray<NSString *> *selectedTags, NSString *content);
/** 已选标签*/
@property (nonatomic, strong) NSArray<NSString *> *selectedTags;
/** 上次打星*/
@property (nonatomic, assign) NSUInteger lastStar;
@end
@implementation CCPopupComments

/**
 初始化评论视图

 @param commit 提交信息
 @return 初始化
 */
+ (instancetype)commentsWithCommit:(void(^)(NSUInteger selectedIndex, NSArray<NSString *> *selectedTags, NSString *content))commit {
    CCPopupComments *popupComments = [[CCPopupComments alloc] init];
    popupComments.commitBlock = commit;
    [popupComments setupUserInterface];
    [popupComments showWithAnimation:YES];
    return popupComments;
}

static CGFloat CCPopupViewHeight = 180;
static CGFloat CCTopViewHeight = 44;
static CGFloat CCStarViewHeight = 44;
static CGFloat CCMarginHeight = 15;
static CGFloat CCTextViewHeight = 100;

- (NSArray<NSArray<NSString *> *> *)tagsDataSource {
    if (!_tagsDataSource) {
        _tagsDataSource = @[
                              @[@"态度极差", @"回复极慢", @"极不专业", @"胡乱推销", @"毫无经验"],
                              @[@"态度差", @"回复慢", @"不专业", @"经验不足"],
                              @[@"态度一般", @"经验一般"],
                              @[@"态度好", @"回复快", @"很专业"],
                              @[@"回复及时", @"态度极好", @"经验丰富"]
                          ];
    }
    return _tagsDataSource;
}

#pragma mark - Animation
- (void)showTagsWithCount:(NSUInteger)count {
    self.tagsView.hidden = NO;
    CGRect rect = self.popupView.frame;
    rect.origin.y = CGRectGetHeight(UIScreen.mainScreen.bounds);
    self.popupView.frame = rect;
    // 浮现动画
    __weak __typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = weakSelf.popupView.frame;
        CGFloat height = [weakSelf tagViewHeightWithTagsCount:count];
        CGFloat CCBottomMargin = 0;
        if (@available(iOS 11.0, *)) {
            CCBottomMargin = weakSelf.safeAreaInsets.bottom;
        }
        rect.origin.y -= CCPopupViewHeight + CCTopViewHeight + CCBottomMargin + height;
        rect.size.height += height + 30;
        weakSelf.popupView.frame = rect;
        weakSelf.tagsView.frame = CGRectMake(CCMarginHeight, CGRectGetMaxY(weakSelf.starView.frame), CGRectGetWidth(UIScreen.mainScreen.bounds) - 2 * CCMarginHeight, height);
        weakSelf.textView.frame = CGRectMake(CCMarginHeight, CGRectGetMaxY(weakSelf.starView.frame) + height, CGRectGetWidth(UIScreen.mainScreen.bounds) - 2 * CCMarginHeight, CCTextViewHeight);
    }];
}

// 弹出视图方法
- (void)showWithAnimation:(BOOL)animation {
    //1. 获取当前应用的主窗口
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    if (animation) {
        // 动画前初始位置
        CGRect rect = self.popupView.frame;
        rect.origin.y = CGRectGetHeight(UIScreen.mainScreen.bounds);
        self.popupView.frame = rect;
        // 浮现动画
        __weak __typeof (self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = weakSelf.popupView.frame;
            CGFloat CCBottomMargin = 0;
            if (@available(iOS 11.0, *)) {
                CCBottomMargin = weakSelf.safeAreaInsets.bottom;
            }
            rect.origin.y -= CCPopupViewHeight + CCTopViewHeight + CCBottomMargin;
            weakSelf.popupView.frame = rect;
        }];
    }
}

// 关闭视图方法
- (void)dismissWithAnimation:(BOOL)animation {
    // 关闭动画
    __weak __typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = weakSelf.popupView.frame;
        CGFloat CCBottomMargin = 0;
        if (@available(iOS 11.0, *)) {
            CCBottomMargin = weakSelf.safeAreaInsets.bottom;
        }
        rect.origin.y += CCPopupViewHeight + CCTopViewHeight + CCBottomMargin;
        weakSelf.popupView.frame = rect;
        weakSelf.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - DQStarViewDelegate
/**
 * 选择评分的代理方法 view:为展示的评分的视图 score:显示的分数
 */
- (void)starScoreChangFunction:(UIView *)view andScore:(CGFloat)score {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    NSInteger index = score;
    if (index != self.lastStar) {
        self.selectedTags = nil;
        self.tagsView.dataSource = self.tagsDataSource[index - 1];
        [self showTagsWithCount:self.tagsDataSource[index - 1].count];
        self.lastStar = index;
    }
}

#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect rect = [self.textView.superview convertRect:self.textView.frame toView:self];//获取相对于self.view的位置
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//获取弹出键盘的fame的value值
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self convertRect:keyboardRect fromView:self.window];//获取键盘相对于self.view的frame ，传window和传nil是一样的
    CGFloat keyboardTop = keyboardRect.origin.y;
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];//获取键盘弹出动画时间值
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (keyboardTop < CGRectGetMaxY(rect)) {//如果键盘盖住了输入框
        CGFloat gap = keyboardTop - CGRectGetMaxY(rect) - 10;//计算需要网上移动的偏移量（输入框底部离键盘顶部为10的间距）
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, gap, weakSelf.frame.size.width, weakSelf.frame.size.height);
        }];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    //  获取键盘隐藏动画时间值
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (self.frame.origin.y < 0) {
        //  如果有偏移，当隐藏键盘的时候就复原
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, 0, weakSelf.frame.size.width, weakSelf.frame.size.height);
        }];
    }
}

#pragma mark - 界面布局
- (void)setupUserInterface {
    self.frame = UIScreen.mainScreen.bounds;
    //  设置子视图的宽度随着父视图变化
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //  背景遮罩图层
    [self addSubview:self.backgroundView];
    //  弹出视图
    [self addSubview:self.popupView];
    //  设置弹出视图子视图
    //  添加左边取消按钮
    [self.popupView addSubview:self.cancelButton];
    //  添加中间标题按钮
    [self.popupView addSubview:self.titleLabel];
    //  添加右边确定按钮
    [self.popupView addSubview:self.commitButton];
    //  添加分割线
    [self.popupView addSubview:self.lineView];
    //  添加评分控件
    [self.popupView addSubview:self.starView];
    //  添加标签选择
    [self.popupView addSubview:self.tagsView];
    self.tagsView.hidden = YES;
    //  评价弹窗
    [self.popupView addSubview:self.textView];
    
    __weak __typeof (self) weakSelf = self;
    self.tagsView.didSelectedBlock = ^(NSArray<NSString *> * _Nonnull selectedTags) {
        if ([weakSelf.textView isFirstResponder]) {
            [weakSelf.textView resignFirstResponder];
        }
        weakSelf.selectedTags = selectedTags;
    };
    
    //监听键盘展示和隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Getter
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        // 设置子视图的大小随着父视图变化
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.userInteractionEnabled = YES;
        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(didTapBackgroundView:)];
        [_backgroundView addGestureRecognizer:myTap];
    }
    return _backgroundView;
}

- (UIView *)popupView {
    if (!_popupView) {
        CGFloat CCBottomMargin = 0;
        if (@available(iOS 11.0, *)) {
            CCBottomMargin = self.safeAreaInsets.bottom;
        }
        _popupView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen.bounds) - CCTopViewHeight - CCPopupViewHeight - CCBottomMargin, CGRectGetWidth(UIScreen.mainScreen.bounds), CCTopViewHeight + CCPopupViewHeight + CCBottomMargin)];
        _popupView.backgroundColor  = [UIColor whiteColor];
        // 设置子视图的大小随着父视图变化
        _popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _popupView;
}

// 设置子视图的大小随着父视图变化 headerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton                   = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame             = CGRectMake(5, 8, 60, 28);
        _cancelButton.backgroundColor   = kBRToolBarColor;
        _cancelButton.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _cancelButton.titleLabel.font   = [UIFont systemFontOfSize:15.0f * kScaleFit];
        [_cancelButton setTitleColor:kDefaultThemeColor
                            forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消"
                       forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)commitButton {
    if (!_commitButton) {
        _commitButton                   = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitButton.frame             = CGRectMake(self.popupView.frame.size.width - 65, 8, 60, 28);
        _commitButton.backgroundColor   = kBRToolBarColor;
        _commitButton.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        _commitButton.titleLabel.font   = [UIFont systemFontOfSize:15.0f * kScaleFit];
        [_commitButton setTitleColor:kDefaultThemeColor
                            forState:UIControlStateNormal];
        [_commitButton setTitle:@"提交"
                       forState:UIControlStateNormal];
        [_commitButton addTarget:self
                          action:@selector(commitButtonTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.cancelButton.frame.origin.x + self.cancelButton.frame.size.width + 2, 0, self.popupView.frame.size.width - 2 * (self.cancelButton.frame.origin.x + self.cancelButton.frame.size.width + 2), CCTopViewHeight)];
        _titleLabel.backgroundColor     = [UIColor clearColor];
        _titleLabel.autoresizingMask    = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        _titleLabel.font                = [UIFont systemFontOfSize:14.0f * kScaleFit];
        _titleLabel.textColor           = [kDefaultThemeColor colorWithAlphaComponent:0.8f];
        _titleLabel.textAlignment       = NSTextAlignmentCenter;
        _titleLabel.text                = @"评价";
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CCTopViewHeight, self.popupView.frame.size.width, 0.5)];
        _lineView.backgroundColor   = BR_RGB_HEX(0xf1f1f1, 1.0f);
        _lineView.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [self.popupView addSubview:_lineView];
    }
    return _lineView;
}

- (DQStarView *)starView {
    if (!_starView) {
        _starView = DQStarView.new;
        _starView.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) / 2.0 - 110, CGRectGetMaxY(self.lineView.frame) + CCMarginHeight, 220, CCStarViewHeight);
        _starView.starTotalCount    = 5;
        _starView.delegate          = self;
        _starView.ShowStyle         = DQStarShowStyleSingleClick;
        //设置星星的分数
        [_starView ShowDQStarScoreFunction:0.0];
        _starView.starSpace         = 15;
    }
    return _starView;
}

- (CCTagsView *)tagsView {
    if (!_tagsView) {
        //  设置一个初始高度
        _tagsView = [[CCTagsView alloc] initWithFrame:CGRectMake(CCMarginHeight, CGRectGetMaxY(self.starView.frame), CGRectGetWidth(UIScreen.mainScreen.bounds) - 2 * CCMarginHeight, 1000)];
        _tagsView.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _tagsView;
}

- (YYTextView *)textView {
    if (!_textView) {
        CGFloat CCBottomMargin = 0;
        if (@available(iOS 11.0, *)) {
            CCBottomMargin = self.safeAreaInsets.bottom;
        }
        _textView = YYTextView.new;
        _textView.frame = CGRectMake(CCMarginHeight, CGRectGetMaxY(self.starView.frame), CGRectGetWidth(UIScreen.mainScreen.bounds) - 2 * CCMarginHeight, CCTextViewHeight);
        _textView.placeholderText = @"请输入你的评价";
        _textView.placeholderFont = [UIFont systemFontOfSize:15];
        _textView.placeholderTextColor = [UIColor lightGrayColor];
        _textView.backgroundColor = BR_RGB_HEX(0xf1f1f1, 1.0f);
        _textView.layer.cornerRadius = 8;
        _textView.layer.masksToBounds = YES;
    }
    return _textView;
}

#pragma mark - 点击背景遮罩图层事件
- (void)didTapBackgroundView:(UITapGestureRecognizer *)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    } else {
        [self dismissWithAnimation:YES];
    }
}

#pragma mark - 取消按钮的点击事件
- (void)cancelButtonTouchUpInside:(UIButton *)sender {
    [self dismissWithAnimation:YES];
}

#pragma mark - 确定按钮的点击事件
- (void)commitButtonTouchUpInside:(UIButton *)sender {
    if (self.commitBlock) {
        [self dismissWithAnimation:YES];
        self.commitBlock(self.lastStar, self.selectedTags, self.textView.text);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    point = [self.popupView.layer convertPoint:point fromLayer:self.layer]; //get layer using containsPoint:
    if ([self.popupView.layer containsPoint:point]) {
        point = [self.textView.layer convertPoint:point fromLayer:self.popupView.layer];
        if (![self.textView.layer containsPoint:point]) {
            //  触摸点在popupView上，不含textView
            if ([self.textView isFirstResponder]) {
                [self.textView resignFirstResponder];
            }
        }
    }
}

#pragma mark - 自定义主题颜色
- (void)setupThemeColor:(UIColor *)themeColor {
    self.cancelButton.layer.cornerRadius = 6.0f;
    self.cancelButton.layer.borderColor = themeColor.CGColor;
    self.cancelButton.layer.borderWidth = 1.0f;
    self.cancelButton.layer.masksToBounds = YES;
    [self.cancelButton setTitleColor:themeColor forState:UIControlStateNormal];
    
    self.commitButton.backgroundColor = themeColor;
    self.commitButton.layer.cornerRadius = 6.0f;
    self.commitButton.layer.masksToBounds = YES;
    [self.commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.titleLabel.textColor = [themeColor colorWithAlphaComponent:0.8f];
}

- (CGFloat)tagViewHeightWithTagsCount:(NSUInteger)count {
    return 50 + 50 * ceil(count / 3.0);
}

- (void)dealloc {
    //  移除键盘通知监听者
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
