//
//  LUNSegmentedControl.h
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 2/10/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LUNSegmentedControl;

/**
 *  @brief Style of transition between selected and unselected state of segments.
 */
typedef NS_ENUM(NSUInteger, LUNSegmentedControlTransitionStyle) {
    /**
     *  @brief No transition. This style is preffered with custom transition provided by delegate.
     */
    LUNSegmentedControlTransitionStyleNone = 0,
    /**
     *  @brief Selected state view cutted by selection is showed on top of the unselected state view.
     */
    LUNSegmentedControlTransitionStyleSlide,
    /**
     *  @brief Selected state view alpha is changing to 1.0 and unselected stata view alpha is changing to 0.0 based on current position of selection.
     */
    LUNSegmentedControlTransitionStyleFade
};

/**
 *  @brief Style of selection shape.
 */
typedef NS_ENUM(NSUInteger, LUNSegmentedControlShapeStyle) {
    /**
     *  @brief Rounded rectangle shape.
     */
    LUNSegmentedControlShapeStyleRoundedRect,
    /**
     *  @brief Liquid shape.
     */
    LUNSegmentedControlShapeStyleLiquid
};

/**
 *  @brief Enumeration that represents bounces.
 */
typedef NS_ENUM(NSUInteger, LUNSegmentedControlBounce) {
    /**
     *  @brief Represent left bounce.
     */
    LUNSegmentedControlBounceLeft,
    /**
     *  @brief Represent right bounce.
     */
    LUNSegmentedControlBounceRight
};

/**
 *  @brief LUNSegmentedControl delegate protocol.
 */
@protocol LUNSegmentedControlDelegate <NSObject>

@optional
/**
 *  @brief Tells the delegate that state of segmented control has been just changed.
 *
 *  @param segmentedControl LUNSegmentedControl instance that informs delegate about this event.
 *  @param fromIndex        Previous state of control.
 *  @param toIndex          Currently selected state of control.
 */
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didChangeStateFromStateAtIndex:(NSInteger)fromIndex toStateAtIndex:(NSInteger)toIndex;
/**
 *  @brief Tells the delegate that state of segmented control will be changed.
 *
 *  @param segmentedControl LUNSegmentedControl instance that informs delegate about this event.
 *  @param fromIndex        Currently selected state of control.
 */
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl willChangeStateFromStateAtIndex:(NSInteger)fromIndex;
/**
 *  @brief Tells the delegate that offset of segmented control has been changed.
 *
 *  @param segmentedControl LUNSegmentedControl instance that informs delegate about this event.
 *  @param offset           X coordinate of current segmented control offset.
 */
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didScrollWithXOffset:(CGFloat)offset;
/**
 *  @brief Asks the delegate to setup segment with custom transition style.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks delegate.
 *  @param stateIndex       Index of segment to setup.
 *  @param stateView        View for unselected state of segment.
 *  @param selectedView     View for selected state of segment.
 *  @param percent          Percent of selection. This value is in range [-1..1]. Value -1 represents state when selection right edge is coincident with the left edge of segment. Values from -1 to 0 represent states when selection right edge is moving from the left edge to the right edge of segment. Value 0 represents fully selected state. Values from 0 to 1 represent states when selection left edge is moving from the left edge to the right edge of segment. Value 1 represents state when selection left edge is coincident with the right edge of segment.
 */
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl setupStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView withSelectionPercent:(CGFloat)percent;
/**
 *  @brief Asks the delegate to reset all customization that had been done in segmentedControl:setupStateAtIndex:stateView:selectedView:withSelectionPercent:. This method is designed to handle switching between transition styles.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks delegate.
 *  @param stateIndex       Index of segment to reset.
 *  @param stateView        View for unselected state of segment.
 *  @param selectedView     View for selected state of segment.
 *  @see segmentedControl:setupStateAtIndex:stateView:selectedView:withSelectionPercent:
 */
- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl resetStateAtIndex:(NSInteger)stateIndex stateView:(UIView *)stateView selectedView:(UIView *)selectedView;

@end

/**
 *  @brief LUNSegmentedControl data source protocol.
 */
@protocol LUNSegmentedControlDataSource <NSObject>

@required
/**
 *  @brief Tells the data source to return the number of segments in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *
 *  @return Number of segments.
 */
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl;

@optional
/**
 *  @brief Tells the data source to return colors for selection in segment at index in a segmented control. Returned colors will form a gradient.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Array of colors to form a gradient.
 */
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return colors for bounce in segment at index in a segmented control. Returned colors will form a gradient.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param bounce           Member of LUNSegmentedControlBounce enumeration.
 *
 *  @return Array of colors to form a gradient.
 */
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForBounce:(LUNSegmentedControlBounce)bounce;
/**
 *  @brief Tells the data source to return title for segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return String to be title for segment.
 */
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return attributed title for segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Attributed string to be title for segment.
 */
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return title for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return String to be title for segment in selected state.
 */
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForSelectedStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return attributed title for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return Attributed string to be title for segment in selected state.
 */
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return view for segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return View for segment.
 */
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForStateAtIndex:(NSInteger)index;
/**
 *  @brief Tells the data source to return view for selected state of segment at index in a segmented control.
 *
 *  @param segmentedControl LUNSegmentedControl instance that asks data source.
 *  @param index            Index of segment.
 *
 *  @return View for selected state of segment.
 */
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForSelectedStateAtIndex:(NSInteger)index;

@end

/**
 *  @brief Control designed to let user switch between number of states. It provides many ways of customization.
 */
@interface LUNSegmentedControl : UIView

/**
 *  @brief Delegate of LUNSegmentedControl.
 */
@property (nonatomic, weak) IBOutlet id <LUNSegmentedControlDelegate> delegate;
/**
 *  @brief Data source of LUNSegmentedControl.
 */
@property (nonatomic, weak) IBOutlet id <LUNSegmentedControlDataSource> dataSource;

/**
 *  @brief Number of currently selected segment. It is in range [0..stateCount-1].
 */
@property (nonatomic, assign) NSInteger currentState;
/**
 *  @brief Number of segments in control.
 */
@property (nonatomic, assign) NSInteger statesCount;

/**
 *  @brief Style of transition between selected and unselected state of segments.
 */
@property (nonatomic, assign) LUNSegmentedControlTransitionStyle transitionStyle;
/**
 *  @brief Style of selection shape.
 */
@property (nonatomic, assign) LUNSegmentedControlShapeStyle shapeStyle;
/**
 *  @brief Corner radius of control.
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
/**
 *  @brief Text color applied to title if data source does not provide attributed titles or views.
 */
@property (nonatomic, strong) IBInspectable UIColor *textColor;
/**
 *  @brief Text color applied to title in selected state if data source does not provide attributed titles for selected state or views for selected state.
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedStateTextColor;
/**
 *  @brief Color of selection. It will be overlayed on top of gradient state colors.
 */
@property (nonatomic, strong) IBInspectable UIColor *selectorViewColor;
/**
 *  @brief Text font applied to title in both selected and unselected state if data source does not provide attributed titles or views.
 */
@property (nonatomic, strong) UIFont *textFont;
/**
 *  @brief Value that determine whether shape of selection should be cutted by corner radius of segmented control.
 */
@property (nonatomic, assign) BOOL applyCornerRadiusToSelectorView;
/**
 *  @brief Color applied for bounce if data source does not provide color for bounces.
 */
@property (nonatomic, strong) UIColor *gradientBounceColor;
/**
 *  @brief Duration of shadow showing.
 */
@property (nonatomic, assign) CGFloat shadowShowDuration;
/**
 *  @brief Duration of shadow hiding.
 */
@property (nonatomic, assign) CGFloat shadowHideDuration;
/**
 *  @brief Value that determine wheter shadow should be applied.
 */
@property (nonatomic, assign) BOOL shadowsEnabled;

/**
 *  @brief Reload all data of control.
 */
- (void)reloadData;

@end
