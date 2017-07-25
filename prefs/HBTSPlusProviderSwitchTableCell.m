#import "HBTSPlusProviderSwitchTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusProviderSwitchTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		BOOL isBackgrounded = ((NSNumber *)specifier.properties[HBTSPlusProviderCellIsBackgroundedKey]).boolValue;
		self.detailTextLabel.text = isBackgrounded ? @"*" : @"";
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	// push the detail label back by a few pixels so it's not right up against the switch
	CGRect detailFrame = self.detailTextLabel.frame;
	detailFrame.origin.x -= 6.f;
	self.detailTextLabel.frame = detailFrame;
}

@end
