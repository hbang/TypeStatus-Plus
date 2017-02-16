#import "HBTSPlusTwitterCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>

@implementation HBTSPlusTwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier]) {
		BOOL isBig = [[super valueForKey:@"_isBig"] boolValue];

		// if it's not the "big" cell, we don't want the detail label
		// if it is the "big" cell, we'll make the text Developer or Designer
		if (!isBig) {
			self.detailTextLabel.text = @"";
		} else {
			// TODO: needs l10n
			NSString *role = specifier.properties[@"developer"] && ((NSNumber *)specifier.properties[@"developer"]).boolValue ? @"Developer" : @"Designer";
			self.detailTextLabel.text = role;
		}

		// use a different tint color for the twitter bird in the accessory view
		UIImageView *accessoryView = (UIImageView *)self.accessoryView;
		UIImage *newImage = [accessoryView.image _flatImageWithColor:[UIColor colorWithWhite:0.196 alpha:1.00]];
		accessoryView.image = newImage;
		
		// resize the avatar for what we want
		UIView *avatarView = [self valueForKey:@"_avatarView"];

		CGFloat size = isBig ? 40.f : 29.f;

		UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
		specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		avatarView.layer.cornerRadius = size / 2;

		// modify the text color
		self.titleLabel.textColor = [UIColor colorWithRed:0.894 green:0.898 blue:0.914 alpha:1.00];
		self.detailTextLabel.textColor = [UIColor colorWithRed:0.894 green:0.898 blue:0.914 alpha:1.00];
	}
	return self;
}

@end
