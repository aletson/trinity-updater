# trinity-updater
***Before you use this:*** Have you considered [trinity-ci-utils-public](https://github.com/aletson/trinity-ci-utils-public) for your host case? That includes systemd support as well as some neat continuous integration tricks, and is likely a much better fit for your needs. 

A shell script for updating to a new revision of [TrinityCore](http://github.com/trinitycore/trinitycore), including support for external alerts.

## Requirements
* You must have the `screen` utility installed. This makes it easier to run the TrinityCore server processes in the background without interfering with everyday system use. If you run TrinityCore via systemd, please consider trinity-ci-utils-public and rolling your own server maintenance alerts through the TrinityCore RA functionality.
* The script expects `cmake`, `boost`, `gcc`, etc. to already be installed on your server. This is only a maintenance script, not a script for initial server setup.
* This script is meant for use with Fedora 23. Your mileage may vary if you test it on a different operating system, although I would imagine any Fedora based system would work.
* You must have automatic DB updates enabled in TrinityCore.

## Recommendations
* If you have mail enabled on the server, you can use the script to send you maintenance alerts. I find `postfix` to be the easiest way to configure mail.
* If you have an IFTTT account, you can use the script to trigger IFTTT Maker commands through web hook.
