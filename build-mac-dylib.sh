#!/bin/sh
# quick hack for local mac dylib build and copy to a Unity sandbox project locally
# TODO: will make a nice multi-platform friendly CMakeFile or something soon :-D

/usr/bin/clang++ -Wall -std=c++17 -stdlib=libc++ -L/usr/local/Cellar/libusb/1.0.26/lib/ -lusb-1.0 -L ./ftd2xx -lftd2xx -g *.cpp -o libmeterfeeder.dylib -shared
#cp libmeterfeeder.dylib ftd2xx/libftd2xx.1.4.16.dylib ~/MMI/code/medbots/Assets/Plugins/Mac/x86_64/
