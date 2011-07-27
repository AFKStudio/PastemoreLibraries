<?php
    
    //
    //  PMActionHelper.php
    //  Pastemore
    //
    //  Created by Marco Tabini on 11-07-09.
    //  Copyright 2011 AFK Studio Partnership - All rights reserved.
    //
    
    class PMActionHelper {
        
        public $version = "1.0(148)";
        
		/**
		 * Set to true to enable logging of the AppleScript commands being sent to Pastemore
		 *
		 * @var bool
		 */
		public $log = false;
        
        /**
         * Holds the currently-queued write commands
         */
        protected $writeCommands = array();
        
		/**
		 * Logs a message if logging is enabled
		 *
		 * @param string $message The message to log 
		 * @return void
		 * @author Marco Tabini
		 */
		protected function log($message = "") {
			if ($this->log) {
				echo date("[H:i:s] - "), $log, "\n";
			}
		}
        
        /**
         * Escapes a string for use in an AppleScript command
         *
         * @param string $string The string to be escaped
         * @return string the escaped string
         * @author Marco Tabini
         */
        public function escapeString($string) {
            return str_replace('"', '\\"', $string);
        }
        
        /**
         * Composes a script by replacing printf-style placeholder with values
         * passsed after the template.
         *
         * @param string $template The template
         * @return string The formatted string
         * @author Marco Tabini
         */
        public function composeScript($template) {
            $args = func_get_args();
            array_shift($args);
            
            return vsprintf($template, $args);
        }
        
        /**
         * Executes a series of (previously formatted) Pastemore AppleScript commands
         *
         * @param string $script The script to be executed
         * @return string The output of the script
         * @author Marco Tabini
         **/
        public function stringForScript($script) {
            $source = <<<EOD
            
            tell application "Pastemore"
            $script
            end tell
            
EOD;
            
            $this->log("Script: " . $script);
            
            $result = trim(shell_exec("osascript -e " . escapeshellarg($source)));
            
			$this->log("Result: " . $result);
			$this->log();
            
			if ($result == "missing value") {
				return null;
			}
			
			return $result;
        }
        
        /**
         * Executes a (previously formatted) Pastemore script and returns the integer result value
         *
         * @param string $script The script to execute
         * @return int The result value, converted to integer
         * @author Marco Tabini
         */
        public function intForScript($script) {
            return (int) $this->stringForScript($script);
        }
        
        /**
         * Causes Pastemore's icon to start/stop animating
         *
         * @param bool $animate Whether to animate the icon
         * @return void
         * @author Marco Tabini
         */
        public function makeIconAnimate($animate) {
            if ($animate) {
                $script = "animate the menu icon";
            } else {
                $script = "stop animating the menu icon";
            }
            
            $this->stringForScript($script);
        }
        
        /**
         * Allow/disallow the pasteboard history from hiding. Useful when you want
         * to show the pasteboard history animations while an action is being executed
         *
         * The pasteboard history window will normally hide itself automatically as
         * your script is executed (thus allowing it to run in the background).
         *
         * @param bool $allow Whether to allow the pasteboard history to hide or not.
         * @return void
         * @author Marco Tabini
         */
        public function allowPasteboardHistoryToHide($allow) {
            if ($allow) {
                $script = "allow the pasteboard history to hide";
            } else {
                $script = "prevent the pasteboard history from hiding";
            }
            
            $this->stringForScript($script);
        }
        
        /**
         * Show the pasteboard history window
         *
         * @return void
         * @author Marco Tabini
         */
        public function showPasteboardHistory() {
            $this->stringForScript("show the pasteboard history");
        }
        
        /**
         * Hide the pasteboard history window
         *
         * @return void
         * @author Marco Tabini
         */
        public function hidePasteboardHistory() {
            $this->stringForScript("hide the pasteboard history");
        }
        
        /**
         * Returns the preferred extension for a given UTI
         *
         * @param string $UTI The UTI whose extension is to be returned
         * @return string The preferred extension, if any, or an empty string.
         * @author Marco Tabini
         */
        public function extensionForUTI($UTI) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'extension for UTI "%s"',
                                                               $UTI));
        }
        
        /**
         * Show a Pastemore-style alert window
         *
         * @param string $title The title of the window
         * @param string $message The message to be displayed
         * @return void
         * @author Marco Tabini
         */
        public function showAlert($title, $message) {
            $this->stringForScript(
                                   $this->composeScript(
                                                        'show message title "%s" message "%s"',
                                                        $this->escapeString($title),
                                                        $this->escapeString($message)));
        }
        
        /**
         * Return the number of items in the pasteboard history
         *
         * @return int
         * @author Marco Tabini
         */
        public function pasteboardItemCount() {
            return $this->intForScript("number of pasteboard items");
        }
        
        /**
         * Return the index of the currently-selected pasteboard item (or -1 if no
         * item is selected).
         *
         * @return int
         * @author Marco Tabini
         */
        public function indexOfSelectedPasteboardItem() {
            return $this->intForScript("selected pasteboard index");
        }
        
        /**
         * Select a given pasteboard item
         *
         * @param int $newIndex The pasteboard item to be selected (>0 && <pasteboardItemCount())
         * @return void
         * @author Marco Tabini
         */
        public function setIndexOfSelectedPasteboardItem($newIndex) {
            $this->stringForScript(
                                   $this->composeScript(
                                                        'set the selected pasteboard index to %d',
                                                        $newIndex));
        }
        
        /**
         * Causes the currently-selected pasteboard item to be pasted into the topmost
         * application.
         *
         * @return void
         * @author Marco Tabini
         */
        public function pasteSelectedPasteboardItem() {
            $this->stringForScript("paste the selected pasteboard item");
        }
        
		/**
		 * Posts the currently-selected pasteboard item into the system pasteboard
		 *
		 * @return void
		 * @author Marco Tabini
		 */
		public function postSelectedPasteboardItemIntoSystemPasteboard() {
			$this->stringForScript("post the selected pasteboard item to the system pasteboard");
		}
        
        /**
         * Returns the UTI of a given data element
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item whose data elements must be examined
         * @param int $dataElementIndex The index of the data element who UTI is to be returned
         * @return string the UTI of the data element
         * @author Marco Tabini
         */
        public function UTIOfDataElement($pasteboardItemIndex, $dataElementIndex) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'UTI %d of pasteboard item %d',
                                                               (int) $pasteboardItemIndex,
                                                               (int) $dataElementIndex));
        }
        
        /**
         * Returns the UTI of a pasteboard item's linked file (if any)
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @return string The UTI of the linked file, or an empty string
         * @author Marco Tabini
         */
        public function UTIOfLinkedFile($pasteboardItemIndex) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'linked uti of pasteboard item %d',
                                                               $pasteboardItemIndex));
        }
        
        /**
         * Returns the path of a pasteboard item's linked file (if any)
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @return string The path to the linked file, or an empty string
         * @author Marco Tabini
         */
        public function pathOfLinkedFile($pasteboardItemIndex) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'linked filepath of pasteboard item %d',
                                                               $pasteboardItemIndex));
        }
        
        /**
         * Returns the best-match UTI of a pasteboard item for a given data type, if available
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $specializedType The data type (one of "plaintext", "richtext", "HTML", "URL", or "image") 
         * @return string The best-match UTI, or an empty string
         * @throws Exception If $specializedType contains an invalid data type
         * @author Marco Tabini
         */
        public function UTIForSpecializedType($pasteboardItemIndex, $specializedType) {
            if (!in_array($specializedType, array("plaintext", "richtext", "HTML", "URL", "image"))) {
                throw new Exception("Invalid specialized type $specializedType.");
            }
            
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'UTI for %s of pasteboard item %d',
                                                               $specializedType,
                                                               $pasteboardItemIndex));
        }
        
        /**
         * Returns the UTI of a pasteboard item that best matches a given PCRE
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $regex The regular expression against which matches should be found (no delimiters are necessary, and no modifiers allowed)
         * @return string The best-match UTI, or an empty string
         * @author Marco Tabini
         */
        public function UTIMatchingRegex($pasteboardItemIndex, $regex) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'UTI for pasteboard item %d root uti "%s"',
                                                               $pasteboardItemIndex,
                                                               $regex));
        }
        
        /**
         * Returns the string value of a pasteboard item's data value
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param int $dataElementIndex The index of the data value
         * @return string The string value of the data value
         * @author Marco Tabini
         */
        public function stringValueOfDataElement($pasteboardItemIndex, $dataElementIndex) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'stringValue of data element %d of pasteboard item %d',
                                                               $dataElementIndex,
                                                               $pasteboardItemIndex));
        }
        
        /**
         * Saves a data element to a temporary file and returns the latter's path. The file
         * automatically receives the preferred extension for its UTI
         *
         * @param string $pasteboardItemIndex The index of the pasteboard item
         * @param string $dataElementIndex The index of the data element
         * @return string The path to the file, if any.
         * @author Marco Tabini
         */
        public function pathOfSavedFile($pasteboardItemIndex, $dataElementIndex) {
            $UTI = $this->UTIOfDataElementAtIndex($pasteboardItemIndex, $dataElementIndex);
            
            if (!$UTI) {
                return null;
            }
            
            $extension = $this->extensionForUTI($UTI);
            
            if (!$extension) {
                return null;
            }
            
            $result = tempnam(sys_get_temp_dir(), "PMPHPHelper");
            
            $this->stringForScript(
                                   $this->composeScript(
                                                        'write data element %d of pasteboard item %d to path %s',
                                                        $dataElementIndex,
                                                        $pasteboardItemIndex,
                                                        $this->escapeString($result)));
        }
        
        /**
         * Returns the string value for a given UTI of a pasteboard item
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $UTI The UTI
         * @return string The string value of the data element
         * @author Marco Tabini
         */
        public function stringValueOfDataElementForUTI($pasteboardItemIndex, $UTI) {
            return $this->stringForScript(
                                          $this->composeScript(
                                                               'stringValue of (data element for pasteboard item %d UTI "%s")',
                                                               $pasteboardItemIndex,
                                                               $UTI));
        }
        
        /**
         * Saves a data element to a temporary file and returns the latter's path. The file
         * automatically receives the preferred extension for its UTI
         *
         * @param string $pasteboardItemIndex The index of the pasteboard item
         * @param string $UTI The UTI
         * @return string The path to the file, if any.
         * @author Marco Tabini
         */
        public function pathOfSavedFileForUTI($pasteboardItemIndex, $UTI) {
            $extension = trim($this->extensionForUTI($UTI));
            
            if (!$extension) {
                return null;
            }
            
            $result = tempnam(sys_get_temp_dir(), "PMPHPHelper");
            
            unlink($result);
            
            $result .= $extension;
            
            $this->stringForScript(
                                   $this->composeScript(
                                                        'write (data element for pasteboard item %d UTI "%s") to path "%s"',
                                                        $pasteboardItemIndex,
                                                        $UTI,
                                                        $this->escapeString($result)));
            
            return $result;
        }
        
        /**
         * Create a new pasteboard item. The new item always receives index #0.
         *
         * Note that the command is not executed until the next time you call {@link PMActionHelper::commitWriteOperations()}
         *
         * @return void
         * @author Marco Tabini
         */
        public function createNewPasteboardItem() {
            $this->writeCommands[] = "make new pasteboard item";
        }
        
        /**
         * Load a string into a pasteboard item with the given UTI
         *
         * Note that the command is not executed until the next time you call {@link PMActionHelper::commitWriteOperations()}
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $text The text to load
         * @param string $UTI The UTI
         * @return void
         * @author Marco Tabini
         */
        public function loadTextIntoPasteboardItem($pasteboardItemIndex, $text, $UTI = 'public.utf8-plain-text') {
            $this->writeCommands[] = $this->composeScript(
                                                          'load text into pasteboard item %d from string "%s" UTI "%s"',
                                                          $pasteboardItemIndex,
                                                          $this->escapeString($text),
                                                          $UTI);
        }
        
        /**
         * Load the contents of a file into a pasteboard item. The UTI is determined based on the file's extension.
         *
         * Note that the command is not executed until the next time you call {@link PMActionHelper::commitWriteOperations()}
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $path The path to the file to load
         * @return void
         * @author Marco Tabini
         */
        public function loadFileIntoPasteboardItem($pasteboardItemIndex, $path) {
            $this->writeCommands[] = $this->composeScript(
                                                          'load file into pasteboard item %d from path "%s"',
                                                          $pasteboardItemIndex,
                                                          $this->escapeString($path));
        }
        
        /**
         * Load arbitrary data into a pasteboard item with the given UTI
         *
         * Note that the command is not executed until the next time you call {@link PMActionHelper::commitWriteOperations()}
         *
         * @param int $pasteboardItemIndex The index of the pasteboard item
         * @param string $data The data to be loaded 
         * @param string $UTI The UTI
         * @return void
         * @author Marco Tabini
         */
        public function loadDataIntoPasteboardItem($pasteboardItemIndex, $data, $UTI) {
            $extension = $this->extensionForUTI($UTI);
            
            if (!$extension) {
                return null;
            }
            
            $filePath = tempnam(sys_get_temp_dir(), "PMPHPHelper");
            
            unlink($filePath);
            
            $filePath .= $extension;
            
            file_put_contents($filePath, $data);
            
            $this->loadFileIntoPasteboardItem($pasteboardItemIndex, $path);
        }
        
        /**
         * Commit all outstanding write operations to Pastemore.
         *
         * @return void
         * @author Marco Tabini
         */
        public function commitWriteOperations() {
            $this->stringForScript(implode("\n", $this->writeCommands));
            $this->writeCommands = array();
        }
    }
    
