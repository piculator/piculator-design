#!/bin/sh
cd /www/wwwroot/rpi.kxxt.tech
dpkg-scanpackages . /dev/null | gzip -9c >  Packages.gz