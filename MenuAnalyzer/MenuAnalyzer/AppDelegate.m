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

#import "MenuAnalyzerViewController.h"

static NSString * const kApplicationName = @"MenuAnalyzer";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) MASShortcut *globalShortcut;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Initialize and register the global shortcut, Command-F1.
    _globalShortcut = [MASShortcut shortcutWithKeyCode:kVK_F1 modifierFlags: NSEventModifierFlagCommand];
    [[MASShortcutMonitor sharedMonitor] registerShortcut: _globalShortcut withAction:^{
        [self analyzeMenuStructure];
    }];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = kApplicationName;
    _statusItem.highlightMode = YES;
    _statusItem.action = @selector(togglePopover:);
    
    _popover = [[NSPopover alloc] init];
    _popover.contentViewController = [[MenuAnalyzerViewController alloc] init];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Unregister the global shortcut
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:_globalShortcut];

}

- (void)analyzeMenuStructure {
    NSLog(@"Analyzing menu structure...");
    [self showPopover:nil];
}

- (void)showPopover:(id) sender {
    NSStatusBarButton *button  = _statusItem.button;
    if (button) {
        [_popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSMinYEdge];
    }
}

- (void)closePopover:(id) sender {
    [_popover performClose:sender];
}

- (void)togglePopover:(id) sender {
    if ([_popover isShown]) {
        [self closePopover:sender];
    } else {
        [self showPopover:sender];
    }
}


@end
