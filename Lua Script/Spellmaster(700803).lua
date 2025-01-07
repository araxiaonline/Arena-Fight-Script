--Spellmaster by Milation 
--Converted to Azerothcore Araxia Online by Manmadedrummer
local BOSS_ID = 700803
local MIN_INTERVAL = 4000
local MAX_INTERVAL = 12000

local function RandomInterval(min, max)
    return math.random(min, max)
end

local PHASE_2_HEALTH = 40
local PHASE_3_HEALTH = 10

local function CastFireball(event, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), 42833, true)
    creature:SendUnitYell("Feel the heat of my Fireball!", 0)
    creature:RegisterEvent(CastFireball, RandomInterval(8000, 12000), 1)
end

local function CastBlastWave(event, delay, calls, creature)
    creature:CastSpell(creature, 36278, true)
    creature:SendUnitYell("You cannot escape the blast!", 0)
    creature:RegisterEvent(CastBlastWave, RandomInterval(10000, 15000), 1)
end

local function CastDivinePlea(event, delay, calls, creature)
    creature:CastSpell(creature, 54428, true)
    creature:SendUnitYell("I shall heal myself!", 0)
    creature:RegisterEvent(CastDivinePlea, RandomInterval(15000, 20000), 1)
end

local function CastArcaneExplosion(event, delay, calls, creature)
    creature:CastSpell(creature, 28450, true)
    creature:SendUnitYell("Witness the power of arcane destruction!", 0)
    creature:RegisterEvent(CastArcaneExplosion, RandomInterval(10000, 15000), 1)
end

local function CastArcaneBarrage(event, delay, calls, creature)
    local target = creature:GetAITarget(math.random(1, 5))
    creature:CastSpell(target, 59248, true)
    creature:SendUnitYell("You cannot avoid my arcane wrath!", 0)
    creature:RegisterEvent(CastArcaneBarrage, RandomInterval(7000, 10000), 1)
end

local function StartPhase1(creature)
    creature:RegisterEvent(CastFireball, RandomInterval(8000, 12000), 1)
    creature:RegisterEvent(CastBlastWave, RandomInterval(10000, 15000), 1)
    creature:RegisterEvent(CastDivinePlea, RandomInterval(15000, 20000), 1)
end

local function StartPhase2(event, delay, calls, creature)
    creature:RemoveEvents()
    creature:RegisterEvent(CastArcaneExplosion, RandomInterval(10000, 15000), 1)
    creature:RegisterEvent(CastDivinePlea, RandomInterval(15000, 20000), 1)
    creature:SendUnitYell("Now you shall feel the true power of the arcane!", 0)
end

local function StartPhase3(event, delay, calls, creature)
    creature:RemoveEvents()
    creature:RegisterEvent(CastArcaneBarrage, RandomInterval(7000, 10000), 1)
    creature:RegisterEvent(CastDivinePlea, RandomInterval(15000, 20000), 1)
    creature:SendUnitYell("This is my final stand. You shall not survive!", 0)
end

local function CheckHealth(event, delay, calls, creature)
    local healthPct = creature:GetHealthPct()
    if healthPct <= PHASE_2_HEALTH and healthPct > PHASE_3_HEALTH then
        StartPhase2(event, delay, calls, creature)
    elseif healthPct <= PHASE_3_HEALTH then
        StartPhase3(event, delay, calls, creature)
    end
end

local function OnCombatStart(event, creature, target)
    creature:SendUnitYell("You dare challenge me? Prepare to meet your end!", 0)
    StartPhase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("No... I can't be defeated...!", 0)
    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_ID, 1, OnCombatStart)
RegisterCreatureEvent(BOSS_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_ID, 4, OnDeath)
