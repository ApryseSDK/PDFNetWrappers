#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2025 by Apryse Software Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

from django.http import HttpResponse
from django.views.decorators.http import condition

import os.path
import site
site.addsitedir("../../../PDFNetC/Lib")

# because this sample must be ran on a Django framework, Python 3 modules are not supported. See:
# https://docs.djangoproject.com/en/dev/faq/install/#can-i-use-django-with-python-3
from PDFNetPython2 import PDFNet, Convert, XODOutputOptions, FilterReader

# request handler as specified in the site's URLconf.
@condition(etag_func=None)
def convert_and_stream(request):

    # path where files are located. This relative to where Django root site is located.
    FILE_DIR = "../../TestFiles/";

    getParams = request.GET
    fileName = 'newsletter.pdf'
    if getParams.__contains__('file'):
        fileName = getParams['file']

    # check if file exists
    if not os.path.isfile(FILE_DIR + fileName):
        print 'File not found: "' + FILE_DIR + fileName + '"'
        return HttpResponse('<h1>404 Not Found</h1><br/>File &quot;' + fileName + '&quot; cannot be found.', status=404)

    print 'Converting and streaming file: "' + FILE_DIR + fileName + '"...'

    try:
        return HttpResponse(perform_convert_and_stream(FILE_DIR + fileName), status=200, content_type='application/vnd.ms-xpsdocument', mimetype='application/vnd.ms-xpsdocument')
    except:
        return HttpResponse('<h1>500 Internal Server Error</h1>', status=500)

def perform_convert_and_stream(filePath):
    PDFNet.Initialize()
    # set the conversion option to not create thumbnails on XOD files because
    # they will not be streamed back to the client.
    xodOptions = XODOutputOptions()
    xodOptions.SetOutputThumbnails(False)

    filter = Convert.ToXod(filePath, xodOptions)
    fReader = FilterReader(filter)

    BUFFER_SIZE = 64 * 1024
    totalBytes = 0
    
    print 'Start streaming...'
    buf = str(fReader.Read(BUFFER_SIZE))
    while len(buf) > 0:
        totalBytes = totalBytes + len(buf)
        yield buf
        print 'Sent total: ' + str(totalBytes) + ' bytes'
        buf = str(fReader.Read(BUFFER_SIZE))
    print 'Done.'
