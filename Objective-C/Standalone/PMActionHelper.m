//
//  PMActionHelper.m
//  Pastemore
//
//  Created by Marco Tabini on 11-07-09.
//  Copyright 2011 AFK Studio Partnership - All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this 
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice, this 
// list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "PMActionHelper.h"

@implementation PMActionHelper


#pragma mark - Execute script


- (NSAppleEventDescriptor *) executeScript:(NSString *) script andReturnErrorsInDictionary: (NSDictionary *__autoreleasing *) error {
    NSString *source = [NSString stringWithFormat:@"tell application \"Pastemore\"\n%@\nend tell", script];
    
    NSAppleScript *applescript = [[NSAppleScript alloc] initWithSource:source];
 
    return [applescript executeAndReturnError:error];
}


- (NSAppleEventDescriptor *) executeScriptAndDisplayErrors:(NSString *) script, ... {
    NSDictionary *errorDictionary = Nil;
    
    va_list args;
    
    va_start(args, script);
    script = [[NSString alloc] initWithFormat:script arguments:args];
    va_end(args);
    
    NSLog(@"Script: %@", script);
    
    NSAppleEventDescriptor *result = [self executeScript:script andReturnErrorsInDictionary:&errorDictionary];
    
    if (errorDictionary) {
        NSRunCriticalAlertPanel(NSLocalizedString(@"Error", Nil), 
                                NSLocalizedString(@"Error while communicating with Pastemore: %@ (%@)", "First @ is error message, second @ is error number"), 
                                @"OK", 
                                Nil,
                                Nil,
                                [errorDictionary objectForKey:NSAppleScriptErrorBriefMessage],
                                [errorDictionary objectForKey:NSAppleScriptErrorNumber],
                                Nil);
    }
    
    return result;
}


- (NSString *) stringForScript:(NSString *) script, ... {
    va_list args;
    
    va_start(args, script);
    script = [[NSString alloc] initWithFormat:script arguments:args];
    va_end(args);

    return [[self executeScriptAndDisplayErrors:script] stringValue];
}


- (int) intForScript:(NSString *) script, ... {
    va_list args;
    
    va_start(args, script);
    script = [[NSString alloc] initWithFormat:script arguments:args];
    va_end(args);
    
    return [[self executeScriptAndDisplayErrors:script] int32Value];
}


#pragma mark - Icon


- (void) makeIconAnimate:(BOOL) animate {
    NSString *script;
    
    if (animate) {
        script = @"animate the menu icon";
    } else {
        script = @"stop animating the menu icon";
    }
    
    [self executeScriptAndDisplayErrors:script];
}


#pragma mark - Pasteboard window


- (void) allowPasteboardHistoryToHide:(BOOL) allow {
    NSString *script;
    
    if (allow) {
        script = @"allow the pasteboard history to hide";
    } else {
        script = @"prevent the pasteboard history from hiding";
    }
    
    [self executeScriptAndDisplayErrors:script];
}


- (void) showPasteboardHistory {
    [self executeScriptAndDisplayErrors:@"show the pasteboard history"];
}


- (void) hidePasteboardHistory {
    [self executeScriptAndDisplayErrors:@"hide the pasteboard history"];
}


#pragma mark - Basic functionality


- (NSString *) extensionForUTI:(NSString *)UTI {
    return [self stringForScript:@"extension for UTI \"%@\"", UTI];
}


- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self executeScriptAndDisplayErrors:@"show message title \"%@\" message \"%@\"",
     [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
     [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
}


#pragma mark - Pasteboard items


- (int) pasteboardItemCount {
    return [self intForScript:@"number of pasteboard items"]; 
}


- (int) indexOfSelectedPasteboardItem {
    return [self intForScript:@"selected pasteboard index"];
}


- (void) setIndexOfSelectedPasteboardItem:(int) index {
    [self executeScriptAndDisplayErrors:@"set selected pasteboard index to %d",
     index];
}


- (void) pasteSelectedPasteboardItem {
#ifdef NSAppKitVersionNumber10_6
    [NSApp hide:self];
#endif
    [self performSelector:@selector(executeScriptAndDisplayErrors:) withObject:@"paste the selected pasteboard item" afterDelay:0];
}


- (void) postSelectedPasteboardItemToSystemPasteboard {
    [self executeScriptAndDisplayErrors:@"post the selected pasteboard item to the system pasteboard"];
}


#pragma mark - UTI Manipulation


- (NSString *) UTIOfDataElementAtIndex:(int)dataElementIndex ofPasteboardItemAtIndex:(int)pasteboardItemIndex {
    return [self stringForScript:@"UTI %d of pasteboard item %d",
            dataElementIndex,
            pasteboardItemIndex];
}


- (NSString *) UTIOfLinkedFileOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"linked uti of pasteboard item %d", index];
}


- (NSString *) pathOfLinkedFileOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"linked filepath of pasteboard item %d", index];
}


- (NSString *) UTIForPlainTextOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for plaintext of pasteboard item %d", index];
}


- (NSString *) UTIForRichTextOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for richtext of pasteboard item %d", index];
}


- (NSString *) UTIForHTMLOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for HTML of pasteboard item %d", index];
}


- (NSString *) UTIForURLOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for URL of pasteboard item %d", index];
}


- (NSString *) UTIForImageOfPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for image of pasteboard item %d", index];
}


- (NSString *) UTIMatchingRegex:(NSString *) regex ofPasteboardItemAtIndex:(int) index {
    return [self stringForScript:@"UTI for pasteboard item %d root uti \"%@\"", index, regex];
}


#pragma mark - Reading from the pasteboard


- (NSString *) stringValueOfDataElementAtIndex:(int)dataElementIndex ofPasteboardItemAtIndex:(int)pasteboardItemIndex {
    return [self stringForScript:@"stringValue of data element %d of pasteboard item %d",
            dataElementIndex,
            pasteboardItemIndex];
}


- (NSString *) pathOfSavedFileWithDataElementAtIndex:(int)dataElementIndex ofPasteboardItemAtIndex:(int)pasteboardItemIndex {
    NSString *UTI = [self UTIOfDataElementAtIndex:dataElementIndex ofPasteboardItemAtIndex:pasteboardItemIndex];
    
    if (!UTI) {
        return Nil;
    }
    
    NSString *extension = [self extensionForUTI:UTI];
    
    if (!extension) {
        return Nil;
    }
    
    NSString *result;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    result = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *) uuidString] stringByAppendingString:extension];
    CFRelease(uuidString);
    
    [self executeScriptAndDisplayErrors:@"write data element %d of pasteboard item %d to path \"%@\"",
     dataElementIndex,
     pasteboardItemIndex,
     [result stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    
    return result;
}


- (NSString *) stringValueOfDataElementForUTI:(NSString *)UTI ofPasteboardItemAtIndex:(int)pasteboardItemIndex {
    return [self stringForScript:@"stringValue of (data element for pasteboard item %d UTI \"%@\")",
            pasteboardItemIndex,
            UTI];
}


- (NSString *) pathOfSavedFileWithDataElementForUTI:(NSString *)UTI ofPasteboardItemAtIndex:(int)pasteboardItemIndex {
    NSString *extension = [self extensionForUTI:UTI];
    
    if (!extension) {
        return Nil;
    }
    
    NSString *result;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    result = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *) uuidString] stringByAppendingString:extension];
    CFRelease(uuidString);
    
    [self executeScriptAndDisplayErrors:@"write (data element for pasteboard item %d UTI \"%@\") to path \"%@\"",
     pasteboardItemIndex,
     UTI,
     [result stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    
    return result;
}


#pragma mark - Writing to the pasteboard


- (void) createNewPasteboardItem {
    [_writeOperations addObject:@"make new pasteboard item"];
}


- (void) loadText:(NSString *)text intoPasteboardItemAtIndex:(int)index usingUTI:(NSString *)UTI {
    [_writeOperations addObject:[NSString stringWithFormat:@"load text into pasteboard item %d from string \"%@\" UTI \"%@\"",
     index,
     [text stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
     UTI]];
}


- (void) loadFileAtPath:(NSString *)path intoPasteboardItemAtIndex:(int)index {
    [_writeOperations addObject:[NSString stringWithFormat:@"load file into pasteboard item %d from path \"%@\"",
     index,
     [path stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
}


- (BOOL) loadData:(NSData *)data intoPasteboardItemAtIndex:(int)index usingUTI:(NSString *)UTI {
    NSString *destinationPath;
    NSString *extension;
    
    extension = [self extensionForUTI:UTI];
    
    if (!extension) {
        return FALSE;
    }
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    destinationPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *) uuidString] stringByAppendingString:extension];
    CFRelease(uuidString);
    
    if (![data writeToFile:destinationPath atomically:NO]) {
        return FALSE;
    }
    
    [self loadFileAtPath:destinationPath intoPasteboardItemAtIndex:index];
    
    return TRUE;
}


- (void) commitWriteOperations {
    [self executeScriptAndDisplayErrors:[_writeOperations componentsJoinedByString:@"\n"]];
    [_writeOperations removeAllObjects];
}


#pragma mark - Initialization and memory management


+ (PMActionHelper *) actionHelper {
    return [[PMActionHelper alloc] init];
}


- (id) init {
    self = [super init];
    
    if (self) {
        _writeOperations = [[NSMutableArray alloc] init];
    }
    
    return self;
}


@end
