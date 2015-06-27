local tagfactory = {}
tagfactory.__index = tagfactory

setmetatable(tagfactory, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local awful = require("awful")
local wibox = require("wibox")

function tagfactory.new(s)
	local self = setmetatable({ entry = "", screen = s }, tagfactory)

	self.textbox = wibox.widget.textbox()

	return self
end

function tagfactory:set_entry(e)
	self.entry = e
	self.textbox:set_text(self.entry)
end

function tagfactory:prompt()
	self:set_entry("")

	function stop()
		keygrabber.stop()
		self:set_entry("")
	end

	keygrabber.run(function(mod, key, event)
		if event == "release" then return end

		if key == "Escape" then stop()
		elseif key == "Return" then
			self:go_to_tag(self.entry)
			stop()
		elseif key:len() == 1 then
			local letter = key:sub(1,1):lower()
			if letter:match("%w") then
				self:set_entry(self.entry .. letter)
			end
		end
	end)
end

function tagfactory:go_to_tag(name) 
	local alltags = awful.tag.gettags(self.screen)
	for key, tag in pairs(alltags) do
		local found = tag.name == name
		if found then
			awful.tag.viewonly(tag)
			return
		end
	end

	self:create_tag()
end

function tagfactory:create_tag() 
	if self.entry == nil or self.entry == "" then self.entry = #awful.tag.gettags(self.screen) + 1 end
	awful.tag({self.entry}, self.screen, layouts[1])
	self:set_entry("")
end

return tagfactory
