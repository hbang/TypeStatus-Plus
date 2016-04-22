#import "HBTSPlusMusicProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <MediaRemote/MediaRemote.h>

@implementation HBTSPlusMusicProvider {
	NSString *_lastSongIdentifier;
}

- (instancetype)init {
	if (self = [super init]) {
		self.name = @"Music";
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typeStatusPlusMusic_mediaInfoDidChange:) name:(NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	}
	return self;
}

- (void)typeStatusPlusMusic_mediaInfoDidChange:(NSNotification *)notification {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
		NSDictionary *dictionary = (__bridge NSDictionary *)result;
		NSString *songName = dictionary[(NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		NSString *artistName = dictionary[(NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		NSString *albumName = dictionary[(NSString *)kMRMediaRemoteNowPlayingInfoAlbum];

		if (!songName) {
			return;
		}

		NSString *identifier = [NSString stringWithFormat:@"title = %@, artist = %@, album = %@", songName, artistName, albumName];

		if (![_lastSongIdentifier isEqualToString:identifier]) {
			[_lastSongIdentifier release];
			_lastSongIdentifier = [identifier retain];

			HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
			notification.content = artistName ? [NSString stringWithFormat:@"%@ – %@", songName, artistName] : songName;
			notification.boldRange = NSMakeRange(0, songName.length);
			notification.statusBarIconName = @"TypeStatusPlusMusic";
			[self showNotification:notification];
		}
	});
}

@end
