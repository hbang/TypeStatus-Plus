#import "HBTSPlusBulletinProvider.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBDataProviderIdentity.h>

@implementation HBTSPlusBulletinProvider

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinOfType:(HBTSStatusBarType)type contactName:(NSString *)contactName {
	BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatusplus.notification");
	if (!contactName) {
		return;
	}

	static BBBulletinRequest *bulletinRequest = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bulletinRequest = [[BBBulletinRequest alloc] init];
		bulletinRequest.bulletinID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.sectionID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.publisherBulletinID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.recordID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.showsUnreadIndicator = NO;
	});
/*
	switch (type) {
		case HBTSStatusBarTypeTyping: {
			NSString *typingString = [freeBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
			bulletinRequest.title = [typingString substringToIndex:typingString.length-(typingString.length>0)];
			break;
		}
		case HBTSStatusBarTypeRead: {
			NSString *readString = [freeBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
			bulletinRequest.title = [readString substringToIndex:readString.length-(readString.length>0)];
			break;
		}
		case HBTSStatusBarTypeTypingEnded:
			break;
	}
*/
	bulletinRequest.message = contactName;
	bulletinRequest.date = [NSDate date];
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.defaultAction = [BBAction actionWithLaunchBundleID:@"com.apple.MobileSMS" callblock:nil];

	BBDataProviderAddBulletin(self, bulletinRequest);

}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(NSUInteger)filter count:(NSUInteger)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	BBSectionInfo *sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
	sectionInfo.sectionID = self.sectionIdentifier;
	return sectionInfo;
}

- (NSString *)sectionIdentifier {
	return @"ws.hbang.typestatusplus.app";
}

- (NSString *)sectionDisplayName {
	return @"TypeStatus";
}

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

- (BOOL)canPerformMigration {
	return YES;
}

- (id)defaultSubsectionInfos {
	return nil;
}

@end
