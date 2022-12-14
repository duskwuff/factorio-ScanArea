data:extend{
    {
        type            = "selection-tool",
        name            = "ScanArea-tool",
        subgroup        = "tool",
        icon            = "__base__/graphics/icons/satellite.png",
        icon_size       = 64,
        icon_mipmaps    = 4,
        flags           = { "hidden", "not-stackable", "only-in-cursor", "spawnable" },
        stack_size      = 1,
        stackable       = false,
        selection_mode = { "nothing" },
        alt_selection_mode = { "nothing" },
        selection_cursor_box_type = "copy",
        alt_selection_cursor_box_type = "copy",
        selection_color = { r = 0.0, g = 0.5, b = 1.0, a = 1 },
        alt_selection_color = { r = 1.0, g = 0.0, b = 0.0, a = 1 },
    },
    {
        type            = "shortcut",
        name            = "ScanArea-shortcut",
        action          = "spawn-item",
        item_to_spawn   = "ScanArea-tool",
        technology_to_unlock = "rocket-silo",
        icon        = {
            filename     = "__ScanArea__/graphics/telescope32.png",
            size         = 32,
            mipmap_count = 0,
        },
    },
    {
        type            = "custom-input",
        name            = "ScanArea-input",
        key_sequence    = "",
        action          = "spawn-item",
        item_to_spawn   = "ScanArea-tool",
    },
}
