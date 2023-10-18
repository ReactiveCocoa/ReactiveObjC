//
//  UIAlertController+RACSignalSupport.m
//  ReactiveObjC
//
//  Created by Gao on 2023-10-18
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+RACDeallocating.h"
#import "NSObject+RACDescription.h"
#import "RACDelegateProxy.h"
#import "RACSignal+Operations.h"
#import "UIAlertController+RACSignalSupport.h"

@implementation UIAlertController (RACSignalSupport)

static void RACUseDelegateProxy(UIAlertController *self) {
  if (self.popoverPresentationController.delegate == self.rac_delegateProxy) return;

  self.rac_delegateProxy.rac_proxiedDelegate = self.popoverPresentationController.delegate;
  self.popoverPresentationController.delegate = (id)self.rac_delegateProxy;

  //	if (self.delegate == self.rac_delegateProxy) return;
  //
  //	self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
  //	self.delegate = (id)self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
  RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
  if (proxy == nil) {
    proxy = [[RACDelegateProxy alloc]
        initWithProtocol:@protocol(UIViewControllerTransitioningDelegate)];
    objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  return proxy;
}

- (RACSignal *)rac_buttonClickedSignal {
  RACSignal *signal =
      [[[[self.rac_delegateProxy signalForSelector:@selector(alertController:didSelectAction:)]
          reduceEach:^(UIAlertController *alertController, UIAlertAction *action) {
            return @(alertController.actions.firstObject == action
                         ? 0
                         : [alertController.actions indexOfObject:action] + 1);
          }] takeUntil:self.rac_willDeallocSignal]
          setNameWithFormat:@"%@ -rac_buttonClickedSignal", RACDescription(self)];

  RACUseDelegateProxy(self);

  return signal;
}

- (RACSignal *)rac_willDismissSignal {
  RACSignal *signal = [[[[self.rac_delegateProxy signalForSelector:@selector(alertController:
                                                                       willDismissWithAction:)]
      reduceEach:^(UIAlertController *alertController, UIAlertAction *action) {
        return action;
      }] takeUntil:self.rac_willDeallocSignal]
      setNameWithFormat:@"%@ -rac_willDismissSignal", RACDescription(self)];

  RACUseDelegateProxy(self);

  return signal;
}

#pragma mark - UIAlertControllerDelegate

- (void)alertController:(UIAlertController *)alertController
        didSelectAction:(UIAlertAction *)action {
  // 这里可以在用户点击按钮时执行一些操作
}

- (void)alertController:(UIAlertController *)alertController
    willDismissWithAction:(UIAlertAction *)action {
  // 这里可以在用户点击按钮时执行一些操作
}

@end
