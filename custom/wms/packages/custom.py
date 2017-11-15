# -*- Mode: Python -*- vi:si:et:sw=4:sts=4:ts=4:syntax=python

from cerbero.packages import package
from cerbero.enums import License

class WMS:

    url = ""
    version = '0.1.90'
    vendor = 'WMS Project'
    licenses = [License.LGPL]
    org = ''
    requires={
        'gstreamer-1.0':{
            'version':'1.12.2-3'
        },
		'ribbon':{
            'version':'0.3.5'
        }
    }
