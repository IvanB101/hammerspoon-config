MAIN_STATE = {}
local s = {}
MAIN_STATE.state = s

s.nav_keys = { h = "left", j = "down", k = "up", l = "right" }
s.key_was_pressed = false
s.esc_pressed = false

require("auto-reload").start(s)

s.tag = 0x2222
s.tag_and_post = function(event)
	event:setProperty(hs.eventtap.event.properties.eventSourceUserData, s.tag)
	event:post()
end

s.esc_tap = hs.eventtap
	.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)
		local props = hs.eventtap.event.properties
		local key_code = event:getKeyCode()
		local event_type = event:getType()
		local esc_key_code = 0x35

		if event:getProperty(props.eventSourceUserData) == s.tag then
			return false
		end

		if key_code == esc_key_code then
			if event_type == hs.eventtap.event.types.keyDown then
				s.key_was_pressed = false
				s.esc_pressed = true
				return true
			end
			s.esc_pressed = false
			if not s.key_was_pressed then
				s.tag_and_post(hs.eventtap.event.newKeyEvent({}, esc_key_code, true))
				s.tag_and_post(hs.eventtap.event.newKeyEvent({}, esc_key_code, false))
			end

			return true
		end

		-- sending events with hs.eventtap.keyStroke is generating infinite loop
		if s.esc_pressed then
			local char = hs.keycodes.map[key_code]
			local mapping = s.nav_keys[char]
			local new_event = event:copy()

			if event_type == hs.eventtap.event.types.keyDown then
				s.key_was_pressed = true
			end

			if mapping then
				new_event:setKeyCode(hs.keycodes.map[mapping])
			else
				local new_flags = new_event:getFlags()
				new_flags.ctrl = true
				new_event:setFlags(new_flags)
			end
			s.tag_and_post(new_event)
			return true
		end

		return false
	end)
	:start()

-- Function to trigger the nth item in the Dock
local function openDockItem(n)
	local dock = hs.application.get("Dock")
	if not dock then
		return
	end

	local axDock = hs.axuielement.applicationElement(dock)
	local list = axDock[1] -- The main list of icons

	local items = list:attributeValue("AXChildren")

	if items and items[n] then
		items[n]:performAction("AXPress")
	end
end

-- Bind Cmd + 1 through 9
for i = 1, 10 do
	local key = i - 1
	hs.hotkey.bind({ "cmd" }, tostring(key), function()
		openDockItem(i)
	end)
end

hs.hotkey.bind({ "cmd" }, "k", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
    win:maximize()
end)
