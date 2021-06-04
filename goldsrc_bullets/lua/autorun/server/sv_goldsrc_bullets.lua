util.AddNetworkString("GoldSrcBulletImpact")

game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact")

local sounds = {
    "gsrc/weapons/ric1.wav",
    "gsrc/weapons/ric2.wav",
    "gsrc/weapons/ric3.wav",
    "gsrc/weapons/ric4.wav",
    "gsrc/weapons/ric5.wav",
    "gsrc/weapons/ric_conc-1.wav",
    "gsrc/weapons/ric_conc-2.wav"
}

local function BulletCallBack(player, tr)
    local hitEnt = tr.Entity

    if (hitEnt != nil) then
        if (hitEnt:IsNPC() or hitEnt:IsPlayer()) then return end
    end

    if (math.random() > 0.6) then
        local choice = sounds[math.random(#sounds)]

        sound.Play(choice, tr.HitPos, 70, 100, 1)
    end

    net.Start("GoldSrcBulletImpact")
    net.WriteVector(tr.HitPos)
    net.Broadcast()
end

hook.Add( "EntityFireBullets", "GoldSrcChangeBullets", function(shooter, data)

    local toCall = data.Callback

    -- Ignore if there's already a callback bound
    if (toCall == nil) then
        data.Callback = BulletCallBack
    end

    return true
end)