data:extend{
    {
        type    = "bool-setting",
        name    = "ScanArea-limit-size",
        order   = "1",
        setting_type = "runtime-global",
        default_value = true,
    },
    {
        type    = "bool-setting",
        name    = "ScanArea-omniscience",
        order   = "2",
        setting_type = "runtime-global",
        default_value = false,
    },
}

if mods["space-exploration"] then
    local omni = data.raw["bool-setting"]["ScanArea-omniscience"]
    omni.hidden = true
    omni.forced_value = false
end
