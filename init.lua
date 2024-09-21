local function get_range()
    local creat = minetest.is_creative_enabled("") and minetest.settings:has("hand_range.creative_range")
    local has_range = minetest.settings:has("hand_range.range") 

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

local range = get_range()
minetest.log("action", "range = " .. range)
if range ~= nil then
    --minetest.after(0, minetest.override_item, "", {range = range})
    minetest.override_item("", {range = range})
    minetest.log("[handrange] overriden")
end

minetest.register_chatcommand("my_hand_range", {
    params = "my_hand_range [range]",
    description = "Set or view your hand range",
    privs = {creative=1},
    func = function(name, params)
        ---- preamble
        local player = minetest.get_player_by_name(name)
        local pmeta = player:get_meta()
        local pinv = player:get_inventory()
        local handlist = pinv:get_list("hand")
        if handlist == nil then
            pinv:set_size("hand", 1)
            pinv:set_stack("hand", 0, ItemStack(""))
            pinv = player:get_inventory()
        end

        --- get
        if params == "" then
            --return true, "Yep"
            minetest.chat_send_player(name,
                dump(pinv:get_stack("hand", 0)))
            return true, dump(pinv:get_stack("hand", 0)
                :get_meta():get_string("range"))

            --return 
        end

        ---- set
        
        -- get stack meta
        -- set range on it
        -- save it
        local stack = ItemStack("")
        stack:get_meta():set_int("range", tonumber(params))
        pinv:set_stack("hand", 0, stack)
    end,
})
