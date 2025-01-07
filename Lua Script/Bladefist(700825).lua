-- Kargath Bladefist Arena Boss made by Manmadedrummer for Araxia Online

local BOSS_KARGATH = 700825
local MAX_HEALTH = 3047017
local SPELL_IMPALE = 67479
local SPELL_BLADE_DANCE = 30739
local SPELL_BERSERKER_RUSH = 56107
local SPELL_CHAIN_HURL = 55240
local SPELL_IMPALING_THROW = 30932
local NPC_IRON_BOMBER = 33695
local NPC_BILESLINGER = 17461
local NPC_IRON_GRUNT = 22973
local SPELL_IRON_BOMB = 43754
local SPELL_VILE_BREATH = 24818
local SPELL_FIRE_PILLAR = 67760
local SPELL_FLAME_JET = 64988
local PHASE_ONE_END = 70
local PHASE_TWO_END = 30
local QUOTE_PHASE_ONE = "Enough! I will show these weaklings what a true champion is capable of."
local QUOTE_PHASE_TWO = "The pleasure is mine. The crowd deserves a superior gladiator, seeing as the last one fell so easily."
local QUOTE_PHASE_THREE = "You owe me a fight, cowards."
local DEATH_QUOTE = "And that's... one hundred."
local currentPhase = 1

local function PhaseOneSpells(eventId, delay, pCall, creature)
    local phase1Spells = {SPELL_IMPALE, SPELL_BLADE_DANCE, SPELL_BERSERKER_RUSH, SPELL_CHAIN_HURL}
    creature:CastSpell(creature:GetVictim(), phase1Spells[math.random(#phase1Spells)], true)
end

local function SummonIronBombers(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 3 do
        creature:SpawnCreature(NPC_IRON_BOMBER, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function SummonBileslingers(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 2 do
        creature:SpawnCreature(NPC_BILESLINGER, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function SummonIronGrunts(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 4 do
        creature:SpawnCreature(NPC_IRON_GRUNT, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function PhaseTwoSpells(eventId, delay, pCall, creature)
    local phase2Spells = {SPELL_IRON_BOMB, SPELL_VILE_BREATH, SPELL_BERSERKER_RUSH, SPELL_CHAIN_HURL, SPELL_IMPALING_THROW}
    creature:CastSpell(creature:GetVictim(), phase2Spells[math.random(#phase2Spells)], true)
end

local function SummonPhaseTwoCreatures(creature)
    SummonIronBombers(creature)
    SummonBileslingers(creature)
    SummonIronGrunts(creature)
end

local function PhaseThreeSpells(eventId, delay, pCall, creature)
    local phase3Spells = {SPELL_FIRE_PILLAR, SPELL_FLAME_JET, SPELL_BERSERKER_RUSH, SPELL_CHAIN_HURL, SPELL_IMPALING_THROW}
    creature:CastSpell(creature:GetVictim(), phase3Spells[math.random(#phase3Spells)], true)
end

local function CheckHealth(eventId, delay, pCall, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end
    local healthPct = creature:GetHealthPct()
    if healthPct <= PHASE_ONE_END and currentPhase == 1 then
        currentPhase = 2
        creature:SendUnitYell(QUOTE_PHASE_TWO, 0)
        creature:RemoveEvents()
        SummonPhaseTwoCreatures(creature)
        creature:RegisterEvent(PhaseTwoSpells, 6000, 0)
    elseif healthPct <= PHASE_TWO_END and currentPhase == 2 then
        currentPhase = 3
        creature:SendUnitYell(QUOTE_PHASE_THREE, 0)
        creature:RemoveEvents()
        creature:RegisterEvent(PhaseThreeSpells, 5000, 0)
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
end

local function OnDeath(event, creature, killer)
    creature:SendUnitSay(DEATH_QUOTE, 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

RegisterCreatureEvent(BOSS_KARGATH, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_KARGATH, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_KARGATH, 4, OnDeath)
