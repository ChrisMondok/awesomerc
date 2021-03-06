-- Standard awesome library
awful = require("awful")
awful.rules = require("awful.rules")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")

netgraph = require("netgraph")
tagfactory = require("tagfactory")

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
fileBrowser = "thunar"

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

local setWallpaper = function()
	os.execute("/usr/bin/feh --bg-fill -z /home/chris/Pictures/Backgrounds/rotation/");
end

setWallpaper()

wallpaperTimer = timer({timeout = 60 * 5})
wallpaperTimer:connect_signal("timeout", function()
	setWallpaper()
	wallpaperTimer:again();
end)

wallpaperTimer:start()
-- }}}

-- {{{ Tags
for s = 1, screen.count() do
	awful.tag({ "home" }, s, layouts[1])
end

-- }}}

-- {{{ Menu
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

awesomemenu = { 
	{ "restart", awesome.restart, "/usr/share/icons/Arc/actions/24/reload.png" },
	{ "quit", awesome.quit, "/usr/share/icons/Arc/actions/24/application-exit.png" }
}

systemmenu = {
	{ "suspend", "systemctl suspend", "/usr/share/icons/Arc/actions/24/system-suspend.png" },
	{ "reboot", "systemctl reboot", "/usr/share/icons/Arc/actions/24/system-restart.png"},
	{ "power off", "systemctl poweroff", "/usr/share/icons/Arc/actions/24/system-shutdown.png" }
}

places = {
	{ "home", fileBrowser .. " /home/chris", "/usr/share/icons/Arc/places/24/folder_home.png" },
	{ "downloads", fileBrowser .. " /home/chris/Downloads/", "/usr/share/icons/Arc/places/24/folder-download.png" },
	{ "music", fileBrowser .. " /home/chris/Music/", "/usr/share/icons/Arc/places/24/folder-music.png" },
	{ "quicksilver", fileBrowser .. " /mnt/quicksilver/", "/usr/share/icons/Arc/devices/24/drive-harddisk.png" },
}

mainmenu = awful.menu({
	items = {
		{ "terminal", terminal, "/usr/share/icons/terminology.png" },
		{ "vivaldi", "vivaldi-stable", "/usr/share/icons/hicolor/24x24/apps/vivaldi.png" },
		{ "spotify", "/home/chris/Scripts/spotify-quiet.sh", "/usr/share/icons/hicolor/24x24/apps/spotify.png" },
		{ "geary", "geary", "/usr/share/icons/hicolor/24x24/apps/geary.png" },
		{ "steam", "steam", "/usr/share/icons/hicolor/24x24/apps/steam.png" },
		{ "places", places, "/usr/share/icons/Arc/places/24/folder.png" },
		{ "awesome", awesomemenu, "/home/chris/.config/awesome/themes/charcoal/awesome-icon.png" },
		{ "system", systemmenu, "/usr/share/icons/Arc/categories/24/preferences-system.png" },
	}
})

launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mainmenu });
-- }}}

-- {{{ Wibox

-- Create a wibox for each screen and add it
local topwibox = {}
local mypromptbox = {}
local mytagfactory = {}
local mylayoutbox = {}
local mytaglist = {}
local downspeedgraph = {}
local upspeedgraph = {}
local mytasklist = {}
local myclock = awful.widget.textclock("%a %b %d %r", 1);

myclock:buttons(awful.util.table.join(
	awful.button({ }, 1, function() os.execute("LANG=en_GB.UTF-8 /usr/bin/gsimplecal &") end )
))

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
	mypromptbox[s] = awful.widget.prompt()

	mytagfactory[s] = tagfactory(s)

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

	if s == 1 then
		downspeedgraph = netgraph.down({ width = 64, height = 20 })
		left_layout:add(downspeedgraph)
		upspeedgraph = netgraph.up({width = 64, height = 20})
		left_layout:add(upspeedgraph)
	end

	left_layout:add(launcher)
	left_layout:add(mytaglist[s])
	left_layout:add(mytagfactory[s].textbox)
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then
		right_layout:add(myclock)
		right_layout:add(wibox.widget.systray())
	end
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
	awful.button({ }, 3, function () mainmenu:toggle() end),
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
	awful.key({ modkey, "Shift"   }, "r",       awesome.restart),
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
	awful.key({ modkey            }, "p",       function() menubar.show() end),

	-- Tag manipulation
	awful.key({ modkey            }, "`",       function() mytagfactory[mouse.screen]:prompt() end),
	awful.key({ modkey            }, "=",       function() mytagfactory[mouse.screen]:create_tag() end),
	awful.key({ modkey            }, "-",       awful.tag.delete),

	awful.key({ modkey            }, "c",       function() myhud:show() end, function() myhud:hide() end)
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

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9, function ()
		local screen = mouse.screen
		local tag = awful.tag.gettags(screen)[i]
		if tag then
			awful.tag.viewonly(tag)
		end
	end),
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		local tag = awful.tag.gettags(screen)[i]
		if tag then
			awful.tag.viewtoggle(tag)
		end
	end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = awful.tag.gettags(client.focus.screen)[i]
			if tag then
				awful.client.movetotag(tag)
			end
		end
	end),
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus then
			local tag = awful.tag.gettags(client.focus.screen)[i]
			if tag then
				awful.client.toggletag(tag)
			end
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
	{
		rule = { class = "Gsimplecal" },
		properties = { y = 32 }
	},
	{
		rule = { class = "steam", name = "Steam Keyboard" },
		properties = { floating = true, focus = false, ontop = true }
	}
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
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

os.execute("/usr/bin/killall compton")
os.execute("/usr/bin/compton --config /home/chris/.comptonrc.conf &")

-- vim: filetype=lua:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:fdm=marker
