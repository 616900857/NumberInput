//
//  NumberInputView.h
//  NumberInput
//
//  Created by mac on 2017/8/21.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TMFNumberInputType) {
    NumberInputLine = 0,
    NumberInputRect
};

@interface NumberInputView : UIView

/**
 类型 支持xib
 */
@property (assign, nonatomic)IBInspectable NSUInteger type;
/**
 数量 通常是 4或者6
 */
@property (assign, nonatomic)IBInspectable NSInteger numCount;
/**
 是否明文
 */
@property (assign, nonatomic)IBInspectable BOOL secureText;
/**
 是否显示光标
 */
@property (assign, nonatomic)IBInspectable BOOL showCursor;

@property (copy, nonatomic) void (^inputBlock)(NSString *number);

@property (copy, nonatomic) void (^inputFinishBlock)(NSString *number);


- (instancetype)initWithFrame:(CGRect)frame inputType:(TMFNumberInputType)type;

- (void)becomeFirstResponder;

- (void)resignFirstResponder;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
