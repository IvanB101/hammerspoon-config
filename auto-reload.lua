local pathwatcher = require("hs.pathwatcher")

local M = {}

M.init = function()
	local function reloadConfig(files)
		M.do_reload = false
		for _, file in pairs(files) do
			if file:sub(-4) == ".lua" then
				M.do_reload = true
			end
		end
		if M.do_reload then
			hs.reload()
		end
	end

	M.file_watcher = pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
end

return M
