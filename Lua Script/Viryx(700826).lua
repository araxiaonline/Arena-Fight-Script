-- High Sage Viryx Arena Boss made by Manmadedrummer for Araxia Online

local BOSS_VIRYX = 700826
local MAX_HEALTH = 390775
local SPELL_CAST_DOWN = 29522
local NPC_SOLAR_ZEALOT = 32228
local SPELL_LENS_FLARE = 29522
local SPELL_SOLAR_BURST = 67330
local SPELL_FIRE_SHIELD = 18968
local SPELL_DIVINE_SHIELD = 41367
local HEALTH_THRESHOLD_PHASE2 = 30
local HEALTH_SHIELD_75 = 75
local HEALTH_SHIELD_50 = 50
local HEALTH_SHIELD_25 = 25
local QUOTE_START = "Behold the might of the Arakkoa!"
local QUOTE_SUMMON = "Servants, protect your master!"
local QUOTE_LOW_HEALTH = "We will always... soar...."
local DEATH_QUOTE = "As long as we rule the skies you will always be beneath us!"
local currentPhase = 1
local shieldCasted75 = false
local shieldCasted50 = false
local shieldCasted25 = false

local function CastRandomSpell(eventId, delay, pCall, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {SPELL_LENS_FLARE, SPELL_SOLAR_BURST}
    local randomSpell = spellList[math.random(#spellList)]
    creature:CastSpell(target, randomSpell, true)
end

local function SummonSolarZealots(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 3 do
        creature:SpawnCreature(NPC_SOLAR_ZEALOT, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
    creature:SendUnitYell(QUOTE_SUMMON, 0)
end

local function CastShields(creature)
    creature:CastSpell(creature, SPELL_FIRE_SHIELD, true)
    creature:CastSpell(creature, SPELL_DIVINE_SHIELD, true)
    SummonSolarZealots(creature)
end

local function CheckHealth(eventId, delay, pCall, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end
    local healthPct = creature:GetHealthPct()
    if healthPct <= HEALTH_SHIELD_75 and not shieldCasted75 then
        shieldCasted75 = true
        CastShields(creature)
    end
    if healthPct <= HEALTH_SHIELD_50 and not shieldCasted50 then
        shieldCasted50 = true
        CastShields(creature)
    end
    if healthPct <= HEALTH_SHIELD_25 and not shieldCasted25 then
        shieldCasted25 = true
        CastShields(creature)
    end
    if healthPct <= HEALTH_THRESHOLD_PHASE2 and currentPhase == 1 then
        currentPhase = 2
        creature:SendUnitYell(QUOTE_LOW_HEALTH, 0)
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomSpell, 1000, 0)
    end
end

local function OnEnterCombat(event, creature, target)
    currentPhase = 1
    shieldCasted75 = false
    shieldCasted50 = false
    shieldCasted25 = false
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
    creature:SendUnitYell(QUOTE_START, 0)
    SummonSolarZealots(creature)
    creature:RegisterEvent(CastRandomSpell, 3000, 0)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell(DEATH_QUOTE, 0)
    local zealots = creature:GetCreaturesInRange(50, NPC_SOLAR_ZEALOT)
    for _, zealot in ipairs(zealots) do
        zealot:DespawnOrUnsummon()
    end
    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_VIRYX, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_VIRYX, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_VIRYX, 4, OnDeath)
