//
//  PMActionHelper.h
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

#import <Foundation/Foundation.h>

@interface PMActionHelper : NSObject {
    NSMutableArray *_writeOperations;
}


// Convenience method to obtain a helper

+ (PMActionHelper *) actionHelper;

// Script execution

/* Note that you only need to pass the body of the script to these two methods. The
   methods will automagically add the “tell/end tell” part */

- (NSAppleEventDescriptor *) executeScript:(NSString *) script andReturnErrorsInDictionary: (NSDictionary *__autoreleasing *) error;

// Helper that executes a script a pops up an alert view if it fails
- (NSAppleEventDescriptor *) executeScriptAndDisplayErrors:(NSString *) script, ...;

// Script execution helpers

- (NSString *) stringForScript:(NSString *) script, ...;
- (int) intForScript:(NSString *) script, ...;

// Basic functionality

- (void) makeIconAnimate:(BOOL) animate;

- (NSString *) extensionForUTI:(NSString *) UTI;

- (void) showAlertWithTitle:(NSString *) title message:(NSString *) message;

// Pasteboard window

- (void) allowPasteboardHistoryToHide:(BOOL) allow;

- (void) showPasteboardHistory;
- (void) hidePasteboardHistory;

// Pasteboard items

- (int) pasteboardItemCount;

@property (nonatomic) int indexOfSelectedPasteboardItem;

- (int) indexOfSelectedPasteboardItem;
- (void) setIndexOfSelectedPasteboardItem:(int) index;

// Cause Pastemore to paste the selected item to OS X's pasteboard.
// In a Cocoa app, this will automatically cause the app to hide
// (otherwise, it wouldn't be possible to perform a meaningful paste operation)

- (void) pasteSelectedPasteboardItem;

// Cause Pastemore to transfer the currently-selected pasteboard item
// to OS X's system pasteboard. Unless your action needs to paste directly,
// this is normally the last command you will issue before notifying the user
// and exiting.
- (void) postSelectedPasteboardItemToSystemPasteboard;

// UTI manipulation

// If the pasteboard item is linked to a file, these methods will return the
// latter's UTI and location

- (NSString *) UTIOfLinkedFileOfPasteboardItemAtIndex:(int) index;
- (NSString *) pathOfLinkedFileOfPasteboardItemAtIndex:(int) index;

// This method returns the UTI of a given data element of a given pasteboard item

- (NSString *) UTIOfDataElementAtIndex:(int) dataElementIndex ofPasteboardItemAtIndex:(int) pasteboardItemIndex;

// These convenience methods return the best-match UTI for a given data
// type, or Nil if no data element is available for that data type

- (NSString *) UTIForPlainTextOfPasteboardItemAtIndex:(int) index;
- (NSString *) UTIForRichTextOfPasteboardItemAtIndex:(int) index;
- (NSString *) UTIForHTMLOfPasteboardItemAtIndex:(int) index;
- (NSString *) UTIForURLOfPasteboardItemAtIndex:(int) index;
- (NSString *) UTIForImageOfPasteboardItemAtIndex:(int) index;
- (NSString *) UTIMatchingRegex:(NSString *) regex ofPasteboardItemAtIndex:(int) index;

// These methods allow you to access the data associated with a given data element—either by index or by its UTI

- (NSString *) stringValueOfDataElementAtIndex:(int) dataElementIndex ofPasteboardItemAtIndex:(int) pasteboardItemIndex;
- (NSString *) pathOfSavedFileWithDataElementAtIndex:(int) dataElementIndex ofPasteboardItemAtIndex:(int) pasteboardItemIndex;

- (NSString *) stringValueOfDataElementForUTI:(NSString *) UTI ofPasteboardItemAtIndex:(int) pasteboardItemIndex;
- (NSString *) pathOfSavedFileWithDataElementForUTI:(NSString *) UTI ofPasteboardItemAtIndex:(int) pasteboardItemIndex;

// Use these methods to write to the pasteboard. You must call -commitWriteOperations when you
// want to 

- (void) createNewPasteboardItem;

- (void) loadText:(NSString *) text intoPasteboardItemAtIndex:(int) index usingUTI:(NSString *) UTI;
- (void) loadFileAtPath:(NSString *) path intoPasteboardItemAtIndex:(int) index;
- (BOOL) loadData:(NSData *)data intoPasteboardItemAtIndex:(int)index usingUTI:(NSString *)UTI;

- (void) commitWriteOperations;

@end
