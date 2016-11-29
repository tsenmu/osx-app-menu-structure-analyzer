//
//  KeyCodeUtilities.m
//  MenuAnalyzer
//
//  Created by Jingjie Zheng on 2016-11-29.
//  Copyright © 2016 Jingjie Zheng. All rights reserved.
//

#import "KeyCodeUtilities.h"



@implementation KeyCodeUtilities


+ (NSString *) convertGlyphCodeToString:(long) glyphCode {
    NSDictionary *dictionary = @{
       @2 : @"⇥",
       @3 : @"⇤",
       @4 : @"⌤",
       @5 : @"⇧",
       @6 : @"⌃",
       @7 : @"⌥",
       @9 : @"␣",
       @10 : @"⌦",
       @11 : @"↩",
       @12 : @"↪",
       @15 : @"",
       @16 : @"↓",
       @17 : @"⌘",
       @18 : @"✓",
       @19 : @"◇",
       @20 : @"",
       @23 : @"⌫",
       @24 : @"←",
       @25 : @"↑",
       @26 : @"→",
       @27 : @"⎋",
       @28 : @"⌧",
       @29 : @"『",
       @30 : @"』",
       @97 : @"␢",
       @98 : @"⇞",
       @99 : @"⇪",
       @100 : @"←",
       @101 : @"→",
       @102 : @"↖",
       @103 : @"﹖",
       @104 : @"↑",
       @105 : @"↘",
       @106 : @"↓",
       @107 : @"⇟",
       @109 : @"",
       @110 : @"⌽",
       @111 : @"F1",
       @112 : @"F2",
       @113 : @"F3",
       @114 : @"F4",
       @115 : @"F5",
       @116 : @"F6",
       @117 : @"F7",
       @118 : @"F8",
       @119 : @"F9",
       @120 : @"F10",
       @121 : @"F11",
       @122 : @"F12",
       @135 : @"F13",
       @136 : @"F14",
       @137 : @"F15",
       @138 : @"⎈",
       @140 : @"⏏",
       @141 : @"英数",
       @142 : @"かな",
       @143 : @"F16",
       @144 : @"F17",
       @145 : @"F18",
       @146 : @"F19",
       @148 : @"fn fn"
    };
    
    NSString* glyphStr = [dictionary objectForKey:[NSNumber numberWithInteger:glyphCode]];
    if (glyphStr == nil) {
        NSLog(@"Glyph code %ld is not found in the dictionary, correct the table.", glyphCode);
    }
    return glyphStr;
}
@end
