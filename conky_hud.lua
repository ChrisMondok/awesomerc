local conky_hud = {}
conky_hud.__index = conky_hud

setmetatable(conky_hud, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

local naughty = require("naughty")

function conky_hud.new()
	local self = setmetatable({}, conky_hud)
	return self
end

function conky_hud:show()
	local conky = self:find_conky()
	if conky then
		conky.ontop = true
	else
		naughty.notify({title = "not found"})
	end
end

function conky_hud:hide()
	local conky = self:find_conky()
	if conky then
		conky.ontop = false
	end
end

function conky_hud:find_conky()
	local clients = client.get()
	for i, client in ipairs(clients) do
		if client.class == "conky" then
			return client
		end
	end
end

return conky_hud
