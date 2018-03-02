#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBDataProviderIdentity.h>
#import <BulletinBoard/BBSectionIcon.h>
#import <BulletinBoard/BBSectionIconVariant.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <TypeStatusProvider/TypeStatusProvider.h>
#import <version.h>

static NSString *const kHBTSPlusAppIdentifier = @"ws.hbang.typestatusplus.app";

@implementation HBTSPlusBulletinProvider {
	HBTSPlusPreferences *_preferences;
	NSMutableSet <BBBulletinRequest *> *_sentBulletins;
}

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [%c(HBTSPlusPreferences) sharedInstance];
		_sentBulletins = [NSMutableSet setWithCapacity:1];

		// construct our data provider identity
		BBDataProviderIdentity *identity = [BBDataProviderIdentity identityForDataProvider:self];

		// give it our identifier and name
		identity.sectionIdentifier = kHBTSPlusAppIdentifier;
		identity.sectionDisplayName = @"TypeStatus";

		// set ourself as only displaying alerts, not sounds or badges
		identity.defaultSectionInfo.pushSettings = BBSectionInfoPushSettingsAlerts;
		
		self.identity = identity;

		// listen for the set status bar notification
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedSetStatusBarNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

- (void)_receivedSetStatusBarNotification:(NSNotification *)nsNotification {
	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:nsNotification.userInfo];

	// if there’s no title or content, stop right here
	if (!notification.content || [notification.content isEqualToString:@""]) {
		return;
	}

	// if we’re in the right state to show a bulletin, do it
	if ([HBTSPlusStateHelper shouldShowBanner]) {
		[self showBulletinForNotification:notification];
	}
}

- (void)showBulletinForNotification:(HBTSNotification *)notification {
	// construct our bulletin
	BBBulletinRequest *bulletin = [[BBBulletinRequest alloc] init];

	// set the basic stuff
	bulletin.sectionID = kHBTSPlusAppIdentifier;
	bulletin.bulletinID = [NSUUID UUID].UUIDString;
	bulletin.recordID = bulletin.bulletinID;
	bulletin.publisherBulletinID = [NSString stringWithFormat:@"%@-%@", notification.sourceBundleID, [NSUUID UUID].UUIDString];

	// set the title to the app display name
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:notification.sourceBundleID];
	bulletin.title = app.displayName;

	// if we’re using the app icon
	if (_preferences.useAppIcon) {
		// get the icon
		SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
		UIImage *icon = [appIcon getUnmaskedIconImage:MIIconVariantSmall];

		// override the icon with what we have
		if ([bulletin respondsToSelector:@selector(setIcon:)]) {
			BBSectionIcon *sectionIcon = [[BBSectionIcon alloc] init];
			[sectionIcon addVariant:[BBSectionIconVariant variantWithFormat:0 imageData:UIImagePNGRepresentation(icon)]];
			bulletin.icon = sectionIcon;
		} else {
			// TODO: didn't i have something working for ios 9 at some point?
			// [bulletin.sectionIcon addVariant:[BBSectionIconVariant variantWithFormat:0 imageData:UIImagePNGRepresentation(icon)]];
			// _currentIcon = icon;
		}
	}

	// set all the rest
	bulletin.message = notification.content;
	bulletin.date = notification.date;
	bulletin.lastInterruptDate = [NSDate date];

	if ([bulletin respondsToSelector:@selector(setTurnsOnDisplay:)]) {
		bulletin.turnsOnDisplay = _preferences.wakeWhenLocked;
	}

	// set a callback to open the conversation
	bulletin.defaultAction = [BBAction actionWithCallblock:^{
		// let the tap to open controller do its thing
		[[HBTSPlusTapToOpenController sharedInstance] receivedStatusBarTappedMessage:nil];
	}];

	// if we need to remove previous bulletins, do so now
	[self clearBulletinsIfNeeded];

	// send it!
	BBDataProviderAddBulletin(self, bulletin);
	[_sentBulletins addObject:bulletin];
}

- (void)clearBulletinsIfNeeded {
	// if the user wants to not keep previous bulletins
	if (_preferences.keepBulletinsMode == HBTSPlusKeepBulletinsModeOne) {
		// loop and remove all bulletins we’ve sent
		for (BBBulletinRequest *bulletin in _sentBulletins) {
			BBDataProviderWithdrawBulletinsWithRecordID(self, bulletin.recordID);
		}

		// empty the set
		[_sentBulletins removeAllObjects];
	}
}

- (void)clearBulletinsForBundleIdentifier:(NSString *)bundleIdentifier {
	// the user has launched an app. if they want its notifications to be removed
	if (_preferences.keepBulletinsMode == HBTSPlusKeepBulletinsModeAll) {
		// we’ll need to keep track of the bulletins we remove
		NSMutableSet *removedBulletins = [NSMutableSet set];
		NSString *prefix = [bundleIdentifier stringByAppendingString:@"-"];

		// loop and remove matching bulletins we’ve sent, adding them to the removed set
		for (BBBulletinRequest *bulletin in _sentBulletins) {
			if ([bulletin.publisherBulletinID hasPrefix:prefix]) {
				BBDataProviderWithdrawBulletinsWithRecordID(self, bulletin.recordID);
				[removedBulletins addObject:bulletin];
			}
		}

		// remove the removed bulletins from the set
		[_sentBulletins minusSet:removedBulletins];
	}
}

#pragma mark - BBDataProvider

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

- (void)noteSectionInfoDidChange:(BBSectionInfo *)sectionInfo {
	[super noteSectionInfoDidChange:sectionInfo];

	BOOL notificationsEnabled = sectionInfo.allowsNotifications;

	_showsWhenUnlocked = notificationsEnabled && sectionInfo.alertType != BBSectionInfoAlertTypeNone;
	_showsInLockScreen = notificationsEnabled && sectionInfo.showsInLockScreen;
}

@end
