require("auto-reload").init()

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
		layer = {
			h = { key = "h", modifiers = { "ctrl" } },
			j = { key = "j", modifiers = { "ctrl" } },
			k = { key = "k", modifiers = { "ctrl" } },
			l = { key = "l", modifiers = { "ctrl" } },
			-- TODO: navigation
		},
		ignore = { "ctrl", "cmd", "shift" },
	},
})
