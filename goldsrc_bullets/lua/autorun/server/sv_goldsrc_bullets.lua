util.AddNetworkString("GoldSrcBulletImpact")

game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact" )
PrecacheParticleSystem( "goldsrc_cs16_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact_alien" )

function HeadshotHook(ply, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD and GetConVar("gsrc_bullets_headshot"):GetBool() then
        local neededArmor = GetConVar("gsrc_bullets_headshot_helmet"):GetInt()
        local choice
        
        if ply:IsPlayer() and ply:Armor() >= neededArmor then
            choice = "GoldSrc.Impact.Helmet"
        else
            choice = "GoldSrc.Impact.Headshot"
        end

        ply:EmitSound(choice)
    end
end

hook.Add( "ScalePlayerDamage", "GoldSrcHeadshotPlayer", HeadshotHook)
hook.Add( "ScaleNPCDamage", "GoldSrcHeadshotNPC", HeadshotHook)
