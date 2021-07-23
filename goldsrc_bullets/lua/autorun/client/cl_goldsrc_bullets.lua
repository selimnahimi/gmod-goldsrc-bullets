local cvarMode = CreateClientConVar( "gsrc_bullets_mode", "cs16", true, false)
local cvarParticlesImpact = CreateClientConVar("gsrc_bullets_particles_impact", "1", true, false)
local cvarParticlesBlood  = CreateClientConVar("gsrc_bullets_particles_blood", "1", true, false)

local BLOOD_RED = 0
local BLOOD_YELLOW = 1

local fleshColors = {}

fleshColors[MAT_FLESH] = BLOOD_RED
fleshColors[MAT_ALIENFLESH] = BLOOD_YELLOW
fleshColors[MAT_ANTLION] = BLOOD_YELLOW
fleshColors[MAT_EGGSHELL] = BLOOD_YELLOW

local function IsBodyHit(matType, bloodColor)
    if bloodColor == nil then
        return fleshColors[matType] != nil
    end
    
    local lookingFor = fleshColors[matType] or false
    return lookingFor == bloodColor
end

function GoldSrcDoImpactParticle(hitPos, matType, hitEnt, mode)
    if IsBodyHit(matType) then
        if not cvarParticlesBlood:GetBool() then return end

        local zombie = false
        local headcrab = false
        if hitEnt:IsValid() then
            zombie = string.match(hitEnt:GetClass(), ".*zombin?e.*") != nil
            headcrab = string.match(hitEnt:GetClass(), ".*headcrab.*") != nil
        end

        if zombie or headcrab or IsBodyHit(matType, BLOOD_YELLOW) then
            ParticleEffect("goldsrc_blood_impact_alien", hitPos, Angle( 0, 0, 0 ))
        elseif IsBodyHit(matType, BLOOD_RED) then
            ParticleEffect("goldsrc_blood_impact", hitPos, Angle( 0, 0, 0 ))
        end
    else
        if not cvarParticlesImpact:GetBool() then return end

        if (mode == "hl1") then
            ParticleEffect("goldsrc_impact", hitPos, Angle( 0, 0, 0 ))
        else
            ParticleEffect("goldsrc_cs16_impact", hitPos, Angle( 0, 0, 0 ))
        end
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
    GoldSrcPlayRicochet(hitPos, matType)
end)
