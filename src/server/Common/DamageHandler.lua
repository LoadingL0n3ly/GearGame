local class = {}

function class.DamageDoneToPlayer(Attacker: Player, Victim: Player, DamageDealt: number, ToolId: number)
    print(Attacker.Name .. " used tool id " .. ToolId .. " to do " .. DamageDealt .. "pts of damage to " .. Victim.Name)
end

return class