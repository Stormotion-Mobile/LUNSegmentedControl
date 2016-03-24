//
//  LUNSegmentedControl.h
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 2/10/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LUNSegmentedControl;

typedef NS_ENUM(NSUInteger, LUNSegmentedControlTransitionStyle) {
    LUNSegmentedControlTransitionStyleSlide,
    LUNSegmentedControlTransitionStyleFade
};

typedef NS_ENUM(NSUInteger, LUNSegmentedControlShapeStyle) {
    LUNSegmentedControlShapeStyleRoundedRect,
    LUNSegmentedControlShapeStyleLiquid
};

typedef NS_ENUM(NSUInteger, LUNSegmentedControlBounce) {
    LUNSegmentedControlBounceLeft,
    LUNSegmentedControlBounceRight
};

@protocol LUNSegmentedControlDelegate <NSObject>

@optional
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didChangeStateFromStateAtIndex:(NSInteger)fromIndex toStateAtIndex:(NSInteger)toIndex;
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl willChangeStateFromStateAtIndex:(NSInteger)fromIndex;
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didScrollWithXOffset:(CGFloat)offset;
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl setupStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView withSelectionPercent:(CGFloat)percent;
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl resetStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView;

@end

@protocol LUNSegmentedControlDataSource <NSObject>

@required
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl;

@optional
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index;
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForBounce:(LUNSegmentedControlBounce)bounce;
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index;
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index;
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForSelectedStateAtIndex:(NSInteger)index;
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index;
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForStateAtIndex:(NSInteger)index;
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForSelectedStateAtIndex:(NSInteger)index;

@end

@interface LUNSegmentedControl : UIView

@property (nonatomic, weak) IBOutlet id <LUNSegmentedControlDelegate> delegate;
@property (nonatomic, weak) IBOutlet id <LUNSegmentedControlDataSource> dataSource;

@property (nonatomic, assign) NSInteger currentState;
@property (nonatomic, assign) NSInteger statesCount;

@property (nonatomic, assign) LUNSegmentedControlTransitionStyle transitionStyle;
@property (nonatomic, assign) LUNSegmentedControlShapeStyle shapeStyle;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, strong) IBInspectable UIColor *textColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedStateTextColor;
@property (nonatomic, strong) IBInspectable UIColor *selectorViewColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) BOOL applyCornerRadiusToSelectorView;
@property (nonatomic, strong) UIColor *gradientBounceColor;
@property (nonatomic, assign) CGFloat shadowShowDuration;
@property (nonatomic, assign) CGFloat shadowHideDuration;
@property (nonatomic, assign) BOOL shadowsEnabled;

- (void)reloadData;

@end
