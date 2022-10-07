local function on_player_selected_area(event)
    if event.item ~= "ScanArea-tool" then
        return
    end

    local player = game.get_player(event.player_index)
    local x1, y1, x2, y2 = event.area.left_top.x, event.area.left_top.y, event.area.right_bottom.x, event.area.right_bottom.y
    local sw, sh = player.surface.map_gen_settings.width / 2, player.surface.map_gen_settings.height / 2

    if player.render_mode == defines.render_mode.game then
        player.print({"ScanArea.use-map-view"})
        return
    end

    if game.active_mods["space-exploration"] ~= nil then
        local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = player.surface.index})
        if zone == nil then -- possibly a weird surface like the universe map
            player.print({"ScanArea.bad-surface"})
            return
        end
        if remote.call("space-exploration", "get_satellites_launched", {force = player.force}) < 1 then
            player.print({"ScanArea.requires-satellite"})
            return
        end
        -- some SE surfaces, particularly Nauvis, are smaller than the map gen
        -- settings say they should be
        sw, sh = zone.radius, zone.radius
    else
        -- non-SE
        local sats = player.force.items_launched["satellite"]
        if sats == nil or sats < 1 then
            player.print({"ScanArea.requires-satellite"})
            return
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

    player.force.chart(player.surface, {{x1, y1}, {x2, y2}})
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
