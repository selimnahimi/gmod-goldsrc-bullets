util.AddNetworkString("GoldSrcBulletImpact")

local cvarRicochet = CreateConVar("gsrc_bullets_ricochet", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc ricochet sounds")
local cvarHeadshot = CreateConVar("gsrc_bullets_headshot", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc headshot sounds")

game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact" )
PrecacheParticleSystem( "goldsrc_cs16_impact" )
PrecacheParticleSystem( "goldsrc_blood_impact" )

-- Ricochet sounds
local sounds = {
    "gsrc/weapons/ric1.wav",
    "gsrc/weapons/ric2.wav",
    "gsrc/weapons/ric3.wav",
    "gsrc/weapons/ric4.wav",
    "gsrc/weapons/ric5.wav",
    "gsrc/weapons/ric_conc-1.wav",
    "gsrc/weapons/ric_conc-2.wav"
}

-- Sounds played on headshot
local headshotSounds = {
    "gsrc/player/headshot1.wav",
    "gsrc/player/headshot2.wav",
    "gsrc/player/headshot3.wav"
}
  

local function BulletCallBack(player, tr, dmginfo, toCall)
    local hitEnt = tr.Entity

    local bodyHit = false

    if (hitEnt != nil) then
        bodyHit = hitEnt:IsNPC() or hitEnt:IsPlayer()
    end

    net.Start("GoldSrcBulletImpact")
    net.WriteBool(bodyHit)
    net.WriteVector(tr.HitPos)
    net.Broadcast()

    if (cvarRicochet:GetBool() and !bodyHit and math.random() > 0.6) then
        local choice = sounds[math.random(#sounds)]

        sound.Play(choice, tr.HitPos, 70, 100, 1)
    end

    if (toCall != nil) then return toCall(player, tr, dmginfo) end
end

hook.Add( "EntityFireBullets", "GoldSrcChangeBullets", function(shooter, data)

    local toCall = data.Callback

    data.Callback = function(player, tr, dmginfo)
        return BulletCallBack(player, tr, dmginfo, toCall)
    end

    return true
end)

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
