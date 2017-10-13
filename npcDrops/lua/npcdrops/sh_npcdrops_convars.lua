-- npcDrops by cometopapa
if SERVER then
	CreateConVar( "npcdrops_disabled", "false", FCVAR_ARCHIVE, "Enable/Disable npcDrops." )
	CreateConVar( "npcdrops_itemremove", "false", FCVAR_ARCHIVE, "Remove item or don't after a while." )
	CreateConVar( "npcdrops_itemremovedly", "0", FCVAR_ARCHIVE, "Remove delay only if item removing true." )
	CreateConVar( "npcdrops_notify", "true", FCVAR_ARCHIVE, "Notify player if they have dropped something?" )
	CreateConVar( "npcdrops_lootsound", "true", FCVAR_ARCHIVE, "Loot sound?" )
end