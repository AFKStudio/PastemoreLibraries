#!/usr/bin/php

<?php

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