-- FullBright feature for MinimalHackGUI (Mobile-compatible)

local Lighting = game:GetService("Lighting")

local defaultBrightness, defaultFogEnd
local isActive = false

local function init(deps)
    Lighting = deps.Lighting
    defaultBrightness = Lighting.Brightness
    defaultFogEnd = Lighting.FogEnd
end

local function enable()
    isActive = true
    Lighting.Brightness = 2
    Lighting.FogEnd = 100000
end

local function disable()
    isActive = false
    Lighting.Brightness = defaultBrightness
    Lighting.FogEnd = defaultFogEnd
end

return {
    init = init,
    enable = enable,
    disable = disable
}