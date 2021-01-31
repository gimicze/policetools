# Police Tools

[![License GNU-GPL v3](https://img.shields.io/github/license/gimicze/policetools?style=for-the-badge)](https://github.com/gimicze/policetools/blob/master/LICENSE "License")
[![Latest release](https://img.shields.io/github/v/release/gimicze/policetools?style=for-the-badge)](https://github.com/gimicze/policetools/releases/latest "Latest release")
[![Total downloads](https://img.shields.io/github/downloads/gimicze/policetools/total?style=for-the-badge)](https://github.com/gimicze/policetools/releases/latest "Total downloads")

A FiveM resource containing some tools / essentials for the police.

# Instalation

1. Extract the contents into folder called `policetools` into your resources folder.
2. Start the script: **a)** in the `server.cfg` file; **b)** through the console

## Starting a resource through console

1. In a server console, or client console (F8), type in `refresh` and confirm using ENTER
2. Type in `start policetools` and confirm using ENTER

## Starting a resource in `server.cfg`
1. Add this line to your server.cfg
```
start policetools
```
2. Save the file and restart the server.

## Usage & Commands

`/callsign <callsign>` - *Sets the callsign to the specified one, will change your blip's appearance on the map. (e.g. L-11 -> blue dot with 11 in it)*
- `<callsign>`: **string** - *your callsign, formatted: e.g. L-21, C-3*

`/policeblip <action> <playerID>` *Adds or removes the specified player to the WL*
- `<action>`: **add / remove / hide / show / on / off** - *specifies the action (on and off turns the blips globally on/off)*
- `<playerID>`: **int** - *the player ID (leave empty if you want to apply the action on yourself)*

`/tint` - *Checks the nearest vehicle's window tint.*

## Compatibility
OneSync **is required** to make this script work as it obtains player coordinates server-side.

## Known bugs
None :-) Feel free to submit an issue on GitHub if you find any.

# Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

# License
[GNU GPL 3.0](https://github.com/gimicze/doorcontrol/blob/main/LICENSE)
