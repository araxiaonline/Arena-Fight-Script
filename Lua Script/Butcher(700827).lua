-- Butcher Arena Boss made by Manmadedrummer for Araxia Online

local BOSS_BUTCHER = 700827
local MAX_HEALTH = 2958269
local SPELL_HEAVY_HANDED = 19818
local SPELL_THE_CLEAVER = 72494
local SPELL_THE_TENDERIZER = 37596
local SPELL_MEAT_HOOK = 29158
local SPELL_CLEAVE = 58131
local SPELL_BOUNDING_CLEAVE = 35473
local SPELL_GUSHING_WOUNDS = 39215
local SPELL_FRENZY = 500098
local NPC_EXPLODING_CADAVER = 37934

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastRandomSpell(eventId, delay, repeats, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {SPELL_HEAVY_HANDED, SPELL_THE_CLEAVER, SPELL_THE_TENDERIZER, SPELL_MEAT_HOOK, SPELL_CLEAVE, SPELL_BOUNDING_CLEAVE, SPELL_GUSHING_WOUNDS}
    local spell = spellList[math.random(1, #spellList)]
    creature:CastSpell(target, spell, true)
    if spell == SPELL_BOUNDING_CLEAVE then
        creature:SendUnitYell("Get the blood flowing!", 0)
    elseif spell == SPELL_FRENZY then
        creature:SendUnitYell("Time for the meat grinder!", 0)
    elseif spell == SPELL_CLEAVE then
        creature:SendUnitYell("Just a slice off the top.", 0)
    end
end

local function SummonExplodingCadavers(eventId, delay, repeats, creature)
    local x, y, z = creature:GetLocation()
    creature:SpawnCreature(NPC_EXPLODING_CADAVER, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 1, 60000)
end

local function Phase1(creature)
    creature:RegisterEvent(CastRandomSpell, 3000, 0)
end

local function Phase2(creature)
    creature:SendUnitYell("Time for the meat grinder!", 0)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpell, 1000, 0)
    creature:CastSpell(creature, SPELL_FRENZY, true)
    creature:RegisterEvent(SummonExplodingCadavers, 5000, 0)
end

local function CheckHealth(eventId, delay, repeats, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end
    local healthPct = creature:GetHealthPct()
    if healthPct <= 30 and currentPhase < 2 then
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
    creature:SendUnitYell("Come and get it!", 0)
    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("Gonna make a Pale stew.", 0)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
    local cadavers = creature:GetCreaturesInRange(50, NPC_EXPLODING_CADAVER)
    for _, cadaver in ipairs(cadavers) do
        cadaver:DespawnOrUnsummon()
    end
    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_BUTCHER, 5, OnSpawn)
RegisterCreatureEvent(BOSS_BUTCHER, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_BUTCHER, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_BUTCHER, 4, OnDeath)
