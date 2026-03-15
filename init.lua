require("auto-reload").init()

local hotkey = require("hs.hotkey")
local window = require("hs.window")

local dock = require("dock")

local nav_layer = {}
for _, key in ipairs({ "h", "j", "k", "l" }) do
	nav_layer[key] = { key = key, modifiers = { "ctrl" } }
end
for i = 1, 10 do
	local key = i - 1
	nav_layer[tostring(key)] = function()
		dock.open_item(i)
	end
end

require("overload"):init({
	{
		key = "escape",
		layer = {
			h = "left",
			j = "down",
			k = "up",
			l = "right",
		},
		default = "ctrl",
	},
	{
		key = "tab",
		layer = nav_layer,
		ignore = { "ctrl", "cmd", "shift" },
	},
})

hotkey.bind({ "cmd" }, "k", function()
	local win = window.focusedWindow()
	if not win then
		return
	end
	win:maximize()
end)
