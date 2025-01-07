-- Gioran The Corrupted Paladin original script by k1ng01 https://www.mmopro.org/archive/index.php/t-3568.html
-- Converted to Azerothcore Araxia Online by Manmadedrummer

local BOSS_GIORAN = 700817
local NPC_SERVANT = 22965
local SPELL_DEATH_AND_DECAY = 60953
local SPELL_EMPOWERED_SHADOW_BOLT = 70281
local SPELL_CATACLYSMIC_BOLT = 38441
local SPELL_DEATHCHILL_BOLT = 72489
local SPELL_HOLY_BOLT = 57465
local SPELL_CURSE_OF_AGONY = 68138
local SPELL_LIFE_SIPHON = 73784
local SPELL_REPENTANCE = 29511
local SPELL_DEATH_PLAGUE = 72865
local SPELL_HOLY_BLAST = 59700
local SPELL_SHOCK_OF_SORROW = 59726
local SPELL_DIVINE_SWARM = 53385
local PHASE_1_HEALTH = 90
local PHASE_2_HEALTH = 75
local PHASE_3_HEALTH = 50
local PHASE_4_HEALTH = 25
local spawnedServants = {}

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastRandomSpell(creature)
    local spells = {
        SPELL_DEATH_AND_DECAY,
        SPELL_EMPOWERED_SHADOW_BOLT,
        SPELL_CATACLYSMIC_BOLT,
        SPELL_DEATHCHILL_BOLT,
        SPELL_HOLY_BOLT,
        SPELL_CURSE_OF_AGONY,
        SPELL_LIFE_SIPHON,
        SPELL_REPENTANCE,
        SPELL_DEATH_PLAGUE,
        SPELL_HOLY_BLAST,
        SPELL_SHOCK_OF_SORROW,
        SPELL_DIVINE_SWARM
    }
    local randomSpell = spells[math.random(1, #spells)]
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, randomSpell, true)
    end
end

local function CastSpellsPhase1(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastSpellsPhase1, math.random(10000, 20000), 1)
end

local function CastSpellsPhase2(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastSpellsPhase2, math.random(10000, 15000), 1)
end

local function CastSpellsPhase3(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastSpellsPhase3, math.random(10000, 12000), 1)
end

local function CastSpellsPhase4(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastSpellsPhase4, math.random(5000, 8000), 1)
end

local function SummonServants(creature)
    for i = 1, 2 do
        local x, y, z, o = creature:GetLocation()
        local servant = creature:SpawnCreature(NPC_SERVANT, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
        if servant then
            table.insert(spawnedServants, servant)
        end
    end
end

local function Phase1(creature)
    creature:SendUnitYell("So you mortals have chosen your own fate? Let us see about that!", 0)
    creature:RegisterEvent(CastSpellsPhase1, math.random(10000, 20000), 1)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("The world will fall upon you mortals!", 0)
    SummonServants(creature)
    creature:RegisterEvent(CastSpellsPhase2, math.random(10000, 15000), 1)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Your souls will be consumed by unholy power!", 0)
    SummonServants(creature)
    creature:RegisterEvent(CastSpellsPhase3, math.random(10000, 12000), 1)
end

local function Phase4(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Witness the true power of the void!", 0)
    creature:RegisterEvent(CastSpellsPhase4, math.random(5000, 8000), 1)
end

local function OnEnterCombat(event, creature, target)
    Phase1(creature)
    creature:RegisterEvent(function(eventId, delay, calls, creature)
        local healthPct = creature:GetHealthPct()
        if healthPct <= PHASE_2_HEALTH and healthPct > PHASE_3_HEALTH then
            Phase2(creature)
        elseif healthPct <= PHASE_3_HEALTH and healthPct > PHASE_4_HEALTH then
            Phase3(creature)
        elseif healthPct <= PHASE_4_HEALTH then
            Phase4(creature)
        end
    end, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("You have failed foolish one", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("Wait... this cannot be, it's not supposed to end this way!", 0)
    creature:RemoveEvents()
    for _, servant in ipairs(spawnedServants) do
        if servant then
            servant:DespawnOrUnsummon()
        end
    end
    spawnedServants = {}
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_GIORAN, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_GIORAN, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_GIORAN, 3, OnKilledTarget)
RegisterCreatureEvent(BOSS_GIORAN, 4, OnDeath)
