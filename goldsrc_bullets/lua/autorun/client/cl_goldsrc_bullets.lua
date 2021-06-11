game.AddParticles( "particles/goldsrc_impact.pcf" )
game.AddParticles( "particles/impact_fx.pcf" )
PrecacheParticleSystem( "goldsrc_impact")
PrecacheParticleSystem( "goldsrc_cs16_impact")
PrecacheParticleSystem( "goldsrc_blood_impact")
PrecacheParticleSystem("impact_concrete")
PrecacheParticleSystem("impact_metal")
PrecacheParticleSystem("impact_computer")
PrecacheParticleSystem("impact_grass")
PrecacheParticleSystem("impact_dirt")
PrecacheParticleSystem("impact_wood")
PrecacheParticleSystem("impact_glass")

local cvarMode = CreateClientConVar( "gsrc_bullets_mode", "cs16", true, false)
local cvarParticlesImpact = CreateClientConVar("gsrc_bullets_particles_impact", "1", true, false)
local cvarParticlesBlood  = CreateClientConVar("gsrc_bullets_particles_blood", "1", true, false)

local function IsBodyHit(matType)
    return matType == MAT_FLESH or matType == MAT_ALIENFLESH or matType == MAT_ANTLION or matType == MAT_EGGSHELL
end

function GoldSrcDoImpactParticle(hitPos, matType, hitEnt, mode)
    local bodyHit = IsBodyHit(matType)

    if bodyHit and cvarParticlesBlood:GetBool() then
        local zombie = false
        local headcrab = false
        if hitEnt:IsValid() then
            zombie = string.match(hitEnt:GetClass(), ".*zombin?e.*") != nil
            headcrab = string.match(hitEnt:GetClass(), ".*headcrab.*") != nil
        end

        if zombie or headcrab or matType == MAT_ALIENFLESH or matType == MAT_ANTLION or matType == MAT_EGGSHELL then
            ParticleEffect("goldsrc_blood_impact_alien", hitPos, Angle( 0, 0, 0 ))
        elseif matType == MAT_FLESH then
            ParticleEffect("goldsrc_blood_impact", hitPos, Angle( 0, 0, 0 ))
        end
    elseif !bodyHit and cvarParticlesImpact:GetBool() then
        if (mode == "hl1") then
            ParticleEffect("goldsrc_impact", hitPos, Angle( 0, 0, 0 ))
        else
            ParticleEffect("goldsrc_cs16_impact", hitPos, Angle( 0, 0, 0 ))
        end
    end

    if !bodyHit then
        GoldSrcPlayRicochet(hitPos)
    end
end

function GoldSrcPlayRicochet(pos, matType)
    local cvarRicochet = GetConVar("gsrc_bullets_ricochet"):GetBool()
    if IsBodyHit(matType) or !cvarRicochet then return end

    if (math.random() > 0.6) then
        local choice
        if (cvarMode:GetString() == "cs16") then
            choice = "GoldSrc.Impact.CS16"
        else
            choice = "GoldSrc.Impact.HL1"
        end

        sound.Play(choice, pos, 70, 100, 1)
    end
end


net.Receive("GoldSrcBulletImpact", function()
    local shooter = net.ReadEntity()
    if (shooter == LocalPlayer()) then return end

    local hitPos = net.ReadVector()
    local matType = net.ReadInt(8)
    local hitEnt = net.ReadEntity()
    local mode = cvarMode:GetString()

    GoldSrcDoImpactParticle(hitPos, matType, hitEnt, mode)
end)
