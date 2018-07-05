# MongoPi

Installing/Upgrading MongoDB on a Raspberry Pi (ARM based processor).

## Overview
Currently, there is no publicly available MongoDB 3.0+ distribution for the Raspberry Pi.

I found instructions on how to install MongoDB 3.0.9 from Andy's [MongoDB 3.0.9 binaries for Raspberry Pi 2 & 3 (Jessie)](https://andyfelong.com/2016/01/mongodb-3-0-9-binaries-for-raspberry-pi-2-jessie/) blog.

While his blog tells you how to completely install MongoDB, I prefer a one line approach to install programs, so it can be more automated.

I have developed a script that will pull his files and automatically do the install on Raspbian Stretch and Jessie.

## Execution
The only command that you will have to execute is this:

```
curl -sL https://raw.githubusercontent.com/lashower/MongoPi/master/install.sh | bash -
```

## Testing

This script has been tested on a Raspberry Pi 3 running Raspbian Stretch.
