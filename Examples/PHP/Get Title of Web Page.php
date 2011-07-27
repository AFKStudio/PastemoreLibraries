#!/usr/bin/php

<?php

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

require "PMActionHelper.php";

$helper = new PMActionHelper;

// Animate Pastemore's menu icon

$helper->makeIconAnimate(true);

// Get the selected pasteboard item and the value of the URL

$selectedIndex = $helper->indexOfSelectedPasteboardItem();
$UTI = $helper->UTIForSpecializedType($selectedIndex, "URL");
$url = $helper->stringValueOfDataElementForUTI($selectedIndex, $UTI);

// Load the HTML document and retrieve the title

$dom = new DOMDocument();
$dom->loadHTMLFile($url);

$xml = simplexml_import_dom($dom);

$titles = $xml->xpath("//title");
$title = trim($titles[0]);

// If no title was retrieved, produce a message to that effect

if (!strlen($title)) {
	$helper->showAlert("Unable to find title", "Pastemore was unable to find the title of the Web document you requested.");
	$helper->makeIconAnimate(false);
	exit(0);
}

// Create a new pasteboard item and load the title into it
// Note that you must call PMActionHelper::commitWriteOperations
// in order for the new pasteboard item to be successfully created

$helper->createNewPasteboardItem();
$helper->loadTextIntoPasteboardItem(1, $title);
$helper->commitWriteOperations();

// Select the new item and post it to the system pasteboard

$helper->setIndexOfSelectedPasteboardItem(1);
$helper->postSelectedPasteboardItemIntoSystemPasteboard();

// Stop animating Pastemore's icon

$helper->makeIconAnimate(false);

// Advise the user

$helper->showAlert("Title successfully retrieved", "The title of the Web document you requested was successfully retrieved and is now in your pasteboard.");