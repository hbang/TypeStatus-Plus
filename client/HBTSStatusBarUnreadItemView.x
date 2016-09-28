#import "HBTSStatusBarUnreadItemView.h"
#import "HBTSPlusClient.h"
#import "HBTSPlusPreferences.h"
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

static CGSize const kHBTSStatusBarUnreadItemViewSize = (CGSize){13.f, 13.f};

@interface HBTSStatusBarUnreadItemView ()

@property (nonatomic) BOOL _typeStatusPlus_isVisible;

@end

%subclass HBTSStatusBarUnreadItemView : UIStatusBarCustomItemView

%property (nonatomic, retain) BOOL _typeStatusPlus_isVisible;

- (_UILegibilityImageSet *)contentsImage {
	// if we’re not enabled, do nothing
	if (![HBTSPlusPreferences sharedInstance].enabled) {
		return %orig;
	}

	// get the badge count
	NSInteger badgeCount = [HBTSPlusClient sharedInstance].badgeCount;

	// if it’s >99, use a static string because 3+ digits won’t fit
	NSString *badgeString = badgeCount > 99 ? @":)" : [NSString stringWithFormat:@"%li", (long)badgeCount];

	// if it’s zero, mark ourself as not visible and do nothing
	if (badgeCount == 0) {
		self._typeStatusPlus_isVisible = NO;
		return %orig;
	}

	// mark ourself as visible
	self._typeStatusPlus_isVisible = YES;

	// start up a graphics context
	UIGraphicsBeginImageContextWithOptions(self.intrinsicContentSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// get the value of a physical pixel (eg, 0.5pt for 1 physical pixel @2x)
	CGFloat physicalPixel = 1.f / [UIScreen mainScreen].scale;

	// use a hairline width, so it always uses one physical pixel
	CGContextSetLineWidth(context, physicalPixel);

	// set the colors
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextSetStrokeColorWithColor(context, self.foregroundStyle.tintColor.CGColor);

	// draw the circle
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, (CGRect){{physicalPixel, physicalPixel}, kHBTSStatusBarUnreadItemViewSize});
	CGContextDrawPath(context, kCGPathFillStroke);

	// set up our attributes
	NSDictionary <NSString *, id> *attributes = @{
		NSFontAttributeName: [UIFont systemFontOfSize:9.f weight:UIFontWeightRegular],
		NSForegroundColorAttributeName: self.foregroundStyle.tintColor,
		NSKernAttributeName: @-0.5f
	};

	// determine where to place the label
	CGSize labelSize = [badgeString sizeWithAttributes:attributes];
	CGPoint labelPoint;
	labelPoint.x = physicalPixel + roundf((kHBTSStatusBarUnreadItemViewSize.width - labelSize.width) / 2.f);
	labelPoint.y = roundf((kHBTSStatusBarUnreadItemViewSize.height - labelSize.height) / 2.f);

	// render the string into the context
	[badgeString drawAtPoint:labelPoint withAttributes:attributes];

	// get the UIImage
	UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() autorelease];
	UIGraphicsEndImageContext();

	// return it as an image set
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:nil];
}

- (CGSize)intrinsicContentSize {
	// if we’re not visible, return zero
	if (!self._typeStatusPlus_isVisible) {
		return CGSizeZero;
	}

	// get the value of a physical pixel (eg, 0.5pt for 1 physical pixel @2x)
	CGFloat physicalPixel = 1.f / [UIScreen mainScreen].scale;

	// add a physical pixel of space to avoid cutting off the circle
	CGSize size = kHBTSStatusBarUnreadItemViewSize;
	size.width = ceilf(size.width + (physicalPixel * 2.f));
	size.height = ceilf(size.height + (physicalPixel * 2.f));
	return size;
}

- (void)updateContentsAndWidth {
	%orig;

	// ensure the content size is updated
	[self invalidateIntrinsicContentSize];
}

%end
