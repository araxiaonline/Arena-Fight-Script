-- Brackenspore Arena Boss by Manmadedrummer for Araxia Online

local BOSS_BRAKENSPORE = 700828
local MAX_HEALTH = 1198099
local SPELL_CREEPING_MOSS = 18289
local SPELL_ROT = 72966
local SPELL_NECROTIC_BREATH = 24818
local SPELL_INFESTING_SPORES1 = 59419
local SPELL_INFESTING_SPORES2 = 35394
local SPELL_CALL_OF_THE_TIDES = 67649
local SPELL_EXPLODING_FUNGUS = 8138
local SPELL_ENRAGE = 500098
local SPELL_AURA_OF_ROT = 25818
local NPC_FUNGAL_OOZE = 5235
local NPC_UNSTABLE_SHROOM = 20479
local currentPhase = 1
local thresholds = {75, 50, 30}
local oozeCooldown = {false, false, false}
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastRandomSpell(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(0) then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {SPELL_CREEPING_MOSS, SPELL_ROT, SPELL_NECROTIC_BREATH, SPELL_INFESTING_SPORES1, SPELL_INFESTING_SPORES2, SPELL_CALL_OF_THE_TIDES, SPELL_EXPLODING_FUNGUS}
    local spell = spellList[math.random(1, #spellList)]
    creature:CastSpell(target, spell, true)
end

local function SummonFungalOozes(creature)
    local x, y, z = creature:GetLocation()
    for i = 1, 3 do
        creature:SpawnCreature(NPC_FUNGAL_OOZE, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function SummonUnstableShrooms(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if not target then return end
    local x, y, z = target:GetLocation()
    creature:SpawnCreature(NPC_UNSTABLE_SHROOM, x + math.random(-10, 10), y + math.random(-10, 10), z, 0, 1, 5000)
end

local function Phase1(creature)
    creature:RegisterEvent(CastRandomSpell, 3000, 0)
end

local function Phase2(creature)
    creature:SendUnitYell("UWAGH!!!", 0)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpell, 1000, 0)
    creature:CastSpell(creature, SPELL_ENRAGE, true)
    creature:CastSpell(creature, SPELL_AURA_OF_ROT, true)
    creature:RegisterEvent(SummonUnstableShrooms, 5000, 0)
end

local function CheckHealth(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(0) then return end
    
    for i, threshold in ipairs(thresholds) do
        if creature:HealthBelowPct(threshold) and not oozeCooldown[i] then
            SummonFungalOozes(creature)
            oozeCooldown[i] = true
        end
    end
    
    if creature:HealthBelowPct(30) and currentPhase < 2 then
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
    oozeCooldown = {false, false, false}
    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("urghh...urgh", 0)
    local oozes = creature:GetCreaturesInRange(50, NPC_FUNGAL_OOZE)
    for _, ooze in ipairs(oozes) do
        ooze:DespawnOrUnsummon()
    end
    local shrooms = creature:GetCreaturesInRange(50, NPC_UNSTABLE_SHROOM)
    for _, shroom in ipairs(shrooms) do
        shroom:DespawnOrUnsummon()
    end
    local players = creature:GetPlayersInRange(50)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_BRAKENSPORE, 5, OnSpawn)
RegisterCreatureEvent(BOSS_BRAKENSPORE, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_BRAKENSPORE, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_BRAKENSPORE, 4, OnDeath)
