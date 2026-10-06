SCF_CAP_VALUE=12;
SCF_NOTIF=false;

function ShardCapFixed(param)
	if param == "" then
	    printCap()
	    DEFAULT_CHAT_FRAME:AddMessage("[SCF] For more information type: /scf help")

	elseif param == "help" then
	    DEFAULT_CHAT_FRAME:AddMessage("--- --- --- --- --- ---")
	    printHelp()

	elseif param == "notif" then
	    toggleNotifications()

	elseif param == "delete" then
	    delShards(SCF_CAP_VALUE)

	else
	    local num = tonumber(param)

	    if num and num > 0 and num % 1 == 0 then
	        SCF_CAP_VALUE = num
	        DEFAULT_CHAT_FRAME:AddMessage("[SCF] Soul shards cap changed to: " .. num)
	        printCap()
	    else
	        DEFAULT_CHAT_FRAME:AddMessage("[SCF] You must use a positive integer value.")
	    end
	end
end

function delShards(cap)
    local total_shards = 0
    local maxStackCount = 0
    local stacks = {}

    -- Scan inventory once
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if isSoulShard(bag, slot) then
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

    -- Display total shards found if notifications is enabled
    if SCF_NOTIF == true then
        DEFAULT_CHAT_FRAME:AddMessage("[SCF] Total [Soul Shard] found: " .. total_shards)
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

function isSoulShard(b, s)
	local shardItemID = 6265;
	
	-- GetContainerItemLink returns a long string, where the item's ID is part of the string. 
	-- Returns "nil" if empty bag slot, which we don't like, since we save it to local itemLink 
	-- So we have to handle that
	local itemLink = GetContainerItemLink(b, s) or "noitem"
		
	-- Check if the item link contains the Soul Shard ID
	return string.find(itemLink, shardItemID) ~= nil
end

function toggleNotifications()
    SCF_NOTIF = not SCF_NOTIF
    local str = "[SCF] Notifications " .. (SCF_NOTIF and "enabled." or "disabled.")
    DEFAULT_CHAT_FRAME:AddMessage(str .. " To change it: /scf notif")
end

function printCap()
    local totalShards = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if isSoulShard(bag, slot) then
                local _, itemCount = GetContainerItemInfo(bag, slot)
                totalShards = totalShards + itemCount
            end
        end
    end

    local str = "[SCF] Current soul shards: " .. totalShards .. "/" .. SCF_CAP_VALUE .. " shard" .. (SCF_CAP_VALUE ~= 1 and "s" or "") .. "."
    DEFAULT_CHAT_FRAME:AddMessage(str)
end

function printHelp()
	DEFAULT_CHAT_FRAME:AddMessage("[SCF] Change cap: /scf <number> ... For example: /scf 5");
	DEFAULT_CHAT_FRAME:AddMessage("[SCF] Notifications: /scf notif");
	DEFAULT_CHAT_FRAME:AddMessage("[SCF] Manual delete: /scf delete");
end

-- Events Handler
local f = CreateFrame'Frame'
f:RegisterEvent'BAG_UPDATE'
f:RegisterEvent'PLAYER_REGEN_ENABLED'

local bagUpdated, inCombat = nil, nil
f:SetScript('OnEvent', function()
    if event == "BAG_UPDATE" then
        bagUpdated = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    end

    if bagUpdated and not inCombat then
        bagUpdated, inCombat = nil, nil
        delShards(SCF_CAP_VALUE)
    end
end)

SLASH_SCF1 = '/scf'
SlashCmdList["SCF"] = ShardCapFixed
