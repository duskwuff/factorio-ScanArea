local function player_has_scan_unlocked(player)
    return player.cheat_mode or player.force.rockets_launched > 0
end


local function on_player_selected_area(event)
    if event.item ~= "ScanArea-tool" then
        return
    end

    local player = game.players[event.player_index]
    local surface = player.surface
    local x1, y1, x2, y2 = event.area.left_top.x, event.area.left_top.y, event.area.right_bottom.x, event.area.right_bottom.y
    local sw, sh = surface.map_gen_settings.width / 2, surface.map_gen_settings.height / 2

    if surface.platform then
        player.print({"ScanArea.bad-surface"})
        return
    end

    if player.render_mode == defines.render_mode.game then
        player.print({"ScanArea.use-map-view"})
        return
    end

    if not player_has_scan_unlocked(player) then
        player.print({"ScanArea.requires-launch"})
        return
    end

    if script.active_mods["space-exploration"] then
        -- some SE surfaces, particularly Nauvis, are smaller than the map gen settings say they should be
        local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
        if zone and zone.radius ~= nil then
            sw, sh = zone.radius, zone.radius
        end
    end

    -- bounding box entirely outside the surface
    if x1 > sw or y1 > sw or x2 < -sh or y2 < -sh then
        player.print({"ScanArea.out-of-bounds"})
        return
    end

    -- clamp bounding box to surface edges
    if x1 < -sw then x1 = -sw end
    if x2 >  sw then x2 =  sw end
    if y1 < -sh then y1 = -sh end
    if y2 >  sh then y2 =  sh end

    -- roughly 100x100 chunks
    if settings.global["ScanArea-limit-size"].value and (x2-x1)*(y2-y1) > 1e7 then
        player.print({"ScanArea.too-big", {"mod-setting-name.ScanArea-limit-size"}})
        return
    end

    player.force.chart(surface, {{x1, y1}, {x2, y2}})
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)


local function on_player_alt_selected_area(event)
    if event.item ~= "ScanArea-tool" then
        return
    end

    local player = game.players[event.player_index]
    local x1, y1, x2, y2 = event.area.left_top.x, event.area.left_top.y, event.area.right_bottom.x, event.area.right_bottom.y

    player.force.cancel_charting(player.surface)
    for x = x1, x2, 32 do
        for y = y1, y2, 32 do
            player.force.unchart_chunk({x/32, y/32}, player.surface)
        end
    end
end
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)


local function init_storage()
    storage.omni_viewers = storage.omni_viewers or {}
end
script.on_init(init_storage)
script.on_configuration_changed(init_storage)


local function on_player_controller_changed(event)
    local player = game.players[event.player_index]
    if player.controller_type == defines.controllers.remote then
        if settings.global["ScanArea-omniscience"].value and player_has_scan_unlocked(player) then
            storage.omni_viewers[event.player_index] = {}
        end
    else
        storage.omni_viewers[event.player_index] = nil
    end
end
script.on_event(defines.events.on_player_controller_changed, on_player_controller_changed)


local function on_nth_tick(event)
    for id, rv in pairs(storage.omni_viewers) do
        local player = game.players[id]
        if player then
            if player.render_mode == defines.render_mode.chart_zoomed_in and not player.surface.platform and event.tick - (rv.tick or 0) >= 20 then
                local px, py = player.position.x, player.position.y
                local pos = string.format("%d/%d/%d", math.floor(px / 32), math.floor(py / 32), player.surface.index)
                if pos ~= rv.pos or event.tick - (rv.tick or 0) >= 300 then
                    player.force.chart(player.surface, {{ x = px - 96, y = py - 96 }, { x = px + 96, y = py + 96 }})
                    rv.pos = pos
                    rv.tick = event.tick
                end
            end
        else
            storage.omni_viewers[id] = nil
        end
    end
end
script.on_nth_tick(12, on_nth_tick)
