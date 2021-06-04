game.AddParticles( "particles/goldsrc_impact.pcf" )
PrecacheParticleSystem( "goldsrc_impact")


hook.Add("Think", "sdfdssdffdsfsd", function()
    --ParticleEffect("goldsrc_impact", LocalPlayer():GetPos(), LocalPlayer():EyeAngles())
end)