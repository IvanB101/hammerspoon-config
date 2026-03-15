---@meta

---@alias EventModifier "ctrl" | "alt" | "cmd" | "shift" | "fn"

---@class EventFlags
---@field cmd boolean
---@field alt boolean
---@field ctrl boolean
---@field fn boolean
---@field shift boolean

---@class Event
---@field copy fun(self:Event):Event
---@field getFlags fun(self:Event):EventFlags
---@field setFlags fun(self:Event, flags:EventFlags):Event
---@field getProperty fun(self:Event, property: number):number
---@field getType fun(self:Event):number
---@field getKeyCode fun(self:Event)
---@field setProperty fun(self:Event, property:number, value: number)
---@field setKeyCode fun(self:Event, value: number)
---@field post fun(self:Event)
