local module = {}

awful = require("awful")

local new = function(direction, config)
	local t = timer({ timeout = 1 })

	local filename = (direction == "tx" and "/sys/class/net/eth0/statistics/tx_bytes" or "/sys/class/net/eth0/statistics/rx_bytes")

	local bytes = 0

	local graph = awful.widget.graph(config)
	graph:set_scale(true)
	graph:set_color(direction == "tx" and "#884444" or "#448844")

	local tip = awful.tooltip({ objects = {graph}})

	local update = (function()
		local diff = 0
		for line in io.lines(filename) do
			local newbytes = tonumber(line)
			if bytes > 0 then
				diff = newbytes - bytes
			end
			bytes = newbytes
		end

		graph:add_value(diff)

		tip:set_text(
			string.format("%9.4f kBps %s", diff/1024, (direction == "tx" and "up" or "down"))
		)

	end)

	t:connect_signal("timeout", update)
	t:start()

	return graph
end

module.down = function(config)
	return new("rx",config)
end

module.up = function(config)
	return new("tx",config)
end

return module
