//
//  ViewController.m
//  LUNSegmentedControl
//
//  Created by Andrii Selivanov on 2/10/16.
//  Copyright © 2016 lunapps. All rights reserved.
//

#import "ViewController.h"
#import "LUNSegmentedControl.h"

@interface ViewController () <LUNSegmentedControlDataSource, LUNSegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet LUNSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *rectangleScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.segmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self segmentedControl:self.segmentedControl didScrollWithXOffset:0];
}

- (NSArray<UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @[[UIColor colorWithRed:160 / 255.0 green:223 / 255.0 blue:56 / 255.0 alpha:1.0], [UIColor colorWithRed:177 / 255.0 green:255 / 255.0 blue:0 / 255.0 alpha:1.0]];
            
            break;
            
        case 1:
            return @[[UIColor colorWithRed:78 / 255.0 green:252 / 255.0 blue:208 / 255.0 alpha:1.0], [UIColor colorWithRed:51 / 255.0 green:199 / 255.0 blue:244 / 255.0 alpha:1.0]];
            break;
            
        case 2:
            return @[[UIColor colorWithRed:178 / 255.0 green:0 / 255.0 blue:235 / 255.0 alpha:1.0], [UIColor colorWithRed:233 / 255.0 green:0 / 255.0 blue:147 / 255.0 alpha:1.0]];
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl {
    return 3;
}

- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index {
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"TAB %li",(long)index] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16]}];
}

- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index {
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"TAB %li",(long)index] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]}];
}


- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didScrollWithXOffset:(CGFloat)offset {
    CGFloat maxOffset = self.segmentedControl.frame.size.width / self.segmentedControl.statesCount * (self.segmentedControl.statesCount - 1);
    CGFloat width = self.view.frame.size.width * 0.7;
    CGFloat leftDistance = (self.backgroundScrollView.contentSize.width - width) * 0.25;
    CGFloat rightDistance = (self.backgroundScrollView.contentSize.width - width) * 0.75;
    CGFloat backgroundScrollViewOffset = leftDistance + ((offset / maxOffset) * (self.backgroundScrollView.contentSize.width - rightDistance - leftDistance));
    width = self.view.frame.size.width;
    leftDistance = -width * 0.75;
    rightDistance = width * 0.5;
    CGFloat rectangleScrollViewOffset = leftDistance + ((offset / maxOffset) * (self.rectangleScrollView.contentSize.width - rightDistance - leftDistance));
    [self.rectangleScrollView setContentOffset:CGPointMake(rectangleScrollViewOffset, 0)];
    [self.backgroundScrollView setContentOffset:CGPointMake(backgroundScrollViewOffset,0)];
}

@end
