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
    else
        -- This is a bit finnicky:
        -- The reason as to why there's a separate clientside version of this,
        -- is to count with the possiblity of lag. Kind of like prediction, except less complicated.
        
        -- However for SOME reason, "EntityFireBullets" gets called a lot of times when you have a high ping.
        -- To avoid bullet particles and sounds being spammed, we store where each bullet landed at a very
        -- short time window (to count with something like a shotgun: multiple bullets can land at the same time),
        -- and if a bullet would hit the (approximately) same spot twice in this period, ignore it.

        local hitString = math.Round(tr.HitPos.x) .. " ".. math.Round(tr.HitPos.y) .. " " .. math.Round(tr.HitPos.z)
        local timePassed = CurTime() - lastParticleTime > 0.1

        if (timePassed || !lastParticlePosTable[hitString]) then
            GoldSrcDoImpactParticle(tr.HitPos, bodyHit, GetConVar("gsrc_bullets_mode"):GetString())
            GoldSrcPlayRicochet(tr.HitPos)
            
            lastParticlePosTable[hitString] = true

            if (timePassed) then
                -- lets empty the bullet table, because time has already passed
                lastParticleTime = CurTime()
                table.Empty(lastParticlePosTable)
            end
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
if SERVER then
    hook.Add( "EntityFireBullets", "SVGoldSrcBulletHook", GoldSrcBulletHook)
else
    hook.Add( "EntityFireBullets", "CLGoldSrcBulletHook", GoldSrcBulletHook)
end

