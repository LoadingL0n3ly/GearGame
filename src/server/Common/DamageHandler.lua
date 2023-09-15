local class = {}

function class.DamageDoneToHumanoid(Attacker: Player, Victim: Humanoid, DamageDealt: number, ToolId: number)
    if Victim:HasTag("Killed") then return end
    warn(Attacker.Name .. " used tool id " .. ToolId .. " to do " .. DamageDealt .. "pts of damage to " .. Victim.Name)
    
    if Victim.Health == 0 then 
        Victim:AddTag("Killed")
        print("Killed!") 
    end
end

return class