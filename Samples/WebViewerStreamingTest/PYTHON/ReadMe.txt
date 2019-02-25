# Copyright (c) 2001-2019 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.

ConvertAndStream.py is a Python Django script that will convert a source file to .xod, and stream it as the conversion is taking place. This example requires Python and Django to be installed.

1. Download Django from http://www.djangoproject.com and install it.

2. Download the WebViewer Redistributable (WebViewer.zip) from here: http://www.pdftron.com/webviewer/download.html

3. Extract the contents of WebViewer.zip to Samples/WebViewerStreaming/PYTHON (make sure you get the directory: Samples/WebViewerStreaming/PYTHON/WebViewer after extraction).

4. Copy Samples/TestFiles/newsletter.xod to Samples/WebViewerStreaming/PYTHON (this document is used in the sample by default).

5. Open a terminal (or command prompt in Windows) and navigate to Samples/WebViewerStreaming/PYTHON directory within the extracted PDFNetC archive.

6. Start the Django server on the pre-configured Django website (Samples/WebViewerStreaming/PYTHON):
        python manage.py runserver 0.0.0.0:8080 (may require sudo or UAC privileges)

7. Open your web browser then go to http://localhost:8080/WebViewer.html. Optionally, check the terminal output to see the results of sample.

NOTE: This sample website project have most of the Django middlewares disabled. This is due to some middlewares require the response body to be fully prepared before the it is sent to then
client (i.e. GzipMiddleware requires the full response body to be written before compressing it). This essentially breaks the streaming aspect of the sample project. For this sample project,
all middlewares are disabled except for CommonMiddleware (see settings.py).
