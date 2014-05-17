-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")

netgraph = require("netgraph")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	                 title = "Oops, there were errors during startup!",
	                 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true
	
		naughty.notify({ preset = naughty.config.presets.critical,
		                 title = "Oops, an error happened!",
		                 text = err })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/chris/.config/awesome/themes/charcoal/theme.lua")

modkey = "Mod4"

terminal = "terminology"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	--awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.floating,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
-- }}}

-- {{{ Tags
tags = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget

-- Create a wibox for each screen and add it
local topwibox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
local downspeedgraph = {}
local upspeedgraph = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ }, 2, closetag),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({ }, 6, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({ }, 7, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		c.minimized = false
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 2, function(c)
		c:kill()
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 6, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 7, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end))

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
	)
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	topwibox[s] = awful.wibox({ position = "top", screen = s })


	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()

	if s == 3 then
		downspeedgraph = netgraph.down({ width = 64, height = 20 })
		left_layout:add(downspeedgraph)
		upspeedgraph = netgraph.up({width = 64, height = 20})
		left_layout:add(upspeedgraph)
	end

	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	topwibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function() os.execute("/usr/bin/gnome-pie -o 875 &") end),
	-- awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext),
	awful.button({ }, 6, awful.tag.viewprev),
	awful.button({ }, 7, awful.tag.viewnext)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,           }, "Left",    awful.tag.viewprev),
	awful.key({ modkey,           }, "Right",   awful.tag.viewnext),
	awful.key({ modkey,           }, "Escape",  awful.tag.history.restore),

	awful.key({ modkey,           }, "j",       function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,           }, "k",       function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey,           }, "Tab",     function ()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j",       function () awful.client.swap.byidx(  1) end),
	awful.key({ modkey, "Shift"   }, "k",       function () awful.client.swap.byidx( -1) end),
	awful.key({ modkey, "Control" }, "j",       function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k",       function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u",       awful.client.urgent.jumpto),

	-- Standard program
	awful.key({ modkey,           }, "Return",  function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r",       awesome.restart),
	awful.key({ modkey, "Shift"   }, "q",       awesome.quit),

	awful.key({ modkey,           }, "l",       function () awful.tag.incmwfact( 0.05) end),
	awful.key({ modkey,           }, "h",       function () awful.tag.incmwfact(-0.05) end),
	awful.key({ modkey, "Shift"   }, "h",       function () awful.tag.incnmaster( 1)   end),
	awful.key({ modkey, "Shift"   }, "l",       function () awful.tag.incnmaster(-1)   end),
	awful.key({ modkey, "Control" }, "h",       function () awful.tag.incncol( 1) end),
	awful.key({ modkey, "Control" }, "l",       function () awful.tag.incncol(-1) end),
	awful.key({ modkey,           }, "space",   function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space",   function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n",       awful.client.restore),

	-- Prompt
	awful.key({ modkey            }, "r",       function () mypromptbox[mouse.screen]:run() end),
	
	-- Menubar
	awful.key({ modkey            }, "p",       function() menubar.show() end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",       function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey,           }, "c",       function (c) awful.placement.centered(c, nil) end),
	awful.key({ modkey, "Shift"   }, "c",       function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",   awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return",  function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",       awful.client.movetoscreen                        ),
	awful.key({ modkey,           }, "t",       function (c) c.ontop = not c.ontop            end),
	awful.key({ modkey,           }, "n",       function (c) c.minimized = true               end),
	awful.key({ modkey,           }, "m",       function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9, function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewonly(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewtoggle(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.movetotag(tags[client.focus.screen][i])
		end
	end),
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.toggletag(tags[client.focus.screen][i])
		end
	end))
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = clientkeys,
			buttons = clientbuttons
		}
	},
	{
		rule = { class = "MPlayer" },
		properties = { floating = true }
	},
	{
		rule = { class = "pinentry" },
		properties = { floating = true }
	},
	{
		rule = { class= "Gnome-pie" },
		properties = { border_width = 0 }
	},
	{
		rule = { name= "File Operation Progress" },
		properties = { floating = true }
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	--if c.class == "Rhythmbox" then
	--	awful.client.movetotag(startActivity("music"),c)
	--end

	local titlebars_enabled = false
	if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(awful.titlebar.widget.iconwidget(c))

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(awful.titlebar.widget.floatingbutton(c))
		right_layout:add(awful.titlebar.widget.maximizedbutton(c))
		right_layout:add(awful.titlebar.widget.stickybutton(c))
		right_layout:add(awful.titlebar.widget.ontopbutton(c))
		right_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local title = awful.titlebar.widget.titlewidget(c)
		title:buttons(awful.util.table.join(
			awful.button({ }, 1, function()
				client.focus = c
				c:raise()
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
				client.focus = c
				c:raise()
				awful.mouse.client.resize(c)
			end)
		))

		-- Now bring it all together
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_right(right_layout)
		layout:set_middle(title)

		awful.titlebar(c):set_widget(layout)
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

os.execute("/usr/bin/compton --config /home/chris/.comptonrc.conf &")

-- vim: filetype=lua:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:fdm=marker
