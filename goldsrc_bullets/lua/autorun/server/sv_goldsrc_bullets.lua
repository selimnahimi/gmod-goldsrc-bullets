util.AddNetworkString("GoldSrcBulletImpact")

local cvarRicochet = CreateConVar("gsrc_bullets_ricochet", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc ricochet sounds")
local cvarHeadshot = CreateConVar("gsrc_bullets_headshot", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc headshot sounds")

game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact" )
PrecacheParticleSystem( "goldsrc_cs16_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact" )

-- Sounds played on headshot
local headshotSounds = {
    "gsrc/player/headshot1.wav",
    "gsrc/player/headshot2.wav",
    "gsrc/player/headshot3.wav"
}

function HeadshotHook(ply, hitgroup, dmginfo)
    if (cvarHeadshot:GetBool()) then
        if hitgroup == HITGROUP_HEAD then
            ply:EmitSound(headshotSounds[math.random(#headshotSounds)])
            --dmginfo:ScaleDamage(3)
        end
    end
end

hook.Add( "ScalePlayerDamage", "GoldSrcHeadshotPlayer", HeadshotHook)
hook.Add( "ScaleNPCDamage", "GoldSrcHeadshotNPC", HeadshotHook)
