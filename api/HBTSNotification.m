#import "HBTSNotification.h"

@implementation HBTSNotification

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		// set defaults for things that don’t have a nil default
		_boldRange = NSMakeRange(0, 0);
		_date = [NSDate date];
	}

	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];

	if (self) {
		// deserialise the easy stuff
		_sectionID = dictionary[kHBTSPlusAppIdentifierKey];
		_content = dictionary[kHBTSPlusMessageContentKey];
		_statusBarIconName = dictionary[kHBTSPlusMessageIconNameKey];
		_date = dictionary[kHBTSPlusDateKey];
		_actionURL = dictionary[kHBTSPlusActionURLKey] ? [[NSURL alloc] initWithString:dictionary[kHBTSPlusActionURLKey]] : nil;

		// deserialize the bold range to an NSRange
		NSArray <NSNumber *> *boldRangeArray = dictionary[kHBTSMessageBoldRangeKey];
		_boldRange = NSMakeRange(boldRangeArray[0].unsignedIntegerValue, boldRangeArray[1].unsignedIntegerValue);
	}

	return self;
}

#pragma mark - Serialization

- (NSString *)_contentWithBoldRange:(out NSRange *)boldRange {
	NSString *text = nil;

	// if we have a title
	if (_title) {
		// if we have a subtitle
		if (_subtitle) {
			// format as title + " " + subtitle
			text = [NSString stringWithFormat:@"%@ %@", _title, _subtitle];
		} else {
			// just copy the title
			text = [[_title copy] autorelease];
		}

		// set the bold range accordingly
		*boldRange = NSMakeRange(0, _title.length);
	} else {
		// otherwise just directly grab the content and bold range
		text = [[_content copy] autorelease];
		*boldRange = _boldRange;
	}

	// we should never end up with nothing to return. crash if so
	NSAssert(text, @"No notification content found");
	NSAssert(text.length > 0, @"No notification content found");

	return text;
}

- (NSDictionary *)dictionaryRepresentation {
	// grab the content and bold range
	NSRange boldRange = NSMakeRange(0, 0);
	NSString *content = [self _contentWithBoldRange:&boldRange];

	// return serialized dictionary
	return @{
		kHBTSPlusAppIdentifierKey: _sectionID,
		kHBTSPlusMessageContentKey: content,
		kHBTSMessageBoldRangeKey: @[ @(boldRange.location), @(boldRange.length) ],
		kHBTSPlusMessageIconNameKey: _statusBarIconName ?: @"",
		kHBTSPlusDateKey: _date,
		kHBTSPlusActionURLKey: _actionURL ? _actionURL.absoluteString : @""
	};
}

#pragma mark - Memory management

- (void)dealloc {
	[_sectionID release];
	[_title release];
	[_subtitle release];
	[_content release];
	[_date release];
	[_statusBarIconName release];
	[_actionURL release];

	[super dealloc];
}

@end
