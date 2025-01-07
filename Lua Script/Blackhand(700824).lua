-- Blackhand Arena boss made by Manmadedrummer for Araxia Online

local BOSS_BLACKHAND = 700824
local MAX_HEALTH = 1713499

local SPELL_MOLTEN_SLAG = 67637
local SPELL_DEMOLITION = 36099
local SPELL_MARKED_FOR_DEATH = 67882
local SPELL_IMPALING_THROW = 39837
local SPELL_THROW_SLAG_BOMBS = 19411
local SPELL_SHATTERED_SMASH = 69627

local NPC_SIEGEBREAKER = 17461
local SPELL_BLACKIRON_PLATING = 41196
local SPELL_MORTAR = 39695
local SPELL_OVERDRIVE = 18546
local SPELL_BATTERING_RAM = 62376
local SPELL_EXPLOSIVE_ROUND = 71126

local SPELL_SLAG_ERUPTION = 40117
local SPELL_MASSIVE_SHATTERING_SMASH = 67662

local PHASE_ONE_END = 70
local PHASE_TWO_END = 30

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404
local TELEPORT_MAP_ID = 1

local QUOTE_PHASE_ONE = "A small victory, but now you will perish in the flame that burns at the heart of Blackrock!"
local QUOTE_PHASE_TWO = "Bring in the siegemaker."
local QUOTE_PHASE_THREE = "Burn - you will all BURN!"
local QUOTE_SHATTERING_SMASH = "I'll bring this whole place down around your heads!"
local QUOTE_SUMMON_SIEGE = "Open the flumes! Flood the room with molten slag."
local DEATH_QUOTE = "This crucible is your molten grave!"

local currentPhase = 1

local function PhaseOneSpells(eventId, delay, pCall, creature)
    local phase1Spells = {SPELL_MOLTEN_SLAG, SPELL_DEMOLITION, SPELL_MARKED_FOR_DEATH, SPELL_THROW_SLAG_BOMBS, SPELL_SHATTERED_SMASH}
    creature:CastSpell(creature:GetVictim(), phase1Spells[math.random(#phase1Spells)], true)
end

local function PhaseTwoSpells(eventId, delay, pCall, creature)
    local phase2Spells = {SPELL_MORTAR, SPELL_BATTERING_RAM, SPELL_EXPLOSIVE_ROUND, SPELL_OVERDRIVE, SPELL_MARKED_FOR_DEATH, SPELL_THROW_SLAG_BOMBS, SPELL_SHATTERED_SMASH}
    creature:CastSpell(creature:GetVictim(), phase2Spells[math.random(#phase2Spells)], true)
end

local function PhaseThreeSpells(eventId, delay, pCall, creature)
    local phase3Spells = {SPELL_SLAG_ERUPTION, SPELL_MASSIVE_SHATTERING_SMASH, SPELL_MARKED_FOR_DEATH, SPELL_THROW_SLAG_BOMBS, SPELL_SHATTERED_SMASH}
    creature:CastSpell(creature:GetVictim(), phase3Spells[math.random(#phase3Spells)], true)
end

local function SummonSiegebreakers(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 2 do
        creature:SpawnCreature(NPC_SIEGEBREAKER, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
    creature:SendUnitYell(QUOTE_SUMMON_SIEGE, 0)
end

local function PhaseTwo(creature)
    creature:SendUnitYell(QUOTE_PHASE_TWO, 0)
    creature:RemoveEvents()
    SummonSiegebreakers(creature)
    creature:RegisterEvent(PhaseTwoSpells, 7000, 0)
end

local function PhaseThree(creature)
    creature:SendUnitYell(QUOTE_PHASE_THREE, 0)
    creature:RemoveEvents()
    creature:RegisterEvent(PhaseThreeSpells, 5000, 0)
end

local function CheckHealth(eventId, delay, pCall, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end

    local healthPct = creature:GetHealthPct()

    if healthPct <= PHASE_ONE_END and currentPhase == 1 then
        currentPhase = 2
        PhaseTwo(creature)
    elseif healthPct <= PHASE_TWO_END and currentPhase == 2 then
        currentPhase = 3
        PhaseThree(creature)
    end
end

local function OnEnterCombat(event, creature, target)
    currentPhase = 1
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)

    creature:SendUnitYell(QUOTE_PHASE_ONE, 0)

    creature:RegisterEvent(PhaseOneSpells, 5000, 0)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell(DEATH_QUOTE, 0)
    creature:RemoveEvents()

    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(TELEPORT_MAP_ID, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_BLACKHAND, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_BLACKHAND, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_BLACKHAND, 4, OnDeath)
