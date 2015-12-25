#import <TypeStatusPlusProvider/HBTSPlusProvider.h>

@interface SKPParticipant : NSObject

@end

@interface SKPArrayFilter : NSObject

- (void)startObserving;

@end

@interface SKPConversation : NSObject

@property (retain, nonatomic) SKPArrayFilter *typingParticipantsFilter;

@end

%hook SKPConversation

- (id)initWithAleObject:(id)object {
	if ((self = %orig)) {
		[self.typingParticipantsFilter startObserving];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"objects"] && [object isKindOfClass:%c(SKPArrayFilter)] && change) {
		NSArray *participants = change[@"new"];
		for (SKPParticipant *participant in participants) {
			HBLogDebug(@"participant is %@", participant);
		}
	}
	%orig;
}

%end

