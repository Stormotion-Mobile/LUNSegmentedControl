//
//  LUNSegmentedControl.m
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 2/10/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import "LUNSegmentedControl.h"
#import "LUNGradientView.h"
#import "UIView+LUNRemoveConstraints.h"

@interface LUNSegmentedControl() <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *leftSpacerView;
@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *rightSpacerView;
@property (nonatomic, strong) UIView *leftLimiterView;
@property (nonatomic, strong) UIView *rightLimiterView;
@property (nonatomic, strong) UIView *gradientViewContainer;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) LUNGradientView *gradientView;
@property (nonatomic, strong) NSMutableArray <UIView *> *stateViewContainers;
@property (nonatomic, strong) NSMutableArray <UIView *> *stateViews;
@property (nonatomic, strong) NSMutableArray <UIView *> *selectedStateViewContainers;
@property (nonatomic, strong) NSMutableArray <UIView *> *selectedStateViews;
@property (nonatomic, strong) NSMutableSet <NSNumber *> *changedViews;
@property (nonatomic, assign) CGPathRef selectorViewPath;
@property (nonatomic, assign) CGFloat gradientBackVelocity;
@property (nonatomic, strong) NSLayoutConstraint *gradientViewLeftConstraint;
@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *addedConstraintsToRemove;
@property (nonatomic, assign) BOOL viewWasLayoutSubviews;
@property (nonatomic, assign) BOOL layoutDependentValuesWasUpdated;

@end

@implementation LUNSegmentedControl

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self baseInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}
- (void)baseInit {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
    self.layer.masksToBounds = NO;
    self.stateViews = [[NSMutableArray alloc] init];
    self.stateViewContainers = [[NSMutableArray alloc] init];
    self.changedViews = [[NSMutableSet alloc] init];
    self.selectedStateViews = [[NSMutableArray alloc] init];
    self.selectedStateViewContainers = [[NSMutableArray alloc] init];
    self.addedConstraintsToRemove = [[NSMutableArray alloc] init];
    [self initDefaults];
    [self initViews];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIfNeeded];
    self.viewWasLayoutSubviews = YES;
    if (!self.layoutDependentValuesWasUpdated) {
        [self updateLayoutDependentValues];
    }
}

#pragma mark - Init defaults
- (void)initDefaults {
    self.textColor = [UIColor blackColor];
    self.selectedStateTextColor = [UIColor whiteColor];
    self.selectorViewColor = [UIColor greenColor];
    self.textFont = [UIFont systemFontOfSize:14];
    self.transitionStyle = LUNSegmentedControlTransitionStyleFade;
    self.shapeStyle = LUNSegmentedControlShapeStyleLiquid;
    self.applyCornerRadiusToSelectorView = NO;
    self.gradientBounceColor = [UIColor redColor];
    self.gradientBackVelocity = 1;
    self.shadowsEnabled = YES;
    self.shadowHideDuration = 0.8;
    self.shadowShowDuration = 0.5;
}

#pragma mark - Init views
- (void)initViews {
    [self initScrollView];
    [self initLeftSpacerView];
    [self initSelectorView];
    [self initRightSpacerView];
    [self initLeftLimiterView];
    [self initRightLimiterView];
    [self initGradientView];
    [self initShadowView];
    [self initTapGestureRecognizers];
}
- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.layer.masksToBounds = YES;
    [self addSubview:self.scrollView];
    [self bringSubviewToFront:self.scrollView];
}
- (void)initLeftSpacerView {
    self.leftSpacerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.leftSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.leftSpacerView];
}
- (void)initSelectorView {
    self.selectorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectorView.clipsToBounds = YES;
    self.selectorView.layer.mask = [CAShapeLayer layer];
    [self.scrollView addSubview:self.selectorView];
    self.selectorView.backgroundColor = self.selectorViewColor;
}
- (void)initRightSpacerView {
    self.rightSpacerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.rightSpacerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.rightSpacerView];
}
- (void)initLeftLimiterView {
    self.leftLimiterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.leftLimiterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.leftLimiterView aboveSubview:self.scrollView];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.leftLimiterView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    leftConstraint.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:leftConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLimiterView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.selectorView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLimiterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftLimiterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}
- (void)initRightLimiterView {
    self.rightLimiterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.rightLimiterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.rightLimiterView aboveSubview:self.scrollView];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.rightLimiterView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    rightConstraint.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:rightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLimiterView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.selectorView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLimiterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightLimiterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}
- (void)initTapGestureRecognizers {
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWasRecognized:)];
    [self.leftLimiterView addGestureRecognizer:leftTap];
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWasRecognized:)];
    [self.rightLimiterView addGestureRecognizer:rightTap];
}
- (void)initGradientView {
    UIView *fakeView = [[UIView alloc] initWithFrame:CGRectZero];
    fakeView.clipsToBounds = YES;
    fakeView.layer.masksToBounds = YES;
    fakeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:fakeView atIndex:0];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:fakeView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:fakeView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fakeView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fakeView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    self.gradientView = [[LUNGradientView alloc] initWithFrame:CGRectZero];
    self.gradientView.translatesAutoresizingMaskIntoConstraints = NO;
    [fakeView addSubview:self.gradientView];
    self.gradientViewContainer = fakeView;
}
- (void)initShadowView {
    self.shadowView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.userInteractionEnabled = NO;
    [self addSubview:self.shadowView];
    [self setupViewConstraints:self.shadowView withContainer:self];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.shadowView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.shadowView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.shadowView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:constraint];
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.shadowView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraint:constraint];
}

#pragma mark - Setup constraints

- (void)setupLeftSpacerViewConstraints {
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.leftSpacerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:constraint];
    [self.addedConstraintsToRemove addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftSpacerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:self.spacerViewWidthMultiplier constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftSpacerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftSpacerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.leftSpacerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
}
- (void)setupSelectorViewConstraints {
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:self.selectorViewWidthMultiplier constant:0];
    [self addConstraint:constraint];
    [self.addedConstraintsToRemove addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftSpacerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:constraint];
    [self.addedConstraintsToRemove addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.scrollView addConstraint:constraint];
    [self.addedConstraintsToRemove addObject:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.selectorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.scrollView addConstraint:constraint];
    [self.addedConstraintsToRemove addObject:constraint];
}
- (void)setupRightSpacerViewConstraints {
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:self.spacerViewWidthMultiplier constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.selectorView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.rightSpacerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self.scrollView addConstraint:constraint];
}
- (void)setupScrollViewContstraints {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
}
- (void)setupGradientViewContstraints {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:((self.statesCount + 2) + (self.statesCount + 1) * self.gradientBackVelocity) / self.statesCount constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [self addConstraint:constraint];
    
    self.gradientViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.gradientView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:self.gradientViewLeftConstraint];
    [self addConstraint:self.gradientViewLeftConstraint];
}
- (void)setupFirstViewConstraints:(UIView *)view {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
}
- (void)setupViewConstraints:(UIView *)view withPreviousView:(UIView *)previousView {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
}
- (void)setupLastViewRightConstraint:(UIView *)view {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [view.superview addConstraint:constraint];
    
    BOOL widthConstraintIsInstalled = NO;
    for (NSLayoutConstraint *constraint in view.superview.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth && (constraint.firstItem == view || constraint.secondItem == view)) {
            widthConstraintIsInstalled = YES;
        }
    }
    if (!widthConstraintIsInstalled) {
        constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        [self.addedConstraintsToRemove addObject:constraint];
        [view.superview addConstraint:constraint];
    }
}
- (void)setupViewConstraints:(UIView *)view withContainer:(UIView *)container {
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [container addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [container addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [container addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.addedConstraintsToRemove addObject:constraint];
    [container addConstraint:constraint];
    
}

#pragma mark - Gradient
- (void)setupGradientWithPercent:(CGFloat)percent offsetFactor:(CGFloat)offsetFactor {
    if (!self.gradientView.layer.mask) {
        self.gradientView.layer.mask = [CAShapeLayer layer];
    }
    self.gradientViewLeftConstraint.constant = (-1 - offsetFactor * self.statesCount) * self.selectorView.bounds.size.width * (1 + self.gradientBackVelocity) + self.selectorView.bounds.size.width * offsetFactor * self.statesCount;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-self.gradientViewLeftConstraint.constant + self.selectorView.bounds.size.width * offsetFactor * self.statesCount, 0);
    ((CAShapeLayer *)self.gradientView.layer.mask).path = CGPathCreateCopyByTransformingPath([self pathForSelectorViewFromPercentage:percent], &transform);
}
- (void)setupGradientViewWithCount:(NSInteger)count {
    if (![self dataSourceProvideGradient]) {
        return ;
    }
    NSMutableArray <NSNumber *> *locations = [[NSMutableArray alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [self setupColorsArray:colors withCount:count];
    [self setupLocationsArray:locations withCount:count];
    ((CAGradientLayer *)self.gradientView.layer).locations = locations;
    ((CAGradientLayer *)self.gradientView.layer).colors = colors;
    ((CAGradientLayer *)self.gradientView.layer).startPoint = CGPointMake(0, 0);
    ((CAGradientLayer *)self.gradientView.layer).endPoint = CGPointMake(1, 0);
}
- (void)setupColorsArray:(NSMutableArray *)colors withCount:(NSInteger)count {
    for (NSInteger index = -1; index <= count; index++) {
        NSArray <UIColor *> *stateColors;
        if (index == -1) {
            stateColors = [self gradientColorForBounce:LUNSegmentedControlBounceLeft];
        }
        if (index >= 0 && index < count) {
            stateColors = [self gradientColorForStateAtIndex:index];
        }
        if (index == count) {
            stateColors = [self gradientColorForBounce:LUNSegmentedControlBounceRight];
        }
        if (stateColors.count == 0) {
            continue;
        }
        for (UIColor *color in stateColors) {
            [colors addObject:(id)color.CGColor];
        }
    }
}
- (void)setupLocationsArray:(NSMutableArray *)locations withCount:(NSInteger)count {
    for (NSInteger index = -1; index <= count; index++) {
        NSArray <UIColor *> *stateColors;
        if (index == -1) {
            stateColors = [self gradientColorForBounce:LUNSegmentedControlBounceLeft];
        }
        if (index >= 0 && index < count) {
            stateColors = [self gradientColorForStateAtIndex:index];
        }
        if (index == count) {
            stateColors = [self gradientColorForBounce:LUNSegmentedControlBounceRight];
        }
        if (stateColors.count == 0) {
            continue;
        }
        NSInteger stateColorsCount = stateColors.count;
        for (NSInteger colorIndex = 0; colorIndex < stateColorsCount; colorIndex++) {
            [locations addObject:@([self gradientLocationForStateAtIndex:index colorIndex:colorIndex colorsCount:stateColorsCount statesCount:count])];
        }
    }
}
- (NSArray <UIColor *> *)gradientColorForStateAtIndex:(NSInteger)index {
    NSMutableArray <UIColor *> *array = [[NSMutableArray alloc] initWithArray:[self.dataSource segmentedControl:self gradientColorsForStateAtIndex:index]];
    if (array.count == 1) {
        [array addObject:array.firstObject];
    }
    return array;
}
- (NSArray <UIColor *> *)gradientColorForBounce:(LUNSegmentedControlBounce)bounce {
    NSMutableArray <UIColor *> *colors = nil;
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:gradientColorsForBounce:)]) {
        colors = [[NSMutableArray alloc] initWithArray:[self.dataSource segmentedControl:self gradientColorsForBounce:bounce]];
    }
    if (!colors) {
        colors = [[NSMutableArray alloc] initWithArray:@[self.gradientBounceColor]];
    }
    if (colors.count == 1) {
        [colors addObject:colors.firstObject];
    }
    return colors;
}

#pragma mark - State views
- (void)setupSelectedLabel:(UILabel *)label forStateAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:titleForSelectedStateAtIndex:)]) {
        label.text = [self.dataSource segmentedControl:self titleForSelectedStateAtIndex:index];
        label.font = self.textFont;
    }
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:attributedTitleForSelectedStateAtIndex:)]) {
        label.attributedText = [self.dataSource segmentedControl:self attributedTitleForSelectedStateAtIndex:index];
    }
    label.textColor = self.selectedStateTextColor;
    label.textAlignment = NSTextAlignmentCenter;
}
- (void)setupLabel:(UILabel *)label forStateAtIndex:(NSInteger)index selected:(BOOL)selected {
    if (selected && [self dataSourceProvideSelectedTitles]) {
        [self setupSelectedLabel:label forStateAtIndex:index];
        return ;
    }
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:titleForStateAtIndex:)]) {
        label.text = [self.dataSource segmentedControl:self titleForStateAtIndex:index];
        label.font = self.textFont;
    }
    if ([self.dataSource respondsToSelector:@selector(segmentedControl:attributedTitleForStateAtIndex:)]) {
        label.attributedText = [self.dataSource segmentedControl:self attributedTitleForStateAtIndex:index];
    }
    label.textColor = selected ? self.selectedStateTextColor : self.textColor;
    label.textAlignment = NSTextAlignmentCenter;
}
- (UIView *)viewForStateAtIndex:(NSInteger)index {
    UIView *view;
    if ([self dataSourceProvideViews]) {
        view = [self.dataSource segmentedControl:self viewForStateAtIndex:index];
    } else {
        NSAssert([self dataSourceProvideTitles], @"Data source should provide titles/attribute titles or views.");
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self setupLabel:label forStateAtIndex:index selected:NO];
        view = label;
    }
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}
- (UIView *)selectedViewForStateAtIndex:(NSInteger)index {
    UIView *view;
    if ([self dataSourceProvideSelectedViews]) {
        view = [self.dataSource segmentedControl:self viewForSelectedStateAtIndex:index];
    } else if ([self dataSourceProvideViews]) {
        view = [self.dataSource segmentedControl:self viewForStateAtIndex:index];
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self setupLabel:label forStateAtIndex:index selected:YES];
        view = label;
    }
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}
- (void)setupStateViewAtIndex:(NSInteger)index withSelectionPercent:(CGFloat)percent {
    if (percent < 1 && percent > -1) {
        [self.changedViews addObject:@(index)];
    }
    switch (self.transitionStyle) {
        case LUNSegmentedControlTransitionStyleFade: {
            self.selectedStateViewContainers[index].alpha = 1 - fabs(percent);
            self.stateViewContainers[index].alpha = fabs(percent);
            break;
        }
            
        case LUNSegmentedControlTransitionStyleSlide: {
            UIView *stateView = self.selectedStateViewContainers[index];
            if (!stateView.layer.mask) {
                stateView.layer.mask = [CAShapeLayer layer];
            }
            CGAffineTransform transform = CGAffineTransformMakeTranslation(stateView.bounds.size.width * percent, 0);
            ((CAShapeLayer *)stateView.layer.mask).path = CGPathCreateCopyByTransformingPath([self pathForSelectorViewFromPercentage:percent], &transform);
            break;
        }
            
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(segmentedControl:setupStateAtIndex:stateView:selectedView:withSelectionPercent:)]) {
        [self.delegate segmentedControl:self setupStateAtIndex:index stateView:self.stateViewContainers[index] selectedView:self.selectedStateViewContainers[index] withSelectionPercent:percent];
    }
}
- (void)deselectStateViewAtIndex:(NSInteger)index {
    [self setupStateViewAtIndex:index withSelectionPercent:1];
}
- (void)selectStateViewAtIndex:(NSInteger)index {
    [self setupStateViewAtIndex:index withSelectionPercent:0];
}
- (void)resetStateViewAtIndex:(NSInteger)index {
    UIView *stateView = [self.stateViewContainers objectAtIndex:index];
    stateView.alpha = 1;
    UIView *selectedView = [self.selectedStateViewContainers objectAtIndex:index];
    selectedView.alpha = 1;
    selectedView.layer.mask = nil;
    if ([self.delegate respondsToSelector:@selector(segmentedControl:resetStateAtIndex:stateView:selectedView:)]) {
        [self.delegate segmentedControl:self resetStateAtIndex:index stateView:stateView selectedView:selectedView];
    }
}
- (void)setupStateViewsWithCount:(NSInteger)count {
    for (NSInteger index = 0; index < count; index ++) {
        UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectZero];
        viewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        viewContainer.userInteractionEnabled = NO;
        viewContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:viewContainer];
        [self.stateViewContainers addObject:viewContainer];
        if (0 == index) {
            [self setupFirstViewConstraints:viewContainer];
        } else {
            [self setupViewConstraints:viewContainer withPreviousView:[self.stateViewContainers objectAtIndex:index - 1]];
        }
    }
    [self setupLastViewRightConstraint:[self.stateViewContainers objectAtIndex:count - 1]];
    for (NSInteger index = 0; index < count; index++) {
        UIView *view = [self viewForStateAtIndex:index];
        UIView *viewContainer = self.stateViewContainers[index];
        [viewContainer addSubview:view];
        [self.stateViews addObject:view];
        [self setupViewConstraints:view withContainer:viewContainer];
    }
}
- (void)setupSelectedStateViewsWithCount:(NSInteger)count {
    for (NSInteger index = 0; index < count; index ++) {
        UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectZero];
        viewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        viewContainer.userInteractionEnabled = NO;
        viewContainer.backgroundColor = [UIColor clearColor];
        [self insertSubview:viewContainer aboveSubview:self.stateViewContainers[index]];
        [self.selectedStateViewContainers addObject:viewContainer];
        if (0 == index) {
            [self setupFirstViewConstraints:viewContainer];
        } else {
            [self setupViewConstraints:viewContainer withPreviousView:[self.selectedStateViewContainers objectAtIndex:index - 1]];
        }
    }
    [self setupLastViewRightConstraint:[self.selectedStateViewContainers objectAtIndex:count - 1]];
    for (NSInteger index = 0; index < count; index++) {
        UIView *view = [self selectedViewForStateAtIndex:index];
        UIView *viewContainer = self.selectedStateViewContainers[index];
        [viewContainer addSubview:view];
        [self.selectedStateViews addObject:view];
        [self setupViewConstraints:view withContainer:viewContainer];
    }
}

#pragma mark - Shadow
- (UIColor *)shadowColorForStateAtIndex:(NSInteger)index {
    if ([self dataSourceProvideGradient]) {
        return [self.dataSource segmentedControl:self gradientColorsForStateAtIndex:index].firstObject;
    }
    return self.selectorViewColor;
}
- (void)setupShadowForStateAtIndex:(NSInteger)index visible:(BOOL)visible animated:(BOOL)animated {
    self.shadowView.layer.shadowColor = [self shadowColorForStateAtIndex:index].CGColor;
    self.shadowView.layer.shadowRadius = 7.0;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 5);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.stateViews[index].bounds.size.width * [self percentFromOffset:[self offsetFromState:index]], 0);
    self.shadowView.layer.shadowPath = CGPathCreateCopyByTransformingPath([self pathForSelectorViewFromPercentage:0], &transform);
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        animation.duration = visible?self.shadowShowDuration:self.shadowHideDuration;
        animation.toValue = @(visible ? 0.7 : 0.0);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.shadowView.layer addAnimation:animation forKey:nil];
    } else {
        self.shadowView.layer.shadowOpacity = visible ? 0.7 : 0.0;
    }
}

#pragma mark - Data source
- (BOOL)dataSourceProvideTitles {
    if (!self.dataSource) {
        return NO;
    }
    if (![self.dataSource respondsToSelector:@selector(segmentedControl:titleForStateAtIndex:)] && ![self.dataSource respondsToSelector:@selector(segmentedControl:attributedTitleForStateAtIndex:)]) {
        return NO;
    }
    return YES;
}
- (BOOL)dataSourceProvideSelectedTitles {
    if (!self.dataSource) {
        return NO;
    }
    if (![self.dataSource respondsToSelector:@selector(segmentedControl:titleForSelectedStateAtIndex:)] && ![self.dataSource respondsToSelector:@selector(segmentedControl:attributedTitleForSelectedStateAtIndex:)]) {
        return NO;
    }
    return YES;
}
- (BOOL)dataSourceProvideViews {
    if (!self.dataSource) {
        return NO;
    }
    return [self.dataSource respondsToSelector:@selector(segmentedControl:viewForStateAtIndex:)];
}
- (BOOL)dataSourceProvideSelectedViews {
    if (!self.dataSource) {
        return NO;
    }
    return [self.dataSource respondsToSelector:@selector(segmentedControl:viewForSelectedStateAtIndex:)];
}
- (BOOL)dataSourceProvideGradient {
    if (!self.dataSource) {
        return NO;
    }
    return [self.dataSource respondsToSelector:@selector(segmentedControl:gradientColorsForStateAtIndex:)];
}

#pragma mark - Reload
- (void)reinstallConstraints {
    [self setupLeftSpacerViewConstraints];
    [self setupSelectorViewConstraints];
    [self setupRightSpacerViewConstraints];
    [self setupScrollViewContstraints];
    [self setupGradientViewContstraints];
}
- (void)removeOldConstraints {
    [self lun_removeConstraintsFromSubTree:[NSSet setWithArray:self.addedConstraintsToRemove]];
    [self.addedConstraintsToRemove removeAllObjects];
}
- (void)reinstallViews {
    for (UIView *view in self.stateViewContainers) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.selectedStateViewContainers) {
        [view removeFromSuperview];
    }
    [self.stateViews removeAllObjects];
    [self.selectedStateViews removeAllObjects];
    [self.stateViewContainers removeAllObjects];
    [self.selectedStateViewContainers removeAllObjects];
    NSInteger count = [self.dataSource numberOfStatesInSegmentedControl:self];
    [self setupStateViewsWithCount:count];
    [self setupSelectedStateViewsWithCount:count];
    [self setupGradientViewWithCount:count];
}
- (void)updateTransitionStyle {
    for (NSInteger index = 0; index < self.statesCount; index++){
        [self resetStateViewAtIndex:index];
        [self deselectStateViewAtIndex:index];
    }
    [self selectStateViewAtIndex:self.currentState];
}
- (void)reloadData {
    if (!self.dataSource) {
        NSLog(@"Can't reload segmented control data without specified data source.");
        return ;
    }
    self.layoutDependentValuesWasUpdated = NO;
    self.statesCount = [self.dataSource numberOfStatesInSegmentedControl:self];
    [self removeOldConstraints];
    [self reinstallViews];
    [self reinstallConstraints];
    [self sendSubviewToBack:self.scrollView];
    [self sendSubviewToBack:self.gradientViewContainer];
    [self updateTransitionStyle];
    if (self.viewWasLayoutSubviews) {
        [self updateLayoutDependentValues];
    }
}
- (void)updateLayoutDependentValues {
    self.currentState = 0;
    self.layoutDependentValuesWasUpdated = YES;
}

#pragma mark - Setters
- (void)setDataSource:(id<LUNSegmentedControlDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}
- (void)setSelectorViewColor:(UIColor *)selectorViewColor {
    _selectorViewColor = selectorViewColor;
    self.selectorView.backgroundColor = selectorViewColor;
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.scrollView.layer.cornerRadius = cornerRadius;
    self.gradientViewContainer.layer.cornerRadius = cornerRadius;
    if (self.applyCornerRadiusToSelectorView) {
        self.selectorView.layer.cornerRadius = cornerRadius;
    } else {
        self.selectorView.layer.cornerRadius = 0;
    }
}
- (void)setTransitionStyle:(LUNSegmentedControlTransitionStyle)transitionStyle {
    _transitionStyle = transitionStyle;
    if (self.statesCount > 0) {
        [self updateTransitionStyle];
    }
}
- (void)setSelectorViewPath:(CGPathRef)selectorViewPath {
    if (!self.selectorView.layer.mask) {
        self.selectorView.layer.mask = [CAShapeLayer layer];
    }
    ((CAShapeLayer *)self.selectorView.layer.mask).path = selectorViewPath;
    _selectorViewPath = selectorViewPath;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(segmentedControl:willChangeStateFromStateAtIndex:)]) {
        [self.delegate segmentedControl:self willChangeStateFromStateAtIndex:self.currentState];
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.dataSource) {
        *targetContentOffset = [self nearestStateOffsetFromOffset:*targetContentOffset];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > self.bounds.size.width - self.selectorView.bounds.size.width) {
        return ;
    }
    [self changeStateToState:[self stateFromOffset:scrollView.contentOffset]];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self changeStateToState:[self stateFromOffset:scrollView.contentOffset]];
    self.userInteractionEnabled = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(segmentedControl:didScrollWithXOffset:)]) {
        [self.delegate segmentedControl:self didScrollWithXOffset:self.frame.size.width - self.scrollView.contentOffset.x - self.selectorView.frame.size.width];
    }
    if ([self offsetFromState:[self stateFromOffset:scrollView.contentOffset]].x != scrollView.contentOffset.x) {
        [self setupShadowForStateAtIndex:self.currentState visible:NO animated:YES];
    }
    CGFloat percent = [self percentFromOffset:scrollView.contentOffset];
    NSInteger leftIndex = [self leftStateIndexFromPercentage:percent];
    NSInteger rightIndex = [self rightStateIndexFromPercentage:percent];
    [self.changedViews minusSet:[self.changedViews objectsPassingTest:^BOOL(NSNumber * _Nonnull number, BOOL * _Nonnull stop) {
        if (number.integerValue == leftIndex) return NO;
        if (number.integerValue == rightIndex) return NO;
        [self deselectStateViewAtIndex:number.integerValue];
        return YES;
    }]];
    CGFloat factor = percent - floor(percent);
    self.selectorViewPath = [self pathForSelectorViewFromPercentage:factor];
    if (leftIndex >= 0 && leftIndex < self.statesCount) {
        [self setupStateViewAtIndex:leftIndex withSelectionPercent:factor];
    }
    if (rightIndex >= 0 && rightIndex < self.statesCount) {
        [self setupStateViewAtIndex:rightIndex withSelectionPercent:factor - 1];
    }
    [self setupGradientWithPercent:factor offsetFactor:percent / self.statesCount];
}

#pragma mark - Tap handling
- (void)tapWasRecognized:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    self.userInteractionEnabled = NO;
    [self setCurrentState:[self stateFromTapPoint:point] animated:YES];
}

#pragma mark - States
- (void)changeStateToState:(NSInteger)state {
    NSInteger currentState = self.currentState;
    _currentState = state;
    if (self.shadowsEnabled) {
        [self setupShadowForStateAtIndex:state visible:YES animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedControl:didChangeStateFromStateAtIndex:toStateAtIndex:)]) {
        [self.delegate segmentedControl:self didChangeStateFromStateAtIndex:currentState toStateAtIndex:state];
    }
}
- (void)setCurrentState:(NSInteger)currentState {
    [self setCurrentState:currentState animated:NO];
}
- (void)setCurrentState:(NSInteger)currentState animated:(BOOL)animated {
    if (!self.dataSource) {
        NSLog(@"Warning! Data source of segmented control:%@ wasn't setted. In order to use segmented control set its data source.",self);
        return ;
    }
    NSAssert(currentState < self.statesCount && currentState >= 0, @"Unable to set state %li. Segmented control has only %li states from 0 to %li.",(long)currentState, (long)self.statesCount, (long)(self.statesCount-1));
    if (!animated) {
        _currentState = currentState;
        if (self.shadowsEnabled) {
            [self setupShadowForStateAtIndex:currentState visible:YES animated:NO];
        }
    }
    [self.scrollView setContentOffset:[self offsetFromState:currentState] animated:animated];
}

#pragma mark - Calculations
- (CGFloat)gradientLocationForBounce:(LUNSegmentedControlBounce)bounce colorIndex:(NSInteger)index colorsCount:(NSInteger)colorsCount statesCount:(NSInteger)statesCount {
    CGFloat totalCount = statesCount + 2 + (statesCount + 1) * self.gradientBackVelocity;
    switch (bounce) {
        case LUNSegmentedControlBounceLeft:
            return index * 1.0 / (colorsCount - 1) / totalCount;
            break;
            
        case LUNSegmentedControlBounceRight:
            return (totalCount - 1 + index * 1.0 / (colorsCount - 1)) / totalCount;
            break;
            
        default:
            break;
    }
    return 0;
}
- (CGFloat)gradientLocationForStateAtIndex:(NSInteger)stateIndex colorIndex:(NSInteger)colorIndex colorsCount:(NSInteger)colorsCount statesCount:(NSInteger)statesCount {
    CGFloat totalCount = statesCount + 2 + (statesCount + 1) * self.gradientBackVelocity;
    CGFloat offset = 1 + stateIndex + (stateIndex + 1) * self.gradientBackVelocity;
    return (offset + colorIndex * 1.0 / (colorsCount - 1)) / totalCount;
}
- (CGPathRef)pathForSelectorViewFromPercentage:(CGFloat)percent {
    switch (self.shapeStyle) {
        case LUNSegmentedControlShapeStyleRoundedRect:
            return [self roundedRectPathForSelectorViewFromPercentage:percent].CGPath;
            
        case LUNSegmentedControlShapeStyleLiquid:
            return [self dribblePathForSelectorViewFromPercentage:percent].CGPath;
            
        default:
            break;
    }
    return nil;
}
- (UIBezierPath *)dribblePathForSelectorViewFromPercentage:(CGFloat)percent {
    if (percent < 0) {
        percent += 1;
    }
    CGFloat height = CGRectGetHeight(self.selectorView.frame);
    CGFloat width = CGRectGetWidth(self.selectorView.frame);
    CGPoint p1 = CGPointMake(height / 2, F(percent) * height);
    CGPoint p4 = CGPointMake(width - height / 2, F(1 - percent) * height);
    CGPoint p2;
    CGPoint p3;
    if (percent > 0.3 && percent < 0.7) {
        p2 = CGPointMake(height / 2 + (width - height) / 4, (p1.y * 3 + p4.y) / 4 + height * 0.1 * (0.2 - fabs(0.5 - percent)) / 0.2);
    } else {
        p2 = CGPointMake(height / 2 + (width - height) / 4, (p1.y * 3 + p4.y) / 4);
    }
    
    if (percent > 0.3 && percent < 0.7) {
        p3 = CGPointMake(height / 2 + (width - height) * 3 / 4, (p1.y + p4.y * 3) / 4 + height * 0.1 * (0.2 - fabs(0.5 - percent))/0.2);
    } else {
        p3 = CGPointMake(height / 2 + (width - height) * 3 / 4, (p1.y + p4.y * 3) / 4);
    }
    
    CGFloat length = height / 4;
    CGFloat coef = 1.2;
    CGPoint p12vector = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    normalizeToLength(p12vector, length);
    CGPoint p34vector = CGPointMake(p4.x - p3.x, p4.y - p3.y);
    normalizeToLength(p34vector, length);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, height / 2)];
    [path addCurveToPoint:p1
            controlPoint1:CGPointMake(0, height / 2 - length)
            controlPoint2:CGPointMake(p1.x-p12vector.x, p1.y-p12vector.y)];
    [path addLineToPoint:p2];
    [path addCurveToPoint:p3
            controlPoint1:CGPointMake(p2.x+p12vector.x/coef, p2.y+p12vector.y/coef)
            controlPoint2:CGPointMake(p3.x-p34vector.x/coef, p3.y-p34vector.y/coef)];
    [path addLineToPoint:p4];
    [path addCurveToPoint:CGPointMake(width, height / 2)
            controlPoint1:CGPointMake(p4.x+p34vector.x, p4.y+p34vector.y)
            controlPoint2:CGPointMake(width, height / 2 - length)];
    
    p1.y = height - p1.y;
    p2.y = height - p2.y;
    p3.y = height - p3.y;
    p4.y = height - p4.y;
    p12vector.y = - p12vector.y;
    p34vector.y = - p34vector.y;
    
    [path addCurveToPoint:p4
            controlPoint1:CGPointMake(width, height / 2 + length)
            controlPoint2:CGPointMake(p4.x+p34vector.x, p4.y+p34vector.y)];
    [path addLineToPoint:p3];
    [path addCurveToPoint:p2
            controlPoint1:CGPointMake(p3.x-p34vector.x/coef, p3.y-p34vector.y/coef)
            controlPoint2:CGPointMake(p2.x+p12vector.x/coef, p2.y+p12vector.y/coef)];
    [path addLineToPoint:p1];
    [path addCurveToPoint:CGPointMake(0, height / 2)
            controlPoint1:CGPointMake(p1.x-p12vector.x, p1.y-p12vector.y)
            controlPoint2:CGPointMake(0, height / 2 + length)];
    return path;
}
- (UIBezierPath *)roundedRectPathForSelectorViewFromPercentage:(CGFloat)percent {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.selectorView.bounds cornerRadius:self.cornerRadius];
    return path;
}
- (NSInteger)leftStateIndexFromPercentage:(CGFloat)percent {
    return floor(percent);
}
- (NSInteger)rightStateIndexFromPercentage:(CGFloat)percent {
    return floor(percent) + 1;
}
- (CGFloat)percentFromOffset:(CGPoint)offset {
    offset.x /= self.leftSpacerView.frame.size.width;
    offset.x *= self.statesCount - 1;
    return self.statesCount - 1 - offset.x;
}
- (CGPoint)offsetFromState:(NSInteger)state {
    NSInteger intOffset = self.statesCount - state - 1;
    CGPoint offset = CGPointMake(intOffset, 0);
    offset.x *= self.leftSpacerView.frame.size.width;
    offset.x /= self.statesCount - 1;
    return offset;
}
- (NSInteger)stateFromOffset:(CGPoint)offset {
    offset.x /= self.leftSpacerView.frame.size.width;
    offset.x *= self.statesCount - 1;
    NSInteger intOffset = round(offset.x);
    return self.statesCount - intOffset - 1;
}
- (NSInteger)stateFromTapPoint:(CGPoint)tapPoint {
    tapPoint.x /= self.selectorView.frame.size.width;
    return floor(tapPoint.x);
}
- (CGPoint)nearestStateOffsetFromOffset:(CGPoint)offset {
    offset.x /= self.leftSpacerView.frame.size.width;
    offset.x *= (self.statesCount - 1);
    offset.x = roundf(offset.x);
    offset.x /= (self.statesCount - 1);
    offset.x *= self.leftSpacerView.frame.size.width;
    return offset;
}
- (CGFloat)spacerViewWidthMultiplier {
    return (self.statesCount - 1) / 1.0 / self.statesCount;
}
- (CGFloat)selectorViewWidthMultiplier {
    return 1.0 / self.statesCount;
}

#pragma mark - Liquid shape functions
CGFloat F(CGFloat x) {
    return 192.862*pow(x,8)-786.037*pow(x,7)+1325.23*pow(x,6)-1182.26*pow(x,5)+587.962*pow(x,4)-157.531*pow(x,3)+20.5313*pow(x,2)-0.760045*x;
}
CGPoint normalizeToLength(CGPoint p, CGFloat length) {
    CGFloat currentLength = sqrt(p.x * p.x + p.y * p.y);
    if (currentLength == 0) {
        return CGPointZero;
    }
    return CGPointMake(p.x / currentLength * length, p.y / currentLength * length);
}

@end
