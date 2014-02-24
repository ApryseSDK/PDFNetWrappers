<?php
//---------------------------------------------------------------------------------------
// Copyright (c) 2001-2014 by PDFTron Systems Inc. All Rights Reserved.
// Consult LICENSE.txt regarding license information.
//---------------------------------------------------------------------------------------
include("./PDFNetPHP.php");

// set to true to enable logging (in order to see debug messages)
$LOG_ENABLED = false;
$LOG_FP = NULL;
if ($LOG_ENABLED) {
    $LOG_FILE = "./streaming.log";
    $LOG_FP = fopen($LOG_FILE, "a");
}

// function to write a message to log file.
function debugLog($msg) {
    global $LOG_ENABLED, $LOG_FP;
    if (! $LOG_ENABLED)
        return;

    fwrite($LOG_FP, $msg."\n");
}

// path where files are located. Relative paths may not work. It is best to use absolute locations.
// [Modify] Change $FILE_DIR to the path that contains your source document.
$FILE_DIR = "../../TestFiles/";

$fileName = "newsletter.pdf"; //the default source file

// get the file query parameter
if (isset($_GET["file"])) {
    $fileName = $_GET["file"];
}

try {
    // check if file exists
    if (!file_exists($FILE_DIR.$fileName)) {
        debugLog("File not found: \"".$FILE_DIR.$fileName."\"");
        // send 404
        header("HTTP/1.1 404 Not Found");
        echo "<h1>404 Not Found</h1><br/>";
        echo "File \"".$fileName."\" cannot be found.";
        return;
    }

    debugLog("Converting and streaming file: \"".$FILE_DIR.$fileName."\"...");
    // set the correct content-type
    header("Content-Type: application/vnd.ms-xpsdocument");
    PDFNet::Initialize();

    // set the conversion option to not create thumbnails on XOD files because
    // they will not be streamed back to the client.
    $xodOptions = new XODOutputOptions();
    $xodOptions->SetOutputThumbnails(false);

    $filter = Convert::ToXod(realpath($FILE_DIR.$fileName), $xodOptions);
    $fReader = new FilterReader($filter);

    $bufferSize = 64 * 1024;
    $totalBytes = 0;

    debugLog("Start streaming...");
    do {
        $buffer = $fReader->Read($bufferSize);
        echo $buffer;
        flush(); // prevents buffering the response so the client can receive them as they are written to the stream.
        $totalBytes += strlen($buffer);
        debugLog("Sent total: ".$totalBytes." bytes");
    }
    while (strlen($buffer) > 0);
    debugLog("Done.");
}
catch (Exception $e) {
    debugLog($e->getMessage());
    debugLog($e->getTraceAsString());
    header("HTTP/1.1 500 Internal Server Error");
    echo "<h1>500 Internal Server Error</h1><br/>";
    echo "The server encountered an unexpected condition which prevented it from fulfilling the request.<br/><br/>";
    echo $e->getMessage()."<br/>";
    echo $e->getTraceAsString();
}

if ($LOG_ENABLED)
    fclose($LOG_FP);
?>
