-- Mannoroth Arena Boss script by Manmadedrummer For Araxia Online

local BOSS_MANNOROTH = 700829
local MAX_HEALTH = 2194018
local SPELL_MARK_OF_DOOM = 71124
local SPELL_SHADOW_BOLT_VOLLEY = 56065
local SPELL_GLAIVE_THRUST = 67448
local SPELL_MASSIVE_BLAST = 71106
local SPELL_PUNCTURE_WOUND = 70279
local SPELL_FEL_HELLSTORM = 66965
local SPELL_FELSEEKER = 67047
local SPELL_WRATH_OF_GULDAN = 7068
local SPELL_GRIPPING_SHADOWS = 36986
local NPC_DOOM_LORD = 101104
local NPC_FEL_IMP = 21135
local currentPhase = 1
local summonCooldown = {false, false}
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local QUOTE_START = "The Legion will burn this world, as it has countless others!"
local QUOTE_PHASE2 = "These mortals cannot be this strong. Gul'dan, do something!"
local QUOTE_DEATH = "Wha- What is this? Gul'dan what have you done? I am... So weak..."
local QUOTE_SPAWN = "Die, mongrels."

local function PhaseOneSpells(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(1) then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {SPELL_MARK_OF_DOOM, SPELL_SHADOW_BOLT_VOLLEY, SPELL_GLAIVE_THRUST, SPELL_PUNCTURE_WOUND, SPELL_MASSIVE_BLAST, SPELL_FEL_HELLSTORM, SPELL_FELSEEKER}
    local spell = spellList[math.random(1, #spellList)]
    creature:CastSpell(target, spell, true)
end

local function PhaseTwoSpells(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(1) then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {
        SPELL_MARK_OF_DOOM, SPELL_SHADOW_BOLT_VOLLEY, SPELL_GLAIVE_THRUST, SPELL_PUNCTURE_WOUND,
        SPELL_MASSIVE_BLAST, SPELL_FEL_HELLSTORM, SPELL_FELSEEKER, SPELL_WRATH_OF_GULDAN, SPELL_GRIPPING_SHADOWS
    }
    local spell = spellList[math.random(1, #spellList)]
    creature:CastSpell(target, spell, true)
end

local function SummonDoomLords(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 3 do
        creature:SpawnCreature(NPC_DOOM_LORD, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function SummonFelImps(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if not target then return end
    local x, y, z = target:GetLocation()
    for i = 1, 3 do
        creature:SpawnCreature(NPC_FEL_IMP, x + math.random(-10, 10), y + math.random(-10, 10), z, 0, 1, 5000)
    end
end

local function Phase1(creature)
    creature:SendUnitYell(QUOTE_SPAWN, 0)
    creature:RegisterEvent(PhaseOneSpells, 3000, 0)
    SummonDoomLords(creature)
    creature:RegisterEvent(SummonFelImps, 10000, 0)
end

local function Phase2(creature)
    creature:SendUnitYell(QUOTE_PHASE2, 0)
    creature:RemoveEvents()
    creature:RegisterEvent(PhaseTwoSpells, 1000, 0)
end

local function CheckHealth(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(1) then return end
    if creature:HealthBelowPct(65) and currentPhase < 2 then
        currentPhase = 2
        Phase2(creature)
    end
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

local function OnEnterCombat(event, creature, target)
    currentPhase = 1
    creature:SendUnitYell(QUOTE_START, 0)
    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 500, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell(QUOTE_DEATH, 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(50)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_MANNOROTH, 5, OnSpawn)
RegisterCreatureEvent(BOSS_MANNOROTH, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_MANNOROTH, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_MANNOROTH, 4, OnDeath)