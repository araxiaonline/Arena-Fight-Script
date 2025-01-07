local BOSS_NPC_ID = 700818
local NPC_LIVING_AMBER = 1031
local NPC_AMBER_MONSTROSITY = 1033

local SPELL_AMBER_SCALPEL = 55362
local SPELL_PARASITIC_GROWTH = 32863
local SPELL_AMBER_STRIKE = 56730
local SPELL_CONCENTRATED_MUTATION = 54427
local SPELL_VOLATILE_AMBER = 70671
local SPELL_AMBER_EXPLOSION = 20476
local SPELL_MASSIVE_STOMP = 60925
local SPELL_FLING = 43665
local SPELL_AMBER_CARAPACE = 49222

local STAGE_2_HEALTH = 70
local STAGE_3_HEALTH = 30
local ENRAGE_HEALTH_THRESHOLD = 50000

local MAX_HP = 1635000

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local summonedCreatures = {}

local function CastRandomSpell(creature)
    local spells = {
        SPELL_AMBER_SCALPEL,
        SPELL_PARASITIC_GROWTH,
        SPELL_AMBER_STRIKE,
        SPELL_VOLATILE_AMBER
    }
    local randomSpell = spells[math.random(1, #spells)]
    local target = creature:GetAITarget(0)

    if target then
        creature:CastSpell(target, randomSpell, true)
    end
end

local function CastAmberExplosion(eventId, delay, calls, monstrosity)
    monstrosity:CastSpell(monstrosity, SPELL_AMBER_EXPLOSION, true)
end

local function CastMassiveStomp(eventId, delay, calls, monstrosity)
    monstrosity:CastSpell(monstrosity, SPELL_MASSIVE_STOMP, true)
end

local function CastFling(eventId, delay, calls, monstrosity)
    local target = monstrosity:GetAITarget(0)
    if target then
        monstrosity:CastSpell(target, SPELL_FLING, true)
    end
end

local function SummonAmberMonstrosity(eventId, delay, calls, creature)
    local x, y, z, o = creature:GetLocation()
    local monstrosity = creature:SpawnCreature(NPC_AMBER_MONSTROSITY, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
    if monstrosity then
        table.insert(summonedCreatures, monstrosity)
        monstrosity:RegisterEvent(CastAmberExplosion, 15000, 0)
        monstrosity:RegisterEvent(CastMassiveStomp, 20000, 0)
        monstrosity:RegisterEvent(CastFling, 25000, 0)
    end
end

local function CastPhase1Spells(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastPhase1Spells, math.random(5000, 10000), 1)
end

local function SummonLivingAmber(eventId, delay, calls, creature)
    for i = 1, 3 do
        local x, y, z, o = creature:GetLocation()
        local amber = creature:SpawnCreature(NPC_LIVING_AMBER, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
        if amber then
            table.insert(summonedCreatures, amber)
        end
    end
end

local function CastPhase2Spells(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastPhase2Spells, math.random(4000, 8000), 1)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("You must be powerful, to have come this far. Yes, yes... you will make worthy test subjects.", 0)
    creature:CastSpell(creature, SPELL_AMBER_CARAPACE, true)
    creature:RegisterEvent(SummonAmberMonstrosity, 15000, 1)
    creature:RegisterEvent(SummonLivingAmber, 15000, 1)
    creature:RegisterEvent(CastPhase2Spells, math.random(4000, 8000), 1)
end

local function CastPhase3Spells(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(CastPhase3Spells, math.random(3000, 6000), 1)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Feel the power of true corruption!", 0)
    creature:RemoveAura(SPELL_AMBER_CARAPACE)
    creature:CastSpell(creature, SPELL_CONCENTRATED_MUTATION, true)
    creature:RegisterEvent(CastPhase3Spells, math.random(3000, 6000), 1)
end

local function CheckEnrage(creature)
    if creature:GetHealth() <= ENRAGE_HEALTH_THRESHOLD then
        if not creature:HasAura(SPELL_CONCENTRATED_MUTATION) then
            creature:SendUnitYell("This isn't over yet! Witness my true power!", 0)
            creature:CastSpell(creature, SPELL_CONCENTRATED_MUTATION, true)
        end
    end
end

local function CheckHealthPhase(eventId, delay, calls, creature)
    local healthPct = creature:GetHealthPct()
    if healthPct <= STAGE_2_HEALTH and healthPct > STAGE_3_HEALTH then
        Phase2(creature)
    elseif healthPct <= STAGE_3_HEALTH then
        Phase3(creature)
    end

    CheckEnrage(creature)
end

local function OnEnterCombat(event, creature, target)
    creature:SetMaxHealth(MAX_HP)
    creature:SetHealth(MAX_HP)

    creature:SendUnitYell("Ah, I see you have found a few of my experiments. Step closer, and you may witness the full glory of my work here.", 0)
    creature:RegisterEvent(CastPhase1Spells, math.random(5000, 10000), 1)
    creature:RegisterEvent(CheckHealthPhase, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("Forgive me, Empress....", 0)
    creature:RemoveEvents()

    if killer:IsPlayer() then
        killer:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_NPC_ID, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_NPC_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_NPC_ID, 4, OnDeath)
