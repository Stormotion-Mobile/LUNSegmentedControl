//
//  UIView+LUNRemoveConstraints.h
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 3/23/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief Category of UIView that provide method to remove set of constraints from view subtree.
 */
@interface UIView (LUNRemoveConstraints)

/**
 *  @brief Remove specified set of constraints from views in receiver subtree and from receiver itself.
 *
 *  @param constraints Set of constraints to remove.
 */
- (void)lun_removeConstraintsFromSubTree:(NSSet <NSLayoutConstraint *> *)constraints;

@end
