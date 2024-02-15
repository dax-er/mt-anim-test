local anims = {
    hud = {},
    hud2 = {},
    hud2_return = {},
}
local animating = {
    hud = {},
    hud2 = {},
}

local function play_anim_hud(itemstack, user, pointed_thing)
    if not user:is_player() then return end
    local pname = user:get_player_name()
    local state = animating["hud"][pname]
    minetest.debug(state)
    if state == true then
        minetest.debug("stopped")
        local last_tween = anims["hud"][pname]
        last_tween:stop()
        return
    end
    minetest.debug("continued")
    animating["hud"][pname] = true
    local tween = Be2eenApi.Tween()
    tween.interpolation = Be2eenApi.Interpolations.sinusoidal_in_out
    tween.loop = true
    tween.duration = 3
    tween.pingpong = true
    local hud = user:hud_add({
        type = "image",
        position = {x = 0.7, y = 0.45},
        text = "anim_test_example.png",
        scale = {x = 1, y = 1},
    })

    function tween:onStep()
        user:hud_change(hud, "scale", {
            x = self:get_animated(1, 12),
            y = self:get_animated(1, 12),
        })
    end

    function tween:onStopped()
        animating["hud"][pname] = false
        user:hud_remove(hud)
    end
    anims["hud"][pname] = tween:start()
    return itemstack
end

local function play_anim_hud2(itemstack, user, pointed_thing)
    if not user:is_player() then return end
    local pname = user:get_player_name()
    local state = animating["hud2"][pname]
    local return_check = anims["hud2_return"][pname]
    if state == true then
        if anims["hud2"][pname]:is_running() then anims["hud2"][pname]:stop() end
        if anims["hud2_return"][pname]:is_running() then anims["hud2_return"][pname]:stop() end
        return
    end
    animating["hud2"][pname] = true
    local tween = Be2eenApi.Tween()
    tween.interpolation = Be2eenApi.Interpolations.elastic
    tween.duration = 3
    local return_tween = Be2eenApi.Tween()
    return_tween.interpolation = Be2eenApi.Interpolations.sinusoidal_out
    return_tween.duration = 1.5
    anims["hud2_return"][pname] = return_tween
    local hud = user:hud_add({
        type = "text",
        scale = {x = 100, y = 100},
        position = {x = 0.2, y = 0.5},
        text = "This is elastic animation!",
        number = 0xFF0000,
        alignment = {x = 0, y = 0},
        size = {x = 2.5},
    })

    function return_tween:onStep()
        user:hud_change(hud, "position", {
            x = self:get_animated(0.7, 0.2),
            y = user:hud_get(hud).position.y,
        })
    end
    function return_tween:onFinished()
        anims["hud2"][pname] = tween:start()
    end
    function return_tween:onStopped()
        animating["hud2"][pname] = false
        user:hud_remove(hud)
    end
    function tween:onStep()
        user:hud_change(hud, "position", {
            x = self:get_animated(0.2, 0.7),
            y = user:hud_get(hud).position.y,
        })
    end
    function tween:onStopped()
        animating["hud2"][pname] = false
        user:hud_remove(hud)
    end
    function tween:onFinished()
        anims["hud2_return"][pname] = return_tween:start()
    end
    anims["hud2"][pname] = tween:start()
    return itemstack
end

minetest.register_craftitem("anim_test:example_scale", {
    description = "An Animation example of scale: Right Click to test",
    inventory_image = "anim_test_example.png",
    on_secondary_use = play_anim_hud,
    stack_max = 1,
})
minetest.register_craftitem("anim_test:example_position", {
    description = "An Animation example of position: Right Click to test",
    inventory_image = "anim_test_example.png^[screen:red",
    on_secondary_use = play_anim_hud2,
    stack_max = 1,
})