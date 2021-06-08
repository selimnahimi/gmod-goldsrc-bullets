game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact")
PrecacheParticleSystem( "goldsrc_cs16_impact")
PrecacheParticleSystem( "goldsrc_blood_impact")

local cvarMode = CreateClientConVar( "gsrc_bullets_mode", "hl1", true, false)
local cvarParticlesImpact = CreateClientConVar("gsrc_bullets_particles_impact", "1", true, false)
local cvarParticlesBlood  = CreateClientConVar("gsrc_bullets_particles_blood", "1", true, false)

-- Ricochet sounds
local sounds_hl1 = {
    "gsrc/weapons/ric1.wav",
    "gsrc/weapons/ric2.wav",
    "gsrc/weapons/ric3.wav",
    "gsrc/weapons/ric4.wav",
    "gsrc/weapons/ric5.wav"
}

local sounds_cs16 = {
    "gsrc/weapons/ric1.wav",
    "gsrc/weapons/ric2.wav",
    "gsrc/weapons/ric3.wav",
    "gsrc/weapons/ric4.wav",
    "gsrc/weapons/ric5.wav",
    "gsrc/weapons/ric_conc-1.wav",
    "gsrc/weapons/ric_conc-2.wav"
}

function GoldSrcDoImpactParticle(hitPos, bodyHit, mode)
    if (cvarParticlesBlood:GetBool() and bodyHit) then
        ParticleEffect("goldsrc_blood_impact", hitPos, Angle( 0, 0, 0 ))
    elseif (cvarParticlesImpact:GetBool() and !bodyHit) then
        if (mode == "hl1") then
            ParticleEffect("goldsrc_impact", hitPos, Angle( 0, 0, 0 ))
        else
            ParticleEffect("goldsrc_cs16_impact", hitPos, Angle( 0, 0, 0 ))
        end
    end
end

function GoldSrcPlayRicochet(pos)
    local cvarRicochet = GetConVar("gsrc_bullets_ricochet"):GetBool()

    if (cvarRicochet and !bodyHit and math.random() > 0.6) then
        local pickFrom
        if (cvarMode:GetString() == "cs16") then
            pickFrom = sounds_cs16
        else
            pickFrom = sounds_hl1
        end

        local choice = pickFrom[math.random(#pickFrom)]

        sound.Play(choice, pos, 70, 100, 1)
    end
end


net.Receive("GoldSrcBulletImpact", function()
    local shooter = net.ReadEntity()
    if (shooter == LocalPlayer()) then return end

    local hitPos = net.ReadVector()
    local bodyHit = net.ReadBool()
    local mode = cvarMode:GetString()

    GoldSrcDoImpactParticle(hitPos, bodyHit, mode)
    
    if (!bodyHit) then GoldSrcPlayRicochet(hitPos) end
end)
