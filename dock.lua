local M = {}

local app = require("hs.application")
local aux_ui_elem = require("hs.axuielement")

M.open_item = function(n)
	local dock = app.get("Dock")
	if not dock then
		return
	end

	local axDock = aux_ui_elem.applicationElement(dock)
	local list = axDock[1] -- The main list of icons

	local items = list:attributeValue("AXChildren")

	if items and items[n] then
		items[n]:performAction("AXPress")
	end
end

return M
