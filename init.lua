if minetest.features.item_meta_range ~= true then
    error("hand_range requires the range feature added in 5.9.0")
end

local function get_range()
    local creat = minetest.is_creative_enabled("") and minetest.settings:has("hand_range.creative_range")

    if creat then
        local setting = minetest.settings:get("hand_range.creative_range")
        if tonumber(setting) ~= nil then
            minetest.log("action", "creative range: " .. tostring(setting))
            return setting
        end
    end

    if minetest.settings:has("hand_range.range") then
        local setting = minetest.settings:get("hand_range.range")
        if tonumber(setting) ~= nil then
            minetest.log("action", "normal range: " .. tostring(setting))
            return setting
        end
    end

    minetest.log("action", "no range!")
    return nil
end

do
    local range = get_range()
    minetest.log("action", "range = " .. range)
    if range ~= nil then
        --minetest.after(0, minetest.override_item, "", {range = range})
        minetest.override_item("", {range = range})
        minetest.log("[handrange] overridden")
    end
end

local function player_ensure_hand_list(player)
    local pinv = player:get_inventory()
    local list = player:get_inventory():get_list("hand")
    if list == nil then
        minetest.log("action", "[handrange] hand list was nil")
        pinv:set_size("hand", 1)
        pinv:set_stack("hand", 1, ItemStack(""))
    end
    minetest.log("action", "[handrange] list ensured")
end

minetest.register_on_joinplayer(player_ensure_hand_list)

minetest.register_chatcommand("my_hand_range", {
    params = "my_hand_range [range]",
    description = "Set or view your hand range",
    privs = {creative=1},
    func = function(name, params)
        player_ensure_hand_list(minetest.get_player_by_name(name))
        -- Preamble
        local player = minetest.get_player_by_name(name)
        local pinv = player:get_inventory()
        --local handlist = pinv:get_list("hand")

        -- Get
        if params == "" then
            --return true, "Yep"
            minetest.chat_send_player(name,
                dump(pinv:get_stack("hand", 1)))
            return true, dump(pinv:get_stack("hand", 1)
                :get_meta():get_string("range"))
        end

        -- Set
        local range = tonumber(params)
        if range == nil then
            return false, "Need a real number"
        end

        local stack = ItemStack("")
        stack:get_meta():set_float("range", tonumber(params))
        minetest.log("[handrange] new range: " .. stack:get_meta():get_string("range"))
        return pinv:set_stack("hand", 1, stack)
    end,
})

local function item_range(stack, player)
    local range

    -- Item Metadata
    range = stack:get_meta():get("range")
    if range ~= nil then
        return tonumber(range), "Item metadata"
    end

    -- Item definition
    range = minetest.registered_items[stack:get_name()].range
    if range ~= nil then
        return range, "Item definition"
    end

    -- Hand meta
    local pinv = player:get_inventory()
    local handlist = pinv:get_list("hand")
    if handlist ~= nil then
        minetest.log("action", "[handrange] item_range:103: hand list exists")
        local hand_stack = pinv:get_stack("hand", 1)
        range = hand_stack:get_meta():get("range")
        if range then
            return tonumber(range), "Hand metadata"
        else
            minetest.log("action", "[handrange] no hand meta!")
        end
    else
        minetest.log("action", "[handrange] lists: " .. dump(pinv:get_lists()))
    end

    -- Hand definition
    range = minetest.registered_items[""].range
    return range, "Hand definition"
end

minetest.register_chatcommand("curr_stack_range", {
    params = "curr_stack_range [range]",
    description = "Set or view your wielded ItemStack's range",
    privs = {creative=1},
    func = function(name, params)
        local player = minetest.get_player_by_name(name)
        local stack = player:get_wielded_item()

        -- get
        if params == "" then
            local range, reason = item_range(stack, player)
            return true, range .. " due to " .. reason
        end

        -- set
        local range = tonumber(params)
        if range == nil then
            return false, "Need a real number to set range with"
        end

        stack:get_meta():set_float("range", range)
        player:set_wielded_item(stack)
    end
})
