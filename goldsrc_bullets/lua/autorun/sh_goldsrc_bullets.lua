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

if game.SinglePlayer() then
    include("autorun/client/cl_goldsrc_bullets.lua")
end

local lastParticleTime = 0
local lastParticlePosTable = {}

CreateConVar("gsrc_bullets_ricochet", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc ricochet sounds")
CreateConVar("gsrc_bullets_headshot", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc headshot sounds")
CreateConVar("gsrc_bullets_headshot_players", "0", FCVAR_REPLICATE, "Only play headshot sounds for players")
CreateConVar("gsrc_bullets_headshot_helmet", "50", FCVAR_REPLICATE, "Minimum armor needed to play a helmet headshot sound")


-- Callback for the fired bullet (GM:EntityFireBullets)
function GoldSrcBulletCallback(player, tr, dmginfo, toCall)
    local hitEnt = tr.Entity

    local bodyHit = false

    if SERVER then
        -- Dispatch a bullet hit effect for every client
        net.Start("GoldSrcBulletImpact")
        net.WriteEntity(player)
        net.WriteVector(tr.HitPos)
        net.WriteInt(tr.MatType, 8)
        net.WriteEntity(tr.Entity)
        net.Broadcast()
    end
    if CLIENT or game.SinglePlayer() then
        if (IsFirstTimePredicted()) then
            GoldSrcDoImpactParticle(tr.HitPos, tr.MatType, tr.Entity, GetConVar("gsrc_bullets_mode"):GetString())
        end
    end

    if (toCall != nil) then return toCall(player, tr, dmginfo) end
end

-- Hook for fired bullets (GM:EntityFireBullets)
function GoldSrcBulletHook(shooter, data)

    local toCall = data.Callback

    data.Callback = function(player, tr, dmginfo)
        -- This convoluted callback is needed, because some SWEPs have their own
        -- bullet callbacks, and overwriting them isn't a good idea. Instead,
        -- let's call our own, and once done, call the SWEP's own bullet callback
        return GoldSrcBulletCallback(player, tr, dmginfo, toCall)
    end

    return true
end

-- Hooks
hook.Add( "EntityFireBullets", "GoldSrcBulletHook", GoldSrcBulletHook)
