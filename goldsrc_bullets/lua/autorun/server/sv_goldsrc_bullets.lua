util.AddNetworkString("GoldSrcBulletImpact")

game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact" )
PrecacheParticleSystem( "goldsrc_cs16_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact_alien" )

function HeadshotHook(ent, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD and GetConVar("gsrc_bullets_headshot"):GetBool() then
        local neededArmor = GetConVar("gsrc_bullets_headshot_helmet"):GetInt()
        local onlyPlayers = GetConVar("gsrc_bullets_headshot_players"):GetBool()
        local choice
        
        if !ent:IsPlayer() and onlyPlayers then return end

        if ent:IsPlayer() and ent:Armor() >= neededArmor then
            choice = "GoldSrc.Impact.Helmet"
        else
            choice = "GoldSrc.Impact.Headshot"
        end

        ent:EmitSound(choice)
    end
end

hook.Add( "ScalePlayerDamage", "GoldSrcHeadshotPlayer", HeadshotHook)
hook.Add( "ScaleNPCDamage", "GoldSrcHeadshotNPC", HeadshotHook)
