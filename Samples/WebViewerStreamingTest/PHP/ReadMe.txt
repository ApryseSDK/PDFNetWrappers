# Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.

ConvertAndStream.php is a PHP web server script that will convert a source file to .xod, and stream it as the conversion is taking place. This example requires PHP capable web server (preferably Apache HTTP Server).

1. Install your choice of web server and make sure that it can parse and execute PHP scripts.

2. Set up your web server to use PDFNetC (see PHP_README.txt in PDFNetC package).

3. Copy the following files to their respective directories:
    a. Copy WebViewer.html to the root folder of htdocs (root folder where web serve will look for files).
    b. Copy PDFNetPHP.php (found in Lib folder of PDFNetC package) and ConvertAndStream.php to the root folder of htdocs.
    c. Download the WebViewer Redistributable (WebViewer.zip) from here: http://www.pdftron.com/webviewer/download.html
    d. Extract the contents of WebViewer.zip to the root folder of htdocs (make sure you get the folder WebViewer/ inside htdocs root).

4. Modify ConvertAndStream.php so the paths to the files are absolute. Enable logging by setting the $LOG_ENABLED variable to true if desired.

5. Open your web browser and browse to: http://yourserver/WebViewer.html. Optionally, check the log file to see the results of sample.
