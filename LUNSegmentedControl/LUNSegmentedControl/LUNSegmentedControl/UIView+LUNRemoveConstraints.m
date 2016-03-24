//
//  UIView+LUNRemoveConstraints.m
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 3/23/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import "UIView+LUNRemoveConstraints.h"

@implementation UIView (LUNRemoveConstraints)

- (void)lun_removeConstraintsFromSubTree:(NSSet <NSLayoutConstraint *> *)constraints {
    NSMutableArray <NSLayoutConstraint *> *constraintsToRemove = [[NSMutableArray alloc] init];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraints containsObject:constraint]) {
            [constraintsToRemove addObject:constraint];
        }
    }
    [self removeConstraints:constraintsToRemove];
    for (UIView *view in self.subviews) {
        [view lun_removeConstraintsFromSubTree:constraints];
    }
}

@end
