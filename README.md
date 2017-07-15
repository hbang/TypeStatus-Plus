# TypeStatus Plus
Wow, apparently it’s real and it exists? And this is the code?

[**typestatus.com/plus**](https://typestatus.com/plus)

See also: [TypeStatus Plus Providers](https://github.com/hbang/TypeStatus-Plus-Providers)

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](LICENSE.md).

----

## Why the hell is this open source?
Open sourcing definitely doesn’t mean we’re throwing in the towel and TypeStatus Plus is never getting updates again (or only getting bugfix updates so it works only well enough to keep making money). In fact, I feel like it’s a significant benefit that users can see that we’re working on it, and somewhat understand what we’ve been working on from commit messages, rather than just taking our word for it.

I’ve open sourced every tweak I’ve released, even if months or years following the official release. We previously open sourced our paid tweaks [FlagPaint](https://github.com/hbang/FlagPaint-2) and [Chrysalis](https://github.com/benrosen78/chrysalis). I think it’s important to the jailbreak community that we give back as much or more than we take.

Can people take this code and build TypeStatus Plus for free? Sure (if they can get it to build…). But we get that the type of person who’d do that would probably install it from a pirate repo anyway, and we’d rather they have the real deal than to risk their device to potentially sketchy pirate repos. If you have the money and want to support further development, [please consider buying it](https://typestatus.com/plus). Your money helps us keep the servers running and motivates us to continue doing what we do. Don’t think of just the product — think of the humans behind it.

This is licensed under a fairly permissive license, the [Apache license](LICENSE.md). It does permit third parties to use some or all of the code commercially, and we’re not going to prevent that as long as you comply with the license’s requirements. We trust you to use your best judgement on what’s right and wrong. We release code primarily to assist other developers in researching how to solve a similar problem, not to grab a big chunk and not feel like what they’re doing is wrong, and hope it’ll help you to ultimately come up with an original way to do so if possible.

## How it works
There are 3 core features:

* The TypeStatus Plus Providers framework, which enables “providers” to relay notifications to TypeStatus Plus in a modular way.
* The code that coordinates the providers’ notification requests, and handles running apps in the background where needed.
* And the other stuff, including Messages app conversation list typing indicators, and status bar unread count badge.

### Notification system
Providers’ notifications work roughly like so:

```
┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐
╎ The Internet™ ╎
└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘
        ┃
┌──────────────┐
│ Typing alert │
└──────────────┘
        ┃
╔══════════════╗     ╔════════════╗       ╔════════════════╗    ╔═══════════╗
║ Provider app ║  ┏━━║ TS Plus SB ║    ┏━━║ TS SpringBoard ║ ┏━━║ TS Client ║
╚══════════════╝  ┃  ╚════════════╝    ┃  ╚════════════════╝ ┃  ╚═══════════╝
        ┃         ┃         ┃          ┃         ┃           ┃        ┃
┌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┐ ┃  ┌───────────────┐ ┃  ┌───────────────┐  ┃  ┌───────────────┐
╎ Network logic ╎ ┃  │ Alert handler │ ┃  │ Alert handler │  ┃  │ Alert handler │
└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┘ ┃  └───────────────┘ ┃  └───────────────┘  ┃  └───────────────┘
        ┃         ┃         ┣━━━━━━━━━━┛         ┣━━━━━━━━━━━┛        ┃
╔═══════════════╗ ┃  ╔══════════════╗     ╔══════════════╗      ┌────────────┐
║ Provider hook ║ ┃  ║ Notification ║     ║ libstatusbar ║      │ Status bar │
╚═══════════════╝ ┃  ║    Center    ║     ╚══════════════╝      │  message   │
        ┃         ┃  ╚══════════════╝            ┃              └────────────┘
┌──────────────┐  ┃         ┃             ┌────────────┐
│   Plus API   │━━┛  ┌──────────────┐     │ Status bar │
└──────────────┘     │ Banner, etc. │     │    icon    │
                     └──────────────┘     └────────────┘
```

I never realised making box drawing character flowcharts could be so fun. And time consuming.

“TS” here is the free TypeStatus package, which provides the core status bar notification functionality. People kinda get confused by that (sorry). “SB” is SpringBoard, and “Client” is the client tweak that lives in all apps with a status bar. If this seems insane, it probably is! 😀 (And it’s pretty simplified as well.) But this is probably the most logical way to achieve what we want, and cleaner than what it was prior to TypeStatus Plus.

### Backgrounding
I’ll say I’m not very proud of this part, because it just hasn’t ever worked well. But here goes:

* We hook assertiond, where `BSAuditTokenTaskHasEntitlement(connection, @"com.apple.multitasking.unlimitedassertions")` usually returns false, and make it return true. This gives us the ability to make our own assertions below.
* In SpringBoard, we wait 10 seconds after launch to begin launching apps in a suspended state, spread out 2 seconds apart. We then create an assertion on the app’s process ID, so that it runs continuously (restarts in the background when closed from the app switcher), and won’t be suspended when in the background. (Writing this, I realised this means apps probably wouldn’t work on the initial SpringBoard launch after reboot, due to the keychain not being unlocked yet, but the latest few jailbreaks being semi-untethered sidestepped this.)
* In order to trick most apps into not disconnecting from their chat socket when the app goes into the background (due to the user switching away from it), we block UIKit from sending NSNotifications and calling the app delegate methods for `UIApplicationWillResignActive` and `UIApplicationDidEnterBackground`. We also ensure `-[UIApplication applicationState]` returns `UIApplicationStateActive`.

## Thinking in retrospect
Holy crap this was so much work just to get non-iMessage services to show TypeStatus notifications. I’ll say I’m not 100% sure why people are willing to accept a compromise of battery life and probably a bit of performance, but I suppose that’s what jailbreaking is — if we were all happy with the same thing, we wouldn’t need to jailbreak. I feel bad that this tweak is as complex as it is, even though on the surface it seems like it has rather few features. Running around after apps changing method names or rewriting code every other update is painful. WhatsApp and Messenger providers have broken a few times — constant refactoring seems par for course for Facebook. I suppose they kinda need it if they have >10k classes in a single app (really, wtf?). I dabbled in some Android development a few months ago and realised how much more flexible its backgrounding system is, which made me pretty disappointed to come back to TypeStatus Plus and have to fix more backgrounding bugs.

I’m happy with basically everything else about the tweak though, and with the amount of code that needed to be written for those remaining features. I could grab all code except the 3rd-party app support and put it in the free TypeStatus package, and be happy with it from a technical standpoint (not so much from a moral standpoint). There are minor chunks of code here and there that could be cleaned up to look nicer, but there’s nothing *actually* wrong with them.

TL;DR: iOS backgrounding being so limited sucks. App updates changing everything on us sucks. But hey, the tweak still usually mostly works!

## The future
I think most of the SpringBoard code we have could be moved into its own daemon. To be fair, even TypeStatus itself should do this, but I tried that during Plus’s development, and again a few months ago when working on TypeStatus 2.3, and it didn’t work too well. Having our own nice-and-private process means we reduce potential for conflicting tweaks, won’t rudely crash SpringBoard if our code breaks, and has the benefit of it being possible to write it in Swift.

Since we are forcing provider apps to pretty much assume they’re in active use 24/7, this does create more energy usage, thereby reducing battery life. An app could continue playing gifs (and yes it’s pronounced jiff, don’t @ me), download large files, or could just be really inefficiently written as a whole (it’s unfortunate there’s no easily accessible place to put a Battery Menu Of Shame on iOS). I can think of some reasonable ways to sidestep this by pausing the app when it hasn’t been used in some time, or when on a bad network, or when there’s no data service, etc, etc. But there’s not really any easy and not-extremely-specific way to address the issues themselves.

Those are a few of the most important things I can think of right now, short of just giving away a document full of potential feature ideas. Nothing I say about the future is ever guaranteed, and I do like changing my mind a lot.

## Thanks 💚
TypeStatus Plus is like “my baby”, but really, most of the work was done by Ben Rosen. He wrote most of the initial code, and I’ve been maintaining it solo since his life got busier. I feel obligated to note that we had various disagreements (unrelated to the code) throughout the project, and I feel bad for them all. But ultimately, we made it work, and otherwise were really good at solving things together.

Ethan Arbuckle helped us out with some of the backgrounding logic that saved our asses. What we had in early betas would constantly break in crazy ways, and we probably wouldn’t have been able to effectively fix it even if we spent months on it. Ethan gave us some of his insanely-well-researched code, coming after his awesome backgrounding-related projects such as Mirmir. I owe him my firstborn child and maybe a spare kidney or two.

Veerklempt and Timon Olsthoorn (tmnlsthrn) made the tweak look beautiful. Adam I (iAdam1n) and Timon handled gathering translations and other housekeeping things, and Adam constantly does an amazing job handling the support inbox.

You guys are great. Together we made TypeStatus Plus happen. Thanks for everything.

*—kirb, 2017-07-14*
