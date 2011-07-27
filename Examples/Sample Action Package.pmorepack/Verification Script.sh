#!/usr/bin/php

<?php

require "PMActionHelper.php";

$actions = json_decode(file_get_contents('php://stdin'));

function findAction($fileName) {
	global $actions;
	
	foreach ($actions->actions as $index => $action) {
		if ($action->fileName == $fileName) {
			return $index;
		}
	}
	
	return -1;
}

$actionIndex = findAction("Get Title of Web Page.sh");

if ($actionIndex != -1) {
	$helper = new PMActionHelper;
	
	$selectedIndex = $helper->indexOfSelectedPasteboardItem();
	$UTI = $helper->UTIForSpecializedType($selectedIndex, "URL");
	$url = $helper->stringValueOfDataElementForUTI($selectedIndex, $UTI);

	if (!preg_match('/apple.com/i', parse_url($url, PHP_URL_HOST))) {
		unset($actions->actions[$actionIndex]);
	}
}

$actions->actions = array_values($actions->actions);

echo json_encode($actions);