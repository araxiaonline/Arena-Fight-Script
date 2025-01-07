--Hellscream Arena Boss script by Manmadedrummer for Araxia Online


local BOSS_HELLSCREAM = 700820
local SUMMON_NPC_1 = 23235
local SUMMON_NPC_2 = 16877
local MAX_HEALTH = 1032152

local DESECRATE = 36473
local ENRAGE = 72148
local WHIRLING_CORRUPTION = 59824
local TOUCH_OF_YSHAARJ = 37727
local SHADOW_SHOCK = 54889
local GRIPPING_DESPAIR = 72428
local SHADOW_NOVA = 71106
local AURAL_SHOCK = 14538
local UNHOLY_AURA = 17467
local CORRUPT_DEVOTION_AURA = 38603

local deathQuotes = {
    "No... It cannot end... like this... What I... What I have seen...",
    "No... NO... This world... Is my destiny... My destiny..."
}

local phaseTwoQuote = "Your strength is impressive... but it will not be enough!"
local phaseThreeQuote = "Enough games... Now, you will see my true power!"
local combatStartQuote = "For the Horde! Your time ends here!"

local PHASE_ONE = 1
local PHASE_TWO = 2
local PHASE_THREE = 3
local currentPhase = PHASE_ONE

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404
local MAP_ID = 1

local function SetBossHealth(creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

local function SummonNPCsOnce(creature)
    if not creature then return end

    local x, y, z = creature:GetLocation()
    creature:SpawnCreature(SUMMON_NPC_1, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 2, 60000)
    creature:SendUnitYell("For the True Horde!", 0)

    creature:SpawnCreature(SUMMON_NPC_2, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 2, 60000)
    creature:SendUnitYell("Blood and Thunder!", 0)
end

local function CastRandomPhaseSpell(eventId, delay, calls, creature)
    if not creature then return end

    local target = creature:GetAITarget(0)
    if not target then return end

    local spellList = {}
    if currentPhase >= PHASE_ONE then
        table.insert(spellList, DESECRATE)
        table.insert(spellList, ENRAGE)
    end
    if currentPhase >= PHASE_TWO then
        table.insert(spellList, WHIRLING_CORRUPTION)
        table.insert(spellList, TOUCH_OF_YSHAARJ)
        table.insert(spellList, SHADOW_SHOCK)
        table.insert(spellList, GRIPPING_DESPAIR)
    end
    if currentPhase >= PHASE_THREE then
        table.insert(spellList, SHADOW_NOVA)
        table.insert(spellList, AURAL_SHOCK)
        table.insert(spellList, UNHOLY_AURA)
        table.insert(spellList, CORRUPT_DEVOTION_AURA)
    end

    local spell = spellList[math.random(1, #spellList)]
    if spell == ENRAGE then
        creature:CastSpell(creature, ENRAGE, true)
    else
        creature:CastSpell(target, spell, true)
    end
end

local function CheckPhaseChange(eventId, delay, calls, creature)
    if not creature then return end

    local healthPct = creature:GetHealthPct()
    if healthPct <= 70 and currentPhase < PHASE_TWO then
        currentPhase = PHASE_TWO
        creature:SendUnitYell(phaseTwoQuote, 0)
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomPhaseSpell, 4000, 0)
    elseif healthPct <= 10 and currentPhase < PHASE_THREE then
        currentPhase = PHASE_THREE
        creature:SendUnitYell(phaseThreeQuote, 0)
        creature:RegisterEvent(CastRandomPhaseSpell, 2000, 0)
    end
end

local function OnEnterCombat(event, creature, target)
    currentPhase = PHASE_ONE
    SetBossHealth(creature)
    creature:SendUnitYell(combatStartQuote, 0)

    SummonNPCsOnce(creature)
    creature:RegisterEvent(CastRandomPhaseSpell, 3000, 0)
    creature:RegisterEvent(CheckPhaseChange, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    local quote = deathQuotes[math.random(1, #deathQuotes)]
    creature:SendUnitYell(quote, 0)

    local players = creature:GetPlayersInRange(10)
    if players then
        for _, player in ipairs(players) do
            player:Teleport(MAP_ID, teleportX, teleportY, teleportZ, teleportOrientation)
        end
    end

    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_HELLSCREAM, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_HELLSCREAM, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_HELLSCREAM, 4, OnDeath)
