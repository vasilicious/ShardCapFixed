# ShardCapFixed for Turtle WoW.

Super lightweight and invisible addon.

Automagically deletes Soul Shards above the cap - when you exit combat (default 12). 

This addon deletes backwards, so that your shards always fill your soulbag first.

## Install
- Unzip. 
- Enter "ShardCapFixed-main"-folder
- Move the "ShardCapFixed" folder into the addons folder. 

## Slash commands
- Show cap: /scf    

- Change cap: /scf NUMBER

- Example: /scf 5
  
### More information: 

- /scf info

## Recent changes:

- Added support for Turtle WoW server where shards stack up to 3 per bag slot
- Changed default to 12 (up from 5)

## Fork Information
This is a fork of the original ShardCap addon, modified to work with servers where Soul Shards stack (up to 3 per bag slot on Turtle WoW).

The original fork was deleting the whole stack (e.g if cap is 6, 3 per slot, it would delete the entire stack with 3, making the total count 4). I changed the deletion logic so that the total count is still 6.