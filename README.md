# LUNSegmentedControl

[![Crafted in LunApps](https://lunapps.com/img/crafted-in-lunapps.png)](https://lunapps.com/)

Please check this [article](https://lunapps.com/blog/lunsegmentedcontrol/) on our blog.

Purpose
-------

LUNSegmentedControl is control designed to let developers use segmented control with custom appearance, customizable interactive animation and other pretty things like gradient for states and shadow.

![](https://i2.wp.com/lunapps.com/blog/wp-content/uploads/2016/03/switcher_animation.gif)

Supported OS & SDK Versions
---------------------------

* Supported build target - iOS 8.0
	
ARC Compatibility
-----------------

LUNSegmentedControl requires ARC.

Installation
------------

To use the LUNSegmentedControl in your app, just drag the LUNSegmentedControl folder into your project.

Or you can use CocoaPods 

```ruby
pod 'LUNSegmentedControl'
```

Usage
-----

Add a UIView and change its class to LUNSegmentedControl. Then you need to set its data source (either from the storyboard or programmaticaly).
Implement the data source method that returns the segment count:
```objective-c
- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl;
```
 
Now implement one of the Data Source methods so you can set either a string, an attributed string or a view to be displayed in every segment.
```objective-c
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index;
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index;
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForStateAtIndex:(NSInteger)index;
```
 
If necessary, you can set a string, an attributed string or a view for the selected state for each segment with the help of following Data Source methods:
```objective-c
- (NSString *)segmentedControl:(LUNSegmentedControl *)segmentedControl titleForSelectedStateAtIndex:(NSInteger)index;
- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index;
- (UIView *)segmentedControl:(LUNSegmentedControl *)segmentedControl viewForSelectedStateAtIndex:(NSInteger)index;
```

After that you can set the following parameters (either from the storyboard or programmaticaly) in order to change the way your control looks:
```objective-c
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
```
In case you want to customize corner radius of the control.

```objective-c
@property (nonatomic, strong) IBInspectable UIColor *textColor;
```
Change that if you want to customize text color for titles of unselected segments.

```objective-c
@property (nonatomic, strong) IBInspectable UIColor *selectedStateTextColor;
```
It is used to change the text color of the title for the selected segment.

```objective-c
@property (nonatomic, strong) IBInspectable UIColor *selectorViewColor;
```
That’s how you change the color of selection itself.
 
In addition, you can set a color (or a number of colors to get a gradient) for each segment, left and right bounces with the help of the following data source methods:
 
```objective-c
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index;
- (NSArray <UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForBounce:(LUNSegmentedControlBounce)bounce;
```

If you want to recieve notifications about position changes, set control's delegate. 

Check out the documentation to find description for more methods and properties you may use.

License
-------

Usage is provided under the [MIT License](http://opensource.org/licenses/MIT)
