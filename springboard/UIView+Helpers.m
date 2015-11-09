#import "UIView+Helpers.h"

@implementation UIView (Helpers)

- (UIImage *)grabImage {
	// http://stackoverflow.com/a/11867557
    UIGraphicsBeginImageContext([self bounds].size);
    [[self layer] renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end