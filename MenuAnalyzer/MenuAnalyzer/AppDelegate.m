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
#import "UIElementUtilities.h"

static NSString * const kApplicationName = @"MenuAnalyzer";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) MASShortcut *globalShortcut;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) MenuAnalyzerViewController *menuAnalyzerViewController;
@property (nonatomic, assign) AXUIElementRef systemWideElement;
@property (nonatomic, strong) NSMutableString *currentOutput;
@property (nonatomic, strong) NSMutableString *currentAppTitle;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _menuAnalyzerViewController = [[MenuAnalyzerViewController alloc] init];
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
    _popover.contentViewController = _menuAnalyzerViewController;
    _popover.behavior = NSPopoverBehaviorTransient;
    
    _systemWideElement = AXUIElementCreateSystemWide();

    _currentOutput = [[NSMutableString alloc] init];
    _currentAppTitle = [[NSMutableString alloc] init];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Unregister the global shortcut
    [[MASShortcutMonitor sharedMonitor] unregisterShortcut:_globalShortcut];

}

- (void)performTimerBasedUpdate {
    [self updateCurrentUIElement];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(performTimerBasedUpdate) userInfo:nil repeats:NO];
}

- (void)getMenuStructure:(AXUIElementRef)element level:(unsigned int)currentLevel {
    if (!element) {
        return;
    }
    NSString* elementTitle = [UIElementUtilities titleOfUIElement:element];
    NSString* elementRole = [UIElementUtilities roleOfUIElement:element];
    
//    NSLog(@"%@", [UIElementUtilities stringDescriptionOfUIElement:element]);
    if ([elementTitle isEqualToString:@"Apple"]) {
        return;
    }
    if ([elementRole isEqualToString:@"AXMenuItem"]) {
        if ([elementTitle isEqualToString:@""]) {
            return;
        }
        if ([elementTitle isEqualToString:@"Services"]) {
            return;
        }
        if (!elementTitle) {
            return;
        }
    }
    if ([elementRole isEqualToString:@"AXMenuBarItem"]) {
        if (!elementTitle) {
            return;
        }
    }
    if (CFGetTypeID(element) == CFArrayGetTypeID()) {
        NSArray *items = (__bridge NSArray *) element;
        for (int i = 0; i < [items count]; ++i) {
            AXUIElementRef item = (__bridge AXUIElementRef)([items objectAtIndex:i]);
            [self getMenuStructure:item level:currentLevel];

        }
    } else if (CFGetTypeID(element) == AXUIElementGetTypeID()) {
        NSMutableString* prependSpaces = [[NSMutableString alloc] init];
        for (int i = 0; i < currentLevel; ++i) {
            [prependSpaces appendString:@"\t"];
        }
        
        AXUIElementRef children = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:(__bridge NSString *)kAXChildrenAttribute ofUIElement:element];
        AXUIElementRef cmdCharElement = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:(__bridge NSString *)kAXMenuItemCmdCharAttribute ofUIElement:element];
        AXUIElementRef cmdGlyphElement = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:(__bridge NSString *)kAXMenuItemCmdGlyphAttribute ofUIElement:element];
        AXUIElementRef cmdVirtualKeyElement = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:(__bridge NSString *)kAXMenuItemCmdVirtualKeyAttribute ofUIElement:element];
        AXUIElementRef cmdModifiersElement = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:(__bridge NSString *)kAXMenuItemCmdModifiersAttribute ofUIElement:element];
        
        NSMutableString* keyboardShortcut = [[NSMutableString alloc] init];
        if (cmdCharElement != nil) {
            [keyboardShortcut appendFormat:@"[%@]", cmdCharElement];
        }
        
        if ([keyboardShortcut isEqualToString:@""] && cmdGlyphElement != nil) {
            [keyboardShortcut appendFormat:@"[%@]", cmdGlyphElement];
        }
        
        if ([keyboardShortcut isEqualToString:@""] && cmdVirtualKeyElement != nil) {
            [keyboardShortcut appendFormat:@"[%@]", cmdVirtualKeyElement];
        }
        
        if (![keyboardShortcut isEqualToString:@""] && cmdModifiersElement != nil) {
            unsigned int mask = (unsigned int)[[NSString stringWithFormat:@"%@", cmdModifiersElement] integerValue];
            
            if (!(mask & kAXMenuItemModifierNoCommand)) {
                [keyboardShortcut appendFormat:@"[Command"];
                if (mask & kAXMenuItemModifierShift) {
                    [keyboardShortcut appendFormat:@"+Shift"];
                }
                if (mask & kAXMenuItemModifierControl) {
                    [keyboardShortcut appendFormat:@"+Control"];
                }
                if (mask & kAXMenuItemModifierOption) {
                    [keyboardShortcut appendFormat:@"+Option"];
                }
                [keyboardShortcut appendFormat:@"]"];
            }
        }
        
        if (![elementRole isEqualToString:@"AXMenuBar"] &&
            ![elementRole isEqualToString:@"AXMenu"]) {
            [_currentOutput appendString:[NSString stringWithFormat:@"%@%@\t%@\n", prependSpaces, elementTitle, keyboardShortcut]];
            [self getMenuStructure:children level:currentLevel + 1];
        } else {
            [self getMenuStructure:children level:currentLevel];
        }
        
    }
}

- (void)updateCurrentUIElement {

    AXUIElementRef app = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:
                                                   (__bridge NSString *)kAXFocusedApplicationAttribute ofUIElement:_systemWideElement];
    if (!app) {
        NSLog(@"Focused application not found.");
        return;
    }
    
    NSString* appTitle = [UIElementUtilities titleOfUIElement:app];
    [_currentAppTitle setString:appTitle];
    
    AXUIElementRef menuBar = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityMenuBarAttribute
                             ofUIElement:app];
    if (!menuBar) {
        NSLog(@"Menu bar not found.");
        return;
    }
    
    [_currentOutput setString: [NSString stringWithFormat:@"Application: %@\n\n", appTitle]];
    [self getMenuStructure:menuBar level:0];
    
    [_menuAnalyzerViewController.textView setString:_currentOutput];
    [self generateOutput];
}

- (void)generateOutput {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* outputDirectory = [NSString stringWithFormat:@"%@/%@/", documentsDirectory, kApplicationName];
    [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString* outputPath = [NSString stringWithFormat:@"%@%@.txt", outputDirectory, _currentAppTitle];
    
    [[NSFileManager defaultManager] createFileAtPath:outputPath contents:nil attributes:nil];
    [_currentOutput writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)analyzeMenuStructure {
    [self showPopover:nil];
    [self updateCurrentUIElement];
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
