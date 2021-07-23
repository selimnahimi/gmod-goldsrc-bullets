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
PrecacheParticleSystem("impact_antlion")

if game.SinglePlayer() then
    include("autorun/client/cl_goldsrc_bullets.lua")
end

local lastParticleTime = 0
local lastParticlePosTable = {}

CreateConVar("gsrc_bullets_ricochet", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc ricochet sounds")
CreateConVar("gsrc_bullets_headshot", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc headshot sounds")
CreateConVar("gsrc_bullets_headshot_players", "0", FCVAR_REPLICATE, "Only play headshot sounds for players")
CreateConVar("gsrc_bullets_headshot_helmet", "50", FCVAR_REPLICATE, "Minimum armor needed to play a helmet headshot sound")
CreateConVar("gsrc_bullets_enabled", "1", FCVAR_REPLICATE, "Enable/Disable the addon (doesn't disable impact materials!)")


-- Callback for the fired bullet (GM:EntityFireBullets)
function GoldSrcBulletCallback(player, tr, dmginfo, toCall)
    if GetConVar("gsrc_bullets_enabled"):GetBool() then
        if (toCall != nil) then toCall(player, tr, dmginfo) end

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
    end
end

-- Hook for fired bullets (GM:EntityFireBullets)
function GoldSrcBulletHook(shooter, bullet)
    if GetConVar("gsrc_bullets_enabled"):GetBool() then
        local toCall = bullet.Callback
        
        bullet.Callback = function(player, tr, dmginfo)
            -- This convoluted callback is needed, because some SWEPs have their own
            -- bullet callbacks, and overwriting them isn't a good idea. Instead,
            -- let's call our own, and once done, call the SWEP's own bullet callback
            GoldSrcBulletCallback(player, tr, dmginfo, toCall)
        end

        if IsValid(shooter) && shooter:IsNPC() && shooter.IsVJBaseSNPC == true then
            local ene = shooter:GetEnemy()
            local wep = shooter:GetActiveWeapon()

            local fSpread = (shooter:GetPos():Distance(ene:GetPos()) / 28) * shooter.WeaponSpread * (wep.NPC_CustomSpread or 1)
            bullet.Spread = Vector(fSpread, fSpread, 0)

            if shooter.WeaponUseEnemyEyePos == true then
                bullet.Dir = (ene:EyePos() + ene:GetUp()*-5) - bullet.Src
            else
                bullet.Dir = (ene:GetPos() + ene:OBBCenter()) -  bullet.Src
            end
        end

        --bullet.Callback = toCall

        return true
    end
end

-- Hooks
hook.Add( "EntityFireBullets", "GoldSrcBulletHook", GoldSrcBulletHook)
