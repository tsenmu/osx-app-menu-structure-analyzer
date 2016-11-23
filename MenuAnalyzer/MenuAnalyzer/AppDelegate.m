//
//  AppDelegate.m
//  MenuAnalyzer
//
//  Created by Jingjie Zheng on 2016-11-23.
//  Copyright © 2016 Jingjie Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong)MASShortcut *globalShortcut;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize and register the global shortcut, Command-F1.
    _globalShortcut = [MASShortcut shortcutWithKeyCode:kVK_F1 modifierFlags: NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] registerShortcut: _globalShortcut withAction:^{
        [self analyzeMenuStructure];
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Unregister the global shortcut
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:_globalShortcut];

}

- (void)analyzeMenuStructure {
    NSLog(@"Analyzing menu structure...");
}


@end
