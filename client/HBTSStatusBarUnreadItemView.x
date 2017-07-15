#import "HBTSStatusBarUnreadItemView.h"
#import "HBTSPlusClient.h"
#import "HBTSPlusPreferences.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

static CGSize const kHBTSStatusBarUnreadItemViewSize = (CGSize){ 13.f, 13.f };

static inline CGFloat getBorderWidth() {
	CGFloat scale = [UIScreen mainScreen].scale;
	return (scale < 3 ? 1.f : 1.5f) / scale;
}

@interface HBTSStatusBarUnreadItemView ()

@property (nonatomic) BOOL _hb_isVisible;

@end

%subclass HBTSStatusBarUnreadItemView : UIStatusBarCustomItemView

%property (nonatomic, retain) BOOL _hb_isVisible;

- (_UILegibilityImageSet *)contentsImage {
	// if we’re not enabled, or foregroundStyle isn’t set yet, do nothing
	if (![HBTSPlusPreferences sharedInstance].enabled || !self.foregroundStyle || !self.foregroundStyle.tintColor) {
		return %orig;
	}

	// get the badge count
	NSInteger badgeCount = [HBTSPlusClient sharedInstance].badgeCount;

	// if it’s >99, use a static string because 3+ digits won’t fit
	NSString *badgeString = badgeCount > 99 ? @":)" : [NSString stringWithFormat:@"%li", (long)badgeCount];

	// set ourself as visible as long as our value isn’t 0
	self._hb_isVisible = badgeCount != 0;

	// if it’s zero, mark ourself as not visible. if it’s -1, we’re waiting to hear back from
	// springboard with our badge count. either way, we aren’t returning any image
	if (badgeCount < 1) {
		return nil;
	}

	// start up a graphics context
	UIGraphicsBeginImageContextWithOptions(self.intrinsicContentSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// determine our border width
	CGFloat physicalPixel = getBorderWidth();

	// use a hairline width, so it always uses one physical pixel
	CGContextSetLineWidth(context, physicalPixel);

	// set the colors
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextSetStrokeColorWithColor(context, self.foregroundStyle.tintColor.CGColor);

	// draw the circle
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, (CGRect){{ physicalPixel, physicalPixel }, kHBTSStatusBarUnreadItemViewSize});
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
	labelPoint.x = physicalPixel + ((kHBTSStatusBarUnreadItemViewSize.width - labelSize.width) / 2.f);
	labelPoint.y = (kHBTSStatusBarUnreadItemViewSize.height - labelSize.height) / 2.f;

	// sitting it in between physical pixels will look awful on non retina screens, so round it if
	// that’s the case
	if ([UIScreen mainScreen].scale < 2) {
		labelPoint.x = roundf(labelPoint.x);
		labelPoint.y = roundf(labelPoint.y);
	}

	// render the string into the context
	[badgeString drawAtPoint:labelPoint withAttributes:attributes];

	// get the UIImage
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// return it as an image set
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:nil];
}

- (CGSize)intrinsicContentSize {
	// if we’re not visible, return zero
	if (!self._hb_isVisible) {
		return CGSizeZero;
	}

	// determine our border width
	CGFloat physicalPixel = getBorderWidth();

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

%ctor {
	// load libstatusbar
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	// only %init this file if lsb is installed, or UIStatusBarCustomItemView won't exist and things
	// will crash
	if (%c(UIStatusBarCustomItemView)) {
		%init;

		// ensure our client class is ready to go first
		[HBTSPlusClient sharedInstance];

		// when the app finishes launching, ask kindly for the unread count
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:HBTSPlusGiveMeTheUnreadCountNotification object:nil];
		}];
	}
}
