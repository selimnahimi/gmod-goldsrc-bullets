util.AddNetworkString("GoldSrcBulletImpact")

function HeadshotHook(ent, hitgroup, dmginfo)
    if GetConVar("gsrc_bullets_enabled"):GetBool() then
        if hitgroup == HITGROUP_HEAD and GetConVar("gsrc_bullets_headshot"):GetBool() then
            local neededArmor = GetConVar("gsrc_bullets_headshot_helmet"):GetInt()
            local onlyPlayers = GetConVar("gsrc_bullets_headshot_players"):GetBool()
            local choice
            
            if !ent:IsPlayer() and onlyPlayers then return end

            if ent:IsPlayer() and ent:Armor() >= neededArmor then
                choice = "GoldSrc.Impact.Helmet"
            else
                choice = "GoldSrc.Impact.Headshot"
            end

            ent:EmitSound(choice)
        end
    end
end

hook.Add( "ScalePlayerDamage", "GoldSrcHeadshotPlayer", HeadshotHook)
hook.Add( "ScaleNPCDamage", "GoldSrcHeadshotNPC", HeadshotHook)
