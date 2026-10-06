# ShardCapFixed for classic WoW (1.12.1).

Super lightweight and invisible addon.

Automagically deletes Soul Shards above the cap - when you exit combat (default 12). 

This addon deletes backwards, so that your shards always fill your soulbag first.

## Install
- Unzip. 
- Enter "ShardCapFixed-main"-folder
- Move the "ShardCapFixed" folder into the addons folder. 

## Slash commands
- /scf			→ show soul shards count (current/max)
- /scf 5		→ set cap to 5
- /scf notif	→ toggle notifications
- /scf deletes	→ delete excess shards
- /scf help		→ help

## Recent changes:
- Added support for Turtle WoW server where shards stack up to 3 per bag slot
- Changed default to 12 (up from 5)
- Fixed deletion logic to allow for partial deletion.

## Fork Information
This is a fork of the original ShardCap addon, modified to work with servers where Soul Shards stack (up to 3 per bag slot on Turtle WoW).

The original fork was deleting the whole stack.
If your cap = 6, but the soul shards stacks in your bag are `{3,3,1}`, it would delete the stacks with 3), making the total count of shards to 4. 
This fix changed the deletion logic so that the total count is still 6.
If you don't have enough inventory slots, it won't split and delete anything.