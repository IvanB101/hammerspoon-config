require("definitions")

local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")
local user_data_prop = eventtap.event.properties.eventSourceUserData

---@module 'overload'

---@class KeyMapping
---@field key string
---@field modifiers EventModifier[]

---@alias Mapping KeyMapping | fun()

---@class OverloadOpts
---@field key string
---@field layer table<string, KeyMapping | fun() | string>
---@field ignore? EventModifier[]
---@field default? EventModifier

---@class Overload : OverloadOpts
---@field active boolean
---@field used boolean

local M = {}

---@type integer
M.tag = 0x2222
---@type table<string, Overload>
M.overloads = {}
---@type Overload[]
M.ordered_overloads = {}

--- Copy an event and add a modifier to it
---@param event Event
---@param modifier EventModifier
M.add_modifier = function(event, modifier)
	local new_flags = event:getFlags()
	new_flags[modifier] = true
	event:setFlags(new_flags)
end

---@param key_code number
---@return Event[]
M.tagged_key_press = function(key_code)
	local down = eventtap.event.newKeyEvent({}, key_code, true)
	down:setProperty(user_data_prop, M.tag)
	local up = eventtap.event.newKeyEvent({}, key_code, false)
	up:setProperty(user_data_prop, M.tag)
	return { down, up }
end

--- Event handler for the eventtap
---@param event Event
---@return boolean, Event?
M.event_handler = function(event)
	if not M.overloads then
		return false
	end

	if event:getProperty(user_data_prop) == M.tag then
		return false
	end

	local key_code = event:getKeyCode()
	local key = keycodes.map[key_code]

	local overload = M.overloads[key]
	local modifiers = event:getFlags()
	if overload then
		for modifier, _ in pairs(modifiers) do
			if (overload.ignore or {})[modifier] then
				return false
			end
		end
		if event:getType() == eventtap.event.types.keyDown then
			overload.active = true
			overload.used = false
			return true
		end
        if not overload.active then
            return false
        end
		overload.active = false
		return true, not overload.used and M.tagged_key_press(key_code) or nil
	end

	local changed = false
	for _, layer in ipairs(M.ordered_overloads) do
		if not layer.active then
			goto continue
		end

		local map = layer.layer[key]
		if not map and not layer.default then
			goto continue
		end
		layer.used = true
		changed = true
		if not map then
			M.add_modifier(event, layer.default)
			goto continue
		end

		if type(map) == "function" then
			if event:getType() == eventtap.event.types.keyDown then
				map()
			end
			return true
		end
		key = map.key
		event:setKeyCode(keycodes.map[key])
		for _, modifier in ipairs(map.modifiers or {}) do
			M.add_modifier(event, modifier)
		end

		::continue::
	end
	if changed then
		event:setProperty(user_data_prop, M.tag)
		return true, { event }
	end

	return false
end

--- Intialize the overloading module
---@param overloads OverloadOpts[]
function M:init(overloads)
	M.esc_tap =
		hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, M.event_handler):start()

	for _, overload_opts in ipairs(overloads) do
		local ignore = {}
		if overload_opts.ignore then
			for _, modifier in ipairs(overload_opts.ignore) do
				ignore[modifier] = true
			end
		end
		local layer = {}
		for key, mapping in pairs(overload_opts.layer) do
			if type(mapping) == "string" then
				layer[key] = { key = mapping }
			else
				layer[key] = mapping
			end
		end

		local overload = {
			key = overload_opts.key,
			layer = layer,
			ignore = ignore,
			default = overload_opts.default,
			active = false,
			used = false,
		}

		M.ordered_overloads[#M.ordered_overloads + 1] = overload
		M.overloads[overload_opts.key] = overload
	end
end

return M
