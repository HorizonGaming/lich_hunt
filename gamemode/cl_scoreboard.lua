local PANEL = {}

surface.CreateFont("us_ScoreboardBig", {
	size = ScreenScale(25),
	weight = 800,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("us_ScoreboardMedium", {
	size = ScreenScale(12),
	weight = 600,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("us_ScoreboardSmall", {
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("us_ScoreboardTiny", {
	size = ScreenScale(8),
	weight = 200,
	antialias = true,
	font = "Prototype",
} )


function PANEL:Init()
	self:SetSize(ScrW() * 0.55, ScrH() * 0.75)
	self:Center()

	self.body = self:Add("DPanel")
	self.body:Dock(FILL)
	self.body:DockMargin(5, 5, 5, 5)

	self.body.Paint = function(body, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 100) )
	end

	self.header = self.body:Add("DPanel")
	self.header:Dock(TOP)
	self.header:SetTall(self:GetTall() * 0.15)
	self.header:DockMargin(4, 4, 4, 4)

	self.header.Paint = function(header, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 200) )
	end

	self.header.title = self.header:Add("DLabel")
	self.header.title:SetText("Lich Hunt")
	self.header.title:SetFont("us_ScoreboardBig")
	self.header.title:SetContentAlignment(5)
	self.header.title:Dock(FILL)

	self.header.hostName = self.header:Add("DLabel")
	self.header.hostName:SetText( GetHostName() )
	self.header.hostName:SetFont("us_ScoreboardSmall")
	self.header.hostName:SetContentAlignment(5)
	self.header.hostName:DockMargin(3, 3, 3, 5)
	self.header.hostName:Dock(BOTTOM)
	
	self.deaths = {}
	local deaths = team.GetPlayers(2)
	for i = 1,#deaths do
		local death = self.body:Add("DPanel")
		self.deaths[i] = death
		death:Dock(TOP)
		death:SetTall(36)
		death:DockMargin(5, 5, 5, 5)

		death.Think = function(death)
			local client = team.GetPlayers(2)[i]

			if ( IsValid(client) ) then
				if (death.player != client) then
					death.player = client
				end

				death.avatar:SetPlayer(client)
			end
		end

		death.name = death:Add("DLabel")
		death.name:SetFont("us_ScoreboardMedium")
		death.name:SetText("")
		death.name:SetContentAlignment(5)
		death.name:Dock(FILL)
		death.name:DockMargin(5, 5, 5, 5)
		death.name:SetTextColor( Color(250, 70, 70, 255) )
		death.name:SizeToContents()

		death.name.Think = function(name)
			if IsValid(death.player) then
				if name:GetText() != death.player:Name() then
					name:SetText( death.player:Name() )
				end
				if not death.player:Alive() then
					name:SetTextColor(Color(200,200,200))
				else
					name:SetTextColor(Color(250,70,70,255))
				end
			end
		end

		death.Paint = function(death, w, h)
			if IsValid(death.player) and death.player:Alive() then
				draw.RoundedBox( 4, 0, 0, w, h, Color(75, 75, 75, 200) )
			else
				draw.RoundedBox( 4, 0, 0, w, h, Color(125, 75, 75, 200) )
			end
		end

		death.avatar = death:Add("AvatarImage")
		death.avatar:Dock(LEFT)
		death.avatar:DockMargin(4, 4, 4, 4)
		death.avatar:SetSize(32, 32)

		death.ping = death:Add("DLabel")
		death.ping:SetFont("us_ScoreboardMedium")
		death.ping:SetText("")
		death.ping:DockMargin(5, 5, 5, 5)
		death.ping:Dock(RIGHT)
		death.ping:SizeToContents()

		death.ping.Think = function(ping)
			if ( IsValid(death.player) ) then
				local amount = math.Clamp(death.player:Ping() / 200, 0, 1)

				ping:SetTextColor( Color( (255 * amount), 255 - (255 * amount), (1 - amount) * 75, 200) )
				ping:SetText( death.player:Ping() )
				ping:SizeToContents()
			end
		end
	end
	
	self.stats = self.body:Add("DLabel")
	self.stats:DockMargin(3, 3, 3, 3)
	self.stats:Dock(BOTTOM)
	self.stats:SetContentAlignment(5)
	self.stats:SetFont("us_ScoreboardTiny")
	self.stats:SetText("Round: 0")
	self.stats:SetExpensiveShadow( 1, Color(5, 5, 5, 250) )
	self.stats:SizeToContents()

	self.stats.Think = function(stats)
		local round = GetGlobalInt("RoundNum", 0)
		local max = 10
		local roundsleft = max - round
		
		if roundsleft == 0 then
		
			stats:SetText("Loading Next Map...")
		
		else
		
			stats:SetText("Rounds Left: "..roundsleft)
		
		end
		
	end

	self.units = self.body:Add("us_ScoreboardTeam")
	self.units:SetWide( (self:GetWide() * 0.5) - 15 )
	self.units:DockMargin(5, 5, 5, 5)
	self.units:Dock(LEFT)
	self.units:SetTeam(1)

	self.dead = self.body:Add("us_ScoreboardTeam")
	self.dead:SetWide( (self:GetWide() * 0.5) - 15 )
	self.dead:DockMargin(5, 5, 5, 5)
	self.dead:Dock(RIGHT)
	self.dead:SetTeam(3)
end

function PANEL:Paint(w, h)
	if not input.IsButtonDown(KEY_TAB) then self:Remove() return end
	draw.RoundedBox( 4, 0, 0, w, h, Color(10, 10, 10, 225) )
end

vgui.Register("us_Scoreboard", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.title = self:Add("DLabel")
	self.title:Dock(TOP)
	self.title:DockMargin(5, 5, 5, 5)
	self.title:SetFont("us_ScoreboardMedium")
	self.title:SetText("The Living")
	self.title:SizeToContents()

	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(5, 5, 5, 5)

	self.scroll.Paint = function(scroll, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(75, 75, 75, 200) )
	end
end

function PANEL:SetTeam(index)
	self.team = index
	self.title:SetTextColor( team.GetColor(index) )
end

function PANEL:Think()
	if (self.team) then
		local suffix = " Players"
		local players = team.NumPlayers(self.team)
		local name = team.GetName(self.team)

		if (players == 1) then
			suffix = " Player"
		end

		self.title:SetText(name.." - "..players..suffix)

		for k, v in SortedPairs( player.GetAll() ) do
			if (!IsValid(v.us_Row) and v:Team() == self.team) then
				local row = self.scroll:Add("us_ScoreboardPlayer")
				row:Dock(TOP)
				row:DockMargin(3, 3, 3, 0)
				row:SetPlayer(v)

				v.us_Row = row

				self.scroll:AddItem(row)
			end
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 225) )
end

vgui.Register("us_ScoreboardTeam", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:SetTall(36)

	self.avatar = self:Add("AvatarImage")
	self.avatar:Dock(LEFT)
	self.avatar:DockMargin(3, 3, 3, 3)
	self.avatar:SetSize(32, 32)

	self.avatar.click = self.avatar:Add("DButton")
	self.avatar.click:Dock(FILL)
	self.avatar.click:SetText("")

	self.avatar.click.Paint = function() end

	self.avatar.click.DoClick = function(avatarButton)
		local menu = DermaMenu()

		menu:AddOption("View Profile", function()
			if ( IsValid(self.player) ) then
				self.player:ShowProfile()
			end
		end)

		local text = "Mute"

		if (self.player.us_Muted) then
			text = "Unmute"
		end
		
		menu:AddOption(text, function()
			if ( IsValid(self.player) ) then
				self.player.us_Muted = !self.player.us_Muted
				self.player:SetMuted(self.player.us_Muted)
			end
		end)

		menu:Open()
	end

	self.name = self:Add("DLabel")
	self.name:SetFont("us_ScoreboardSmall")
	self.name:SetText("N/A")
	self.name:Dock(LEFT)
	self.name:DockMargin(5, 5, 5, 5)
	self.name:SizeToContents()

	self.ping = self:Add("DLabel")
	self.ping:SetFont("us_ScoreboardMedium")
	self.ping:SetText("")
	self.ping:DockMargin(5, 5, 5, 5)
	self.ping:Dock(RIGHT)
	self.ping:SizeToContents()

	self.frags = self:Add("DLabel")
	self.frags:SetFont("us_ScoreboardMedium")
	self.frags:SetText("0")
	self.frags:DockMargin(5, 5, 15, 5)
	self.frags:Dock(RIGHT)
	self.frags:SizeToContents()
end

function PANEL:SetPlayer(client)
	if ( IsValid(client) ) then
		self.player = client
		self.team = client:Team()
		self.avatar:SetPlayer(client)
		self.initialized = true
	end
end

function PANEL:Think()
	if ( self.initialized and !IsValid(self.player) ) then
		self:Remove()
	elseif (self.initialized) then
		if ( self.team != self.player:Team() ) then
			self:Remove()
		end

		self.frags:SetText( self.player:Frags() )
		self.frags:SizeToContents()

		local amount = math.Clamp(self.player:Ping() / 200, 0, 1)

		self.ping:SetTextColor( Color( (255 * amount), 255 - (255 * amount), (1 - amount) * 75, 200) )
		self.ping:SetText( self.player:Ping() )
		self.ping:SizeToContents()
		
		if ( self.player:Name() != self.name:GetText() ) then
			self.name:SetText( self.player:Name() )
			self.name:SizeToContents()
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 225) )
end

vgui.Register("us_ScoreboardPlayer", PANEL, "DPanel")

local SCOREBOARD

function GM:ScoreboardShow()
	gui.EnableScreenClicker(true)

	SCOREBOARD = vgui.Create("us_Scoreboard")
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)
	
	if not SCOREBOARD then return end

	SCOREBOARD:Remove()
end