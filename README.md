# SmartOS lx-brand VM Guest Tools

The VM Guest tools contains scripts and drivers that are used to create SmartOS lx-brand images.



## Linux

The linux directory contains the 'mdata-get' tool, as well as several other
scripts for formatting a secondary disk, setting up networking, and fetching
user-scripts.

## Building

To build the ISO, tar and zip files run:

```
make all
```