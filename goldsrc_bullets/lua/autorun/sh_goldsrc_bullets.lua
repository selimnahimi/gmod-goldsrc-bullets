if game.SinglePlayer() then
    include("autorun/client/cl_goldsrc_bullets.lua")
end

local lastParticleTime = 0
local lastParticlePosTable = {}

-- Callback for the fired bullet (GM:EntityFireBullets)
function GoldSrcBulletCallback(player, tr, dmginfo, toCall)
    local hitEnt = tr.Entity

    local bodyHit = false

    -- If we hit a player, we need a different impact effect.
    if (hitEnt != nil) then
        bodyHit = hitEnt:IsNPC() or hitEnt:IsPlayer()
    end

    if SERVER then
        -- Dispatch a bullet hit effect for every client
        net.Start("GoldSrcBulletImpact")
        net.WriteEntity(player)
        net.WriteVector(tr.HitPos)
        net.WriteBool(bodyHit)
        net.Broadcast()
    end
    if CLIENT or game.SinglePlayer() then
        if (IsFirstTimePredicted()) then
            GoldSrcDoImpactParticle(tr.HitPos, bodyHit, GetConVar("gsrc_bullets_mode"):GetString())
            GoldSrcPlayRicochet(tr.HitPos)
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
