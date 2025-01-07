--General Pavalak script made by Manmadedrummer for Araxia Online

local NPC_ID = 700822
local REINFORCEMENT_ID = 29128

local MAX_HEALTH = 1850000

local SPELL_BLADE_RUSH = 75125
local SPELL_TEMPEST = 63557
local SPELL_BULWARK = 29382
local SPELL_SIEGE_EXPLOSIVE = 72802
local SPELL_THROW_EXPLOSIVE = 355057

local BULWARK_PHASES = {65, 35}
local CAST_TIME_REDUCTION_THRESHOLD = 35

local SPELL_CAST_MIN_DELAY = 2000 
local SPELL_CAST_MAX_DELAY = 6000 
local HALF_CAST_MIN_DELAY = SPELL_CAST_MIN_DELAY / 2
local HALF_CAST_MAX_DELAY = SPELL_CAST_MAX_DELAY / 2

local REINFORCEMENT_COUNT = 3

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local bossState = {
    bulwarkUsed = { [65] = false, [35] = false }
}

local function CastRandomSpell(eventId, delay, calls, creature)
    if creature:GetHealthPct() <= 0 then return end

    local spells = {SPELL_BLADE_RUSH, SPELL_TEMPEST, SPELL_SIEGE_EXPLOSIVE, SPELL_THROW_EXPLOSIVE}
    local spell = spells[math.random(1, #spells)]
    local target = creature:GetAITarget(0, true)
    if target then
        creature:CastSpell(target, spell, false)
    end
end

local function SummonReinforcements(creature)
    for i = 1, REINFORCEMENT_COUNT do
        local x, y, z = creature:GetX() + math.random(-5, 5), creature:GetY() + math.random(-5, 5), creature:GetZ()
        creature:SpawnCreature(REINFORCEMENT_ID, x, y, z, 0, 3, 60000)
    end
end

local function AdjustCastSpeed(creature)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpell, math.random(HALF_CAST_MIN_DELAY, HALF_CAST_MAX_DELAY), 0)
end

local function OnHealthCheck(eventId, delay, calls, creature)
    local healthPct = creature:GetHealthPct()

    for _, threshold in ipairs(BULWARK_PHASES) do
        if healthPct <= threshold and not bossState.bulwarkUsed[threshold] then
            creature:CastSpell(creature, SPELL_BULWARK, true)
            SummonReinforcements(creature)
            bossState.bulwarkUsed[threshold] = true

            if threshold == CAST_TIME_REDUCTION_THRESHOLD then
                AdjustCastSpeed(creature)
            end

            break
        end
    end
end

local function TeleportNearbyPlayers(creature)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(creature:GetMapId(), teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

local function OnCombat(event, creature, target)
    bossState.bulwarkUsed = { [65] = false, [35] = false }

    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)

    creature:RegisterEvent(CastRandomSpell, math.random(SPELL_CAST_MIN_DELAY, SPELL_CAST_MAX_DELAY), 0)
    creature:RegisterEvent(OnHealthCheck, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDied(event, creature, killer)
    TeleportNearbyPlayers(creature)
    creature:RemoveEvents()
end

RegisterCreatureEvent(NPC_ID, 1, OnCombat)
RegisterCreatureEvent(NPC_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(NPC_ID, 4, OnDied)
