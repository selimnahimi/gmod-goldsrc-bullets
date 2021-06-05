game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact")
PrecacheParticleSystem( "goldsrc_cs16_impact")
PrecacheParticleSystem( "goldsrc_blood_impact")

local cvarMode = CreateClientConVar( "gsrc_bullets_mode", "hl1", true, false)
local cvarParticlesImpact = CreateClientConVar("gsrc_bullets_particles_impact", "1", true, false)
local cvarParticlesBlood  = CreateClientConVar("gsrc_bullets_particles_blood", "1", true, false)


net.Receive("GoldSrcBulletImpact", function()
    local bodyHit = net.ReadBool()
    local hitPos = net.ReadVector()
    local mode = cvarMode:GetString()

    if (cvarParticlesBlood:GetBool() and bodyHit) then
        ParticleEffect("goldsrc_blood_impact", hitPos, Angle( 0, 0, 0 ))
    elseif (cvarParticlesImpact:GetBool() and !bodyHit) then
        if (mode == "hl1") then
            ParticleEffect("goldsrc_impact", hitPos, Angle( 0, 0, 0 ))
        else
            ParticleEffect("goldsrc_cs16_impact", hitPos, Angle( 0, 0, 0 ))
        end
    end
end)