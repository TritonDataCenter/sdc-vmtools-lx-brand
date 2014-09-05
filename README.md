# SmartOS VM Guest Tools

The VM Guest tools contains scripts and drivers that are used to create
virtualized machine images in SmartOS.

## Windows

The windows directory contains signed VirtIO drivers, as well as some scripts
and binaries that are used to retrieve metadata from the metadata API. In
addition, sample sysprep files are provided that you can use to create your own
windows images. 

## Linux

The linux directory contains the 'mdata-get' tool, as well as several other
scripts for formatting a secondary disk, setting up networking, and fetching
user-scripts.

## Building

To build the ISO, tar and zip files run:

```
make all
```