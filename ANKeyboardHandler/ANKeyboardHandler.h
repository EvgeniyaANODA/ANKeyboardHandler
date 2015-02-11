//
//  ANKeyboardHandler.h
//
//  Created by Oksana Kovalchuk on 17/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANHelperFunctions.h"

typedef void(^ANKeyboardAnimationBlock)(CGFloat keyboardHeightDelta);
typedef void(^ANKeyboardStateBlock)(BOOL isVisible);

@protocol ANKeyboardEventHandler <NSObject>
@optional

- (void)keyboardWillUpdateToVisible:(BOOL)isVisible withNotification:(NSNotification*)notification;

@end

@interface ANKeyboardHandler : NSObject

@property (nonatomic, weak) id<ANKeyboardEventHandler> eventHandler;
@property (nonatomic, copy) ANKeyboardAnimationBlock animationBlock;
@property (nonatomic, assign) BOOL handleKeyboard;
@property (nonatomic, copy) ANKeyboardStateBlock animationCompletion;

+ (instancetype)handlerWithTarget:(id)target;

- (void)hideKeyboard;
- (void)prepareForDie;

@end
