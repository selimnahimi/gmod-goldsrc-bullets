game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact")


net.Receive("GoldSrcBulletImpact", function()
    local hitPos = net.ReadVector()
    ParticleEffect("goldsrc_impact", hitPos, Angle( 0, 0, 0 ))
end)