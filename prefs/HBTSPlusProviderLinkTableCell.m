#import "HBTSPlusProviderLinkTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusProviderLinkTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		BOOL isBackgrounded = ((NSNumber *)specifier.properties[HBTSPlusProviderCellIsBackgroundedKey]).boolValue;
		self.detailTextLabel.text = isBackgrounded ? @"*" : @"";
	}

	return self;
}

@end
