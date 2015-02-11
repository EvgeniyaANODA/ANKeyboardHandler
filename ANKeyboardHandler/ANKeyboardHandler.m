//
//  ANKeyboardHandler.m
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANKeyboardHandler.h"
#import "ANHelperFunctions.h"

@interface ANKeyboardHandler ()
{
    struct {
        BOOL shouldNotifityKeyboardState : YES;
    } _delegateExistingMethods;
}
@property (nonatomic, weak) UIScrollView* target;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, assign) BOOL isKeyboardShown; //sometimes IOS send unbalanced show/hide notifications

@end

@implementation ANKeyboardHandler

+ (instancetype)handlerWithTarget:(id)target
{
    NSAssert([target isKindOfClass:[UIScrollView class]],
             @"You can't handle keyboard on class %@\n It must me UIScrollView subclass", NSStringFromClass([target class]));
    
    ANKeyboardHandler* instance = [ANKeyboardHandler new];
    instance.target = target;
    [instance setupKeyboard];
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.handleKeyboard = YES;
    }
    return self;
}

- (void)setEventHandler:(id<ANKeyboardEventHandler>)eventHandler
{
    _eventHandler = eventHandler;
    
}

- (void)setupKeyboard
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.target addGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer.cancelsTouchesInView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)prepareForDie
{
    [self.target removeGestureRecognizer:self.tapRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self prepareForDie];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if (!self.isKeyboardShown)
    {
        self.isKeyboardShown = YES;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (self.isKeyboardShown)
    {
        self.isKeyboardShown = NO;
        [self handleKeyboardWithNotification:aNotification];
    }
}

- (UIView *)findViewThatIsFirstResponderInParent:(UIView*)parent
{
    if (parent.isFirstResponder)
    {
        return parent;
    }
    
    for (UIView *subView in parent.subviews)
    {
        UIView *firstResponder = [self findViewThatIsFirstResponderInParent:subView];
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}

- (void)handleKeyboardWithNotification:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    kbHeight = self.isKeyboardShown ? kbHeight : -kbHeight;
    
    UIView* responder = [self findViewThatIsFirstResponderInParent:self.target];
    
    [UIView animateWithDuration:duration animations:ANMainQueueBlockFromCompletion(^{
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.target.contentInset.top,
                                                      0.0,
                                                      self.target.contentInset.bottom + kbHeight,
                                                      0.0);
        if (self.handleKeyboard)
        {
            self.target.contentInset = contentInsets;
            self.target.scrollIndicatorInsets = contentInsets;
            if (responder)
            {
                [self.target scrollRectToVisible:[self.target convertRect:responder.frame fromView:responder.superview]
                                        animated:NO];
            }
        }
        if (self.animationBlock)
        {
            self.animationBlock(kbHeight);
        }
    }) completion:^(BOOL finished) {
        if (self.animationCompletion)
        {
            self.animationCompletion(self.isKeyboardShown);
        }
    }];
}

- (void)hideKeyboard
{
    [self.target endEditing:YES];
}

@end
