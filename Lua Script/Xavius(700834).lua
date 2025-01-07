-- Xavius Arena Boss script by Manmadedrummer for Araxia Online

local XAVIUS_NPC_ID = 700834
local PHASE_ONE = 1
local PHASE_TWO = 2
local PHASE_THREE = 3
local HEALTH_ON_SPAWN = 1193755
local PHASE_TWO_HEALTH = 65
local PHASE_THREE_HEALTH = 30

local SPELL_DARKENING_SOUL = 68156
local SPELL_NIGHTMARE_BLADES = 500075
local SPELL_CORRUPTING_NOVA = 40737
local SPELL_TORMENTING_SWIPE = 45150
local SPELL_BLACKENED_SOUL = 31293
local SPELL_BLACKENED_TAINTING = 68090
local SPELL_CORRUPTION_METEOR = 57467
local SPELL_BONDS_OF_TERROR = 65857
local SPELL_NIGHTMARE_INFUSION = 72448
local SPELL_DARK_RUINATION = 41445
local SPELL_TAINTED_DISCHARGE = 67876
local SPELL_NIGHTMARE_BOLT = 75384

local NPC_HARBINGER_OF_HORROR = 32278
local NPC_LURKING_TERROR = 18770
local NPC_PROTEAN_NIGHTMARE = 20864
local NPC_NIGHTMARE_TENTACLE = 16235

local currentPhase = PHASE_ONE
local npcSummonedInPhase = false

local function CastRandomSpellInPhase(eventId, delay, repeats, creature)
    local spellTable = {}
    if currentPhase == PHASE_ONE then
        spellTable = {SPELL_DARKENING_SOUL, SPELL_NIGHTMARE_BLADES, SPELL_CORRUPTING_NOVA, SPELL_TORMENTING_SWIPE}
    elseif currentPhase == PHASE_TWO then
        spellTable = {SPELL_BLACKENED_SOUL, SPELL_BLACKENED_TAINTING, SPELL_CORRUPTION_METEOR, SPELL_BONDS_OF_TERROR, SPELL_NIGHTMARE_INFUSION, SPELL_DARK_RUINATION, SPELL_TAINTED_DISCHARGE}
    elseif currentPhase == PHASE_THREE then
        spellTable = {SPELL_BLACKENED_SOUL, SPELL_NIGHTMARE_BLADES, SPELL_NIGHTMARE_INFUSION, SPELL_CORRUPTION_METEOR, SPELL_NIGHTMARE_BOLT}
    end
    local spellToCast = spellTable[math.random(1, #spellTable)]
    creature:CastSpell(creature:GetVictim(), spellToCast, false)
end

local function Phase1(creature)
    creature:RegisterEvent(CastRandomSpellInPhase, 6000, 0)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        creature:SpawnCreature(NPC_LURKING_TERROR, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
    end, 15000, 1)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        creature:SpawnCreature(NPC_HARBINGER_OF_HORROR, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
    end, 20000, 1)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("You will crumble beneath my power!", 0)
    for i = 1, 2 do
        creature:SpawnCreature(NPC_PROTEAN_NIGHTMARE, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
    end
    creature:RegisterEvent(CastRandomSpellInPhase, 4000, 0)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("My victory is absolute. The power of Nightmare grows!", 0)
    creature:SpawnCreature(NPC_NIGHTMARE_TENTACLE, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
    creature:RegisterEvent(CastRandomSpellInPhase, 2000, 0)
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(HEALTH_ON_SPAWN)
    creature:SetHealth(HEALTH_ON_SPAWN)
end

local function OnEnterCombat(event, creature)
    creature:SendUnitYell("Feel the devastation of the Nightmare!", 0)
    Phase1(creature)
end

local function OnHealthChange(event, creature, damage)
    local currentHealthPct = creature:GetHealthPct()
    if currentHealthPct < PHASE_TWO_HEALTH and currentPhase == PHASE_ONE then
        currentPhase = PHASE_TWO
        npcSummonedInPhase = false
        Phase2(creature)
    elseif currentHealthPct < PHASE_THREE_HEALTH and currentPhase == PHASE_TWO then
        currentPhase = PHASE_THREE
        npcSummonedInPhase = false
        Phase3(creature)
    end
end

local function DespawnSummons(creature, npcID)
    local summons = creature:GetCreaturesInRange(100, npcID)
    for _, summon in ipairs(summons) do
        summon:DespawnOrUnsummon()
    end
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("My work... left... unfinished...", 0)
    DespawnSummons(creature, NPC_HARBINGER_OF_HORROR)
    DespawnSummons(creature, NPC_LURKING_TERROR)
    DespawnSummons(creature, NPC_PROTEAN_NIGHTMARE)
    DespawnSummons(creature, NPC_NIGHTMARE_TENTACLE)
    local playersInRange = creature:GetPlayersInRange(100)
    for _, player in ipairs(playersInRange) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

local function OnKillPlayer(event, creature, victim)
    creature:SendUnitYell("Your souls are mine, woven for all time into the fabric of the Nightmare!", 0)
end

-- Added OnLeaveCombat function to despawn the boss upon leaving combat
local function OnLeaveCombat(event, creature)
    creature:SendUnitYell("You cannot escape the Nightmare forever...", 0)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

RegisterCreatureEvent(XAVIUS_NPC_ID, 5, OnSpawn)
RegisterCreatureEvent(XAVIUS_NPC_ID, 1, OnEnterCombat)
RegisterCreatureEvent(XAVIUS_NPC_ID, 9, OnHealthChange)
RegisterCreatureEvent(XAVIUS_NPC_ID, 4, OnDeath)
RegisterCreatureEvent(XAVIUS_NPC_ID, 3, OnKillPlayer)
RegisterCreatureEvent(XAVIUS_NPC_ID, 2, OnLeaveCombat)  -- Register OnLeaveCombat event
