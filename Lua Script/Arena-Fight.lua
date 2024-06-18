--[[
Custom Arena Fighting Teleport NPC for Araxia - by Manmadedrummer
THis script is to a set area and spawns a custom boss to fight.
]]

-- Variables
local NPC_ID = 800799
local ZoneID = 33
local X = -13200.41
local Y = 279.175
local Z = 21.857
local O = 1.18
local Faction = 14 -- Hostile faction for both Alliance and Horde
local Duration = 600000 -- 10 minutes, adjust as needed
local ParticipationCost = 10000 -- How much gold it cost

-- On Triggers
function ArenaFightingGossipOnTalk(Unit, Event, player)
    Unit:GossipCreateMenu(100, player, 0)
    Unit:GossipMenuAddItem(0, "I want to fight Patchwerk (Level 83)", 1, 0)
    Unit:GossipMenuAddItem(0, "I'd like to fight Festergut! (Level 83)", 2, 0)
    Unit:GossipMenuAddItem(0, "I'd like to fight Lord Jaraxxus! (Level 83)", 3, 0)
    Unit:GossipMenuAddItem(0, "I'd like to fight Deathbringer Saurfang! (Level 83)", 4, 0)
    Unit:GossipMenuAddItem(0, "Maybe next time.", 500, 0)
    Unit:GossipSendMenu(player)
end

function ArenaFightingGossipOnSelect(Unit, Event, player, id, intid, code, pMisc)
    if (intid == 500) then
        player:GossipComplete()
        return
    end

    if player:GetCoinage() < ParticipationCost then
        player:SendBroadcastMessage("You do not have enough gold to participate.")
        player:GossipComplete()
        return
    end

    player:ModifyMoney(-ParticipationCost)
    player:SendBroadcastMessage("You're being teleported to the ring, get ready to fight!")

    if (intid == 1) then
        player:Teleport(ZoneID, X, Y, Z, O)
        Unit:SpawnCreature(16028, X, Y, Z, O, Faction, Duration)
    elseif (intid == 2) then
        player:Teleport(ZoneID, X, Y, Z, O)
        Unit:SpawnCreature(36626, X, Y, Z, O, Faction, Duration)
    elseif (intid == 3) then
        player:Teleport(ZoneID, X, Y, Z, O)
        Unit:SpawnCreature(34780, X, Y, Z, O, Faction, Duration)
    elseif (intid == 4) then
        player:Teleport(ZoneID, X, Y, Z, O)
        Unit:SpawnCreature(37813, X, Y, Z, O, Faction, Duration)
    end

    player:GossipComplete()
end

RegisterUnitGossipEvent(2555, 1, "ArenaFightingGossipOnTalk")
RegisterUnitGossipEvent(2555, 2, "ArenaFightingGossipOnSelect")

