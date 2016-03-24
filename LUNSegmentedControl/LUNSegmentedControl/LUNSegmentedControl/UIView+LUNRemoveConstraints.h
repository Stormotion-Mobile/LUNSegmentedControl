//
//  UIView+LUNRemoveConstraints.h
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 3/23/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LUNRemoveConstraints)

- (void)lun_removeConstraintsFromSubTree:(NSSet <NSLayoutConstraint *> *)constraints;

@end
