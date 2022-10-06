local function on_player_selected_area(event)
    if event.item ~= "ScanArea-tool" then
        return
    end

    local player = game.get_player(event.player_index)
    local x1, y1, x2, y2 = event.area.left_top.x, event.area.left_top.y, event.area.right_bottom.x, event.area.right_bottom.y

    if game.active_mods["space-exploration"] ~= nil then
        -- SE mode
        local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = player.surface.index})
        local r = zone.radius
        if remote.call("space-exploration", "get_satellites_launched", {force = player.force}) < 1 and not player.cheat_mode then
            player.print({"ScanArea.requires-satellite"})
            return
        end
        if zone.type ~= "planet" and zone.type ~= "moon" and not player.cheat_mode then
            player.print({"ScanArea.bad-surface"})
            return
        end
        if r ~= nil then
            -- is bounding box entirely outside the planet?
            if x1 > r or y1 > r or x2 < -r or y2 < -r then
                player.print({"ScanArea.out-of-bounds"})
                return
            end
            -- clamp bounding box to planet radius
            if x1 < -r then x1 = -r end
            if x2 > r  then x2 = r end
            if y1 < -r then y1 = -r end
            if y2 > r  then y2 = r end
        end
    else
        -- non-SE mode
        local sats = player.force.items_launched["satellite"]
        if sats == nil or sats < 1 then
            player.print({"ScanArea.requires-satellite"})
            return
        end
    end

    if player.render_mode == defines.render_mode.game then
        player.print({"ScanArea.use-map-view"})
        return
    end

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
