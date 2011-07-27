//
//  Resize_ImageAppDelegate.m
//  Resize Image
//
//  Created by Marco Tabini on 11-07-26.
//  Copyright 2011 AFK Studio Partnership. All rights reserved.
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

#import "Resize_ImageAppDelegate.h"
#import "PMActionHelper.h"


@implementation Resize_ImageAppDelegate

@synthesize window = _window;
@synthesize resizeValue = _resizeValue;


- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Retrieve current pasteboard item
    
    PMActionHelper *helper = [[PMActionHelper alloc] init];
    
    int selectedIndex = helper.indexOfSelectedPasteboardItem;
    NSString *UTI = [helper UTIForImageOfPasteboardItemAtIndex:selectedIndex];
    
    if (!UTI) {
        [helper showAlertWithTitle:NSLocalizedString(@"Unable to Open Image", Nil)
                           message:NSLocalizedString(@"Pastemore was unable to open the image you selected. Please try again. (1)", Nil)];
    }
    
    imagePath = [helper pathOfSavedFileWithDataElementForUTI:UTI ofPasteboardItemAtIndex:selectedIndex];
    
    if (!imagePath) {
        [helper showAlertWithTitle:NSLocalizedString(@"Unable to Open Image", Nil)
                           message:NSLocalizedString(@"Pastemore was unable to open the image you selected. Please try again. (2)", Nil)];
    }
    
    self.resizeValue = 100.0;
}


- (void) applicationWillTerminate:(NSNotification *)notification {
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:Nil];
}


- (IBAction)okPressed:(id)sender {
    NSImage *oldImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    if (!oldImage) {
        NSAlert *alertSheet = [NSAlert alertWithMessageText:NSLocalizedString(@"Unable to Open Image", Nil)
                                              defaultButton:@"Quit"
                                            alternateButton:Nil
                                                otherButton:Nil
                                  informativeTextWithFormat:@"Pastemore was unable to open the image you selected. Please try again. (3)"];
        
        [alertSheet beginSheetModalForWindow:self.window
                               modalDelegate:NSApp
                              didEndSelector:@selector(terminate:)
                                 contextInfo:Nil];
        
        return;
    }
    
    NSSize oldSize = oldImage.size;
    NSSize newSize = NSMakeSize(oldSize.width * (self.resizeValue / 100), oldSize.height * (self.resizeValue / 100));
    
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    
    if (!newImage) {
        NSAlert *alertSheet = [NSAlert alertWithMessageText:NSLocalizedString(@"Unable to Create Image", Nil)
                                              defaultButton:@"Quit"
                                            alternateButton:Nil
                                                otherButton:Nil
                                  informativeTextWithFormat:@"Pastemore was unable to create a new image. Please try again. (4)"];
        
        [alertSheet beginSheetModalForWindow:self.window
                               modalDelegate:NSApp
                              didEndSelector:@selector(terminate:)
                                 contextInfo:Nil];
        
        return;
    }
    
    [newImage lockFocus];
    
    [oldImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                fromRect:NSMakeRect(0, 0, oldSize.width, oldSize.height)
               operation:NSCompositeSourceOver
                fraction:1.0];
    
    [newImage unlockFocus];
    
    PMActionHelper *helper = [[PMActionHelper alloc] init];
    
    [helper createNewPasteboardItem];
    [helper loadData:[newImage TIFFRepresentation] intoPasteboardItemAtIndex:1 usingUTI:@"public.tiff"];
    [helper commitWriteOperations];
    
    helper.indexOfSelectedPasteboardItem = 1;
    [helper postSelectedPasteboardItemToSystemPasteboard];
    
    [helper showAlertWithTitle:NSLocalizedString(@"Image Resized Successfully", Nil)
                       message:NSLocalizedString(@"Pastemore has placed a copy of the resized image in the pasteboard.", Nil)];
    
    [NSApp terminate:self];
}

@end
