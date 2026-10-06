-- ShardCapFixed.lua
SCF_CAP_VALUE=12;
SCF_SPAM=false; 

function delShards(cap)
    local total_shards = 0
    local maxStackCount = 0
    local stacks = {}

    -- Scan inventory once
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if shardTest(bag, slot) then
                local _, itemCount = GetContainerItemInfo(bag, slot)

                total_shards = total_shards + itemCount

                if not stacks[itemCount] then
                    stacks[itemCount] = {}
                end

                table.insert(stacks[itemCount], {
                    bag = bag,
                    slot = slot
                })

                if itemCount > maxStackCount then
                    maxStackCount = itemCount
                end
            end
        end
    end

    -- Display total shards found if spam is enabled
    if SCF_SPAM == true then
        DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Total [Soul Shard] found: " .. total_shards)
    end

    local excess = total_shards - cap
    if excess <= 0 then
        return
    end

    -- Delete entire stacks, starting from largest
    for count = maxStackCount, 1, -1 do
        if stacks[count] and table.getn(stacks[count]) > 0 then
            while excess >= count do
                local stack = table.remove(stacks[count])
                
                ClearCursor()
                PickupContainerItem(stack.bag, stack.slot)
                DeleteCursorItem()
                excess = excess - count
            end
        end
    end

    -- Partial stack deletion (split remaining excess from smallest larger stack)
    if excess > 0 then
        for count = excess + 1, maxStackCount do
            if stacks[count] and table.getn(stacks[count]) > 0 then
                local stack = table.remove(stacks[count])

                ClearCursor()
                SplitContainerItem(stack.bag, stack.slot, excess)
                if CursorHasItem() then
                    DeleteCursorItem()
                end
                return
            end
        end
    end
end

function shardTest(b, s)
	-- Soul Shards have itemID = 6265
	local shardID = 6265;
	
	-- GetContainerItemLink returns a long string, where the item's ID is part of the string. 
	-- Returns "nil" if empty bag slot, which we don't like, since we save it to local itemLink 
	-- So we have to handle that
	local itemLink = GetContainerItemLink(b, s) or "noitem"
		
	-- Test if a given item is a shard with LUA's string.find(x,y) function.
	return string.find(itemLink, shardID) ~= nil
end

-- Events to listen for:
local f = CreateFrame'Frame'
f:RegisterEvent'BAG_UPDATE'
f:RegisterEvent'PLAYER_REGEN_ENABLED'

-- Check if something is in the bags and check if player exited combat.
local combat, bag = nil, nil
f:SetScript('OnEvent', function()
	-- DEFAULT_CHAT_FRAME:AddMessage("registered")
	if event == "BAG_UPDATE" then
		bag = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		combat = true
	end

	if bag and combat then
		bag, combat = nil, nil
		delShards(SCF_CAP_VALUE);
	end
end)

function ShardCapFixed_IsInteger(n)
	-- Returns true if n is an integer.
	if tonumber(n) ~= math.floor(tonumber(n)) then
		return false
	else
		return true
	end
end

function ShardCapFixed_PrintCap()
	-- Correct spelling of shard/shards in case the user sets the cap to 1.
	-- xD smiley face.
	str = "ShardCapFixed - Current cap is "..SCF_CAP_VALUE.." shard";
	if SCF_CAP_VALUE ~= 1 then 
		str = str.."s"
	end 
	DEFAULT_CHAT_FRAME:AddMessage(str..".");
end

function ShardCapFixed_PrintInfo()
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Change cap: /scf <number> ... For example: /scf 5");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Show cap: /scf");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Notifications: /scf spam");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Manual delete: /scf delete");
	DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Deletes when you exit combat. Deletes from backpack first. Put your soulbag in your last bag slot, like a normal person. Cheers.");
end

function ShardCapFixed_ToggleSpam()
	local msg ="ShardCapFixed - Notifications ";

	if SCF_SPAM == true then 
		SCF_SPAM = false; 
		msg = msg.."disabled."; 
	else 
		SCF_SPAM = true; 
		msg = msg.."enabled.";
	end 
	DEFAULT_CHAT_FRAME:AddMessage(msg.." To change it: /scf spam");
end

function ShardCapFixed(parameter) 
	if parameter == '' then
		ShardCapFixed_PrintCap();
		DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - Change cap: /scf <number> ... For example: /scf 5");
		DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - More information type: /scf info");
	end

	if parameter == "info" then
		DEFAULT_CHAT_FRAME:AddMessage("--- --- --- --- --- ---");
		ShardCapFixed_PrintInfo();
	end
	
	-- toggle spam 
	if parameter == "spam" then
		ShardCapFixed_ToggleSpam();
	end 
	
	-- check if parameter is a number (this if clause seems weird, but it's not)
	if type(tonumber(parameter)) == "number" then
		-- If parameter is a number, check for integer
		if ShardCapFixed_IsInteger(parameter) then
			-- If it IS an integer, we set the new value for SCF_CAP_VALUE..., account for negative numbers. 
			SCF_CAP_VALUE = math.abs(parameter); 
			ShardCapFixed_PrintCap();
		else 
			-- If it is NOT and integer, we tell them to type /scf info for more information or something... 
			DEFAULT_CHAT_FRAME:AddMessage("ShardCapFixed - You must use an integer for example 1 or 5 or 28.");
		end 
	end
	
	if parameter == "delete" then
		delShards(SCF_CAP_VALUE)
	end
end

SLASH_SCF1 = '/scf'
SlashCmdList["SCF"] = ShardCapFixed
