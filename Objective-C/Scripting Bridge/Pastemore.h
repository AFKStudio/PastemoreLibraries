/*
 * Pastemore.h
 */

// Copyright © 2010–2011 AFK Studio Partnership. All Right Reserved.
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


#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>

@class PastemoreWindow, PastemoreApplication, PastemorePasteboardItem, PastemoreDataElement;

/*
 * Standard Suite
 */

// A window.
@interface PastemoreWindow : SBObject

- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?

@end


/*
 * Pastemore Scripting Suite
 */

// The Pastemore application.
@interface PastemoreApplication : SBApplication
	- (SBElementArray *) windows;
	- (SBElementArray *) pasteboardItems;

	@property (copy, readonly) NSString *name;  // The name of the application.
	@property (readonly) BOOL frontmost;  // Is this the active application?
	@property (copy, readonly) NSString *version;  // The version number of the application.
	@property NSInteger selectedPasteboardIndex;

	- (void) animateTheMenuIcon;
	- (void) stopAnimatingTheMenuIcon;
	- (void) showThePasteboardHistory;
	- (void) hideThePasteboardHistory;
	- (void) preventThePasteboardHistoryFromHiding;
	- (void) pasteTheSelectedPasteboardItem;
	- (void) postTheSelectedPasteboardItemToTheSystemPasteboard;
	- (void) allowThePasteboardHistoryToHide;
	- (void) showMessageTitle:(NSString *)title message:(NSString *)message;
	- (NSString *) extensionForUTI:(NSString *)x;  // Returns the default extension for a given UTI
@end

// A pasteboard item
@interface PastemorePasteboardItem : SBObject

- (SBElementArray *) UTIs;
- (SBElementArray *) dataElements;

@property (readonly) NSInteger size;  // The total size of the pasteboard item
@property (copy, readonly) NSString *linkedUTI;  // The UTI of the file referenced by the pasteboard item
@property (copy, readonly) NSString *linkedFilepath;  // The file linked to the pasteboard item

- (NSString *) UTIForPlaintext;  // Returns the best UTI for a plaintext representation of a pasteboard item
- (NSString *) UTIForRichtext;  // Returns the best UTI for a rich text representation of a pasteboard item
- (NSString *) UTIForHTML;  // Returns the best UTI for an HTML representation of a pasteboard item
- (NSString *) UTIForURL;  // Returns the best UTI for an URL representation of a pasteboard item
- (NSString *) UTIForImage;  // Returns the best UTI for an image representation of a pasteboard item
- (NSString *) UTIForRootUTI:(NSString *)rootUTI;  // Returns the best UTI for a given regular expression
- (PastemoreDataElement *) dataElementForUTI:(NSString *)UTI;  // Returns the data value associated with a given UTI
- (void) loadFileIntoFromPath:(NSString *)fromPath;  // Loads data into a pasteboard item
- (void) loadTextIntoFromString:(NSString *)fromString UTI:(NSString *)UTI;  // Loads text into a pasteboard item

@end

@interface PastemoreDataElement : SBObject

@property (readonly) NSInteger size;  // The total size of the pasteboard item
@property (copy, readonly) NSString *stringValue;  // The string value of the pasteboard item.

- (void) writeToPath:(NSString *)toPath;  // Write data element to file

@end

