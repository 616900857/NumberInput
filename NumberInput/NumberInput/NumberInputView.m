//
//  NumberInputView.m
//  NumberInput
//
//  Created by mac on 2017/8/21.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import "NumberInputView.h"
#define UGInputSpace        10
#define UGInputPointWidth   16
#define HEXRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define HEXRGB_Alpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:a]

@interface NumberInputView()<UITextFieldDelegate>
// 已输入的个数
@property (assign, nonatomic) NSInteger inputNum;
// 类型
@property (assign, nonatomic)TMFNumberInputType inputType;
// 光标
@property (strong, nonatomic) CAShapeLayer *cursorLayer;
// 响应者
@property (strong, nonatomic) UITextField *responsder;

@end

IB_DESIGNABLE
@implementation NumberInputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputType:(TMFNumberInputType)type {
    if (self = [super initWithFrame:frame]) {
        self.inputType = type;
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    self.numCount = _numCount < 1 ? 4 : _numCount;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)];
    [self addGestureRecognizer:tap];
}

- (void)drawRect:(CGRect)rect {
    CGRect curRect = CGRectInset(self.bounds, 1, 1);
    CGFloat perInputViewW = (curRect.size.width - (self.numCount - 1) * UGInputSpace) / self.numCount;
    CGFloat perInputViewH = curRect.size.height;
    CGFloat pointCenterX = perInputViewW * 0.5;
    CGFloat pointCenterY = self.bounds.size.height * 0.5;
    CGFloat space = _type == NumberInputLine ? UGInputSpace : 0;
    CGFloat viewX = 0;
    
    if(_inputType == NumberInputRect) {
        perInputViewW = curRect.size.width / self.numCount;
    }
    
    // 样式 下划线 、边框
    if (_inputType == NumberInputLine) {
        for (NSInteger i = 0; i < self.numCount; i++) {
            viewX = i * (perInputViewW + UGInputSpace) + curRect.origin.x;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(viewX, perInputViewH)];
            [path addLineToPoint:CGPointMake(viewX+perInputViewW, perInputViewH)];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineCapRound;
            path.lineWidth = 1.0;
            [HEXRGB(0xCCCCCC) setStroke];
            [path stroke];
        }
    } else {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:curRect cornerRadius:3.0];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineCapRound;
        path.lineWidth = 1.0;
        [HEXRGB(0xCCCCCC) setStroke];
        [path stroke];
        
        for (NSInteger i = 1; i < self.numCount; i++) {
            viewX = i * perInputViewW + curRect.origin.x;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(viewX, 0)];
            [path addLineToPoint:CGPointMake(viewX, perInputViewH)];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineCapRound;
            path.lineWidth = 1.0;
            [HEXRGB(0xCCCCCC) setStroke];
            [path stroke];
        }
    }
    
    if (_secureText) {
        // 画点
        for (NSInteger i = 0; i < self.inputNum; i++) {
            viewX = i * (perInputViewW + space) + pointCenterX + curRect.origin.x;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path addArcWithCenter:CGPointMake(viewX, pointCenterY) radius:UGInputPointWidth * 0.5 startAngle:0.0 endAngle:M_PI * 2 clockwise:YES];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineCapRound;
            [HEXRGB(0x080F44) setFill];
            [path fill];
        }
        
    } else {
        //数字
        UIFont *font = [UIFont systemFontOfSize:18];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, HEXRGB(0x080F44), NSForegroundColorAttributeName, nil];
        
        NSString *text = self.responsder.text;
        for(int i = 0; i < text.length; i++) {
            NSString *numStr = [text substringWithRange:NSMakeRange(i, 1)];
            CGSize size = [numStr sizeWithAttributes:attributes];
            viewX = i * (perInputViewW + space) + pointCenterX - size.width/2.0;
            [numStr drawAtPoint:CGPointMake(viewX, pointCenterY - size.height/2.0) withAttributes:attributes];
        }
    }
    self.cursorLayer.hidden = YES;
    if (_showCursor && _numCount > self.inputNum && self.responsder.isFirstResponder) {
        self.cursorLayer.hidden = NO;
        viewX = self.inputNum * (perInputViewW + space) + pointCenterX + curRect.origin.x;
        // 关闭隐式动画
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.cursorLayer.position = CGPointMake(viewX, pointCenterY);
        [CATransaction commit];
        [self.cursorLayer addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
}

#pragma mark --- > UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 0) {
        if (textField.text.length + string.length > self.numCount) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setNeedsDisplay];
}

- (void)textFieldEditingChanged:(UITextField *)sender {
    [self setNeedsDisplay];
    self.inputNum = sender.text.length;
    if (self.inputNum == self.numCount) {
        !self.inputFinishBlock?:self.inputFinishBlock(self.responsder.text);
        [self resignFirstResponder];
    }
    !self.inputBlock?:self.inputBlock(self.responsder.text);
    NSLog(@"===验证码输入：%@===",sender.text);
}

- (void)setType:(NSUInteger)type {
    if (_inputType != type) {
        _inputType = type <= NumberInputRect ? type : NumberInputRect;
        _type = _inputType;
        [self setNeedsDisplay];
    }
}

- (void)setNumCount:(NSInteger)numCount {
    if (_numCount != numCount) {
        _numCount = numCount;
        [self setNeedsDisplay];
    }
}

- (void)setShowCursor:(BOOL)showCursor {
    if (_showCursor != showCursor) {
        _showCursor = showCursor;
        [self setNeedsDisplay];
    }
}

- (void)setSecureText:(BOOL)secureText {
    if (_secureText != secureText) {
        _secureText = secureText;
        [self setNeedsDisplay];
    }
}

- (CAShapeLayer *)cursorLayer {
    if (!_cursorLayer) {
        _cursorLayer = [CAShapeLayer layer];
        _cursorLayer.bounds = CGRectMake(0, 0, 1, 20);
        _cursorLayer.backgroundColor = HEXRGB(0x4680FA).CGColor;
        [self.layer addSublayer:_cursorLayer];
    }
    return _cursorLayer;
}

- (UITextField *)responsder {
    if (!_responsder) {
        _responsder = [[UITextField alloc] init];
        _responsder.delegate = self;
        _responsder.backgroundColor = UIColor.clearColor;
        _responsder.keyboardType = UIKeyboardTypeNumberPad;
        [_responsder addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_responsder];
    }
    return _responsder;
}

//闪动动画
- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 1.0;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}

- (void)clean {
    self.responsder.text = @"";
    self.inputNum = 0;
    [self setNeedsDisplay];
}

- (void)becomeFirstResponder {
    [self.responsder resignFirstResponder];
    [self.responsder becomeFirstResponder];
    [self setNeedsDisplay];
}

- (void)resignFirstResponder {
    [self.responsder resignFirstResponder];
}

@end
