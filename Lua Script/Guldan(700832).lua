-- Gul'dan Arena Boss Script by Manmadedrummer for Araxia Online

local Guldan = 700832
local Lord = 1848
local Inquisitor = 25720

local PHASE_ONE = 1
local PHASE_TWO = 2
local PHASE_THREE = 3

local currentPhase = PHASE_ONE

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local spells = {
    28884, -- Hand of Gul'dan
    64675, -- Shatter Essence
    75954, -- Dark Blast
    7121,  -- Scattering Field
    500095, -- Liquid Hellfire
    39132, -- Fel Efflux
    22745, -- Bonds of Fel
    40876, -- Eye of Gul'dan
    52461, -- Unstoppable Rage
    72006, -- Shadow Cleave
    60010, -- Storm of the Destroyer
    32862, -- Well of Souls
    9373,  -- Soul Siphon
    25805, -- Soul Corrosion
    70388, -- Black Harvest
    19698, -- Flames of Sargeras
    67876, -- Desolate Ground
    48193  -- Fury of The Fel
}

local function CastRandomSpell(eventId, delay, calls, creature)
    local spellId = spells[math.random(#spells)]
    creature:CastSpell(creature:GetVictim(), spellId, true)
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Prepare yourself, our enemies' suffering shall soon commence.", 0)
    creature:RegisterEvent(CastRandomSpell, 8000, 0)
end

local function CheckHealth(event, creature)
    local healthPct = creature:GetHealthPct()
    if healthPct <= 85 and currentPhase == PHASE_ONE then
        currentPhase = PHASE_TWO
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomSpell, 5000, 0)
        local lordSpawn = creature:SpawnCreature(Lord, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
        local inquisitorSpawn = creature:SpawnCreature(Inquisitor, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
        if lordSpawn then
            lordSpawn:SetFaction(16) -- Set Lord's faction to hostile
        end
        if inquisitorSpawn then
            inquisitorSpawn:SetFaction(16) -- Set Inquisitor's faction to hostile
        end
    elseif healthPct <= 55 and currentPhase == PHASE_TWO then
        currentPhase = PHASE_THREE
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomSpell, 3000, 0)
    end
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDied(event, creature, killer)
    creature:SendUnitYell("Do not concern yourself, my fate is beyond your feeble grasp.", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

local function OnSpawn(event, creature)
    currentPhase = PHASE_ONE
    creature:SetMaxHealth(3486231)
    creature:SetHealth(3486231)
end

RegisterCreatureEvent(Guldan, 1, OnEnterCombat)
RegisterCreatureEvent(Guldan, 9, CheckHealth)
RegisterCreatureEvent(Guldan, 2, OnLeaveCombat)
RegisterCreatureEvent(Guldan, 4, OnDied)
RegisterCreatureEvent(Guldan, 5, OnSpawn)
