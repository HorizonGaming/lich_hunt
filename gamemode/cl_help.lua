local help = { "THE LICH HAS BEEN SUMMONED!",
			   "",
			   "When the round starts, the Lich has 60 seconds to hide his heart in any prop.",
			   "While the Lich's heart is hidden, he is invisible and powerful!",
			   "Search for the Lich's heart or listen for the heartbeat, and destroy it to weaken the Lich!",
			   "The Lich will stop at nothing to protect his heart, so beware his many powers!",
			   "The player who kills the Lich becomes the next Lich!",
			   "",
			   "THIS GAMEMODE IS CURRENTLY IN DEVELOPMENT. ANY SUGGESTIONS CAN BE MADE AT HORIZONGAMING.US",
			   "Gamemode by Indie and Matt Damon"}

local PANEL = { }

function PANEL:Init( )

	local text = ""
	for k, v in ipairs( help ) do
	
		if ( k != 1 ) then
			text = text.."\n"
		end
		
		text = text..v
		
	end
	
	local lbl = vgui.Create( "DLabel", self )
	lbl:SetText( text )
	lbl:SetPos( 10, 30 )
	lbl:SizeToContents( )
	
	local pad  	  = 0
	local spacing = 3 //This is a guess
	local w, h = surface.GetTextSize( "Default", "W" )
	
	self:SetSize( 600, #help * h + pad + ( #help * spacing ) )
	self:Center( )
	self:MakePopup( )
	self:SetTitle("Gamemode Help")
	self:SetKeyboardInputEnabled( false )
	
	surface.PlaySound( "ui/hint.wav" )
	
end

function PANEL:Paint( )

	surface.SetDrawColor( Color( 0, 0, 0, 220 ) )
	surface.DrawRect( 0, 0, self:GetWide( ), self:GetTall( ) )
	surface.DrawRect( 0, 0, self:GetWide( ), 22.5 )
	
end
vgui.Register( "HelpScreen", PANEL, "DFrame" )

function CC_ShowHelp( pl, cmd, args )
	
	if ( GAMEMODE.HelpScreen ) then GAMEMODE.HelpScreen:Remove( ) end
	GAMEMODE.HelpScreen = vgui.Create( "HelpScreen" )
	
end
concommand.Add( "lh_helpscreen", CC_ShowHelp )