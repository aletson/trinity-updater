# trinity-updater
A shell script for updating to a new revision of [TrinityCore](http://github.com/trinitycore/trinitycore), including support for external alerts.

## Requirements
* You must have the `screen` utility installed. This makes it easier to run the TrinityCore server processes in the background without interfering with everyday system use. I'd like to remove this but don't know if writing a systemd script for TrinityCore has been done. If it has, feel free to open a PR.
* The script expects `cmake`, `boost`, `gcc`, etc. to already be installed on your server. This is only a maintenance script, not a script for initial server setup.
* This script is meant for use with Fedora 23. Your mileage may vary if you test it on a different operating system, although I would imagine any Fedora based system would work.
* You must have automatic DB updates enabled in TrinityCore.

## Recommendations
* If you have mail enabled on the server, you can use the script to send you maintenance alerts. I find `postfix` to be the easiest way to configure mail.
* If you have an IFTTT account, you can use the script to trigger IFTTT Maker commands through web hook.
