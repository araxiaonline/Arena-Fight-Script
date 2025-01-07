-- Original Script by Kreegoth at mmopro.org
-- Converted for Araxia Online on Azerothcore by Manmadedrummer https://github.com/araxiaonline

local ENEMY_ID = 700801
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local SPELL_ARCANE_EXPLOSION = 27082
local SPELL_MORTAL_STRIKE = 24573
local SPELL_SUNDER_ARMOR = 7386
local SPELL_SUMMON_INFERNAL = 1122
local SPELL_HATEFUL_STRIKE = 28308
local SPELL_DEMORALIZING_SHOUT = 69565
local SPELL_IMPALE = 19781
local SPELL_IMPENDING_DOOM = 39046
local SPELL_FEAR = 5782
local SPELL_VOID_SHIELD = 58813

local MAX_HEALTH = 877964

local function CastArcaneExplosion(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_ARCANE_EXPLOSION, true)
end

local function CastMortalStrike(eventId, delay, repeats, creature)
    local tank = creature:GetAITarget(1)
    if tank then
        creature:CastSpell(tank, SPELL_MORTAL_STRIKE, true)
    end
end

local function CastSunderArmor(eventId, delay, repeats, creature)
    local tank = creature:GetAITarget(1)
    if tank then
        creature:CastSpell(tank, SPELL_SUNDER_ARMOR, true)
    end
end

local function SummonInfernalOnce(creature)
    creature:CastSpell(creature, SPELL_SUMMON_INFERNAL, true)
end

local function CastHatefulStrike(eventId, delay, repeats, creature)
    local tank = creature:GetAITarget(1)
    if tank then
        creature:CastSpell(tank, SPELL_HATEFUL_STRIKE, true)
    end
end

local function CastDemoralizingShout(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_DEMORALIZING_SHOUT, true)
end

local function CastImpale(eventId, delay, repeats, creature)
    local tank = creature:GetAITarget(1)
    if tank then
        creature:CastSpell(tank, SPELL_IMPALE, true)
    end
end

local function CastImpendingDoom(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_IMPENDING_DOOM, true)
    end
end

local function CastFear(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_FEAR, true)
    end
end

local function CastVoidShield(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_VOID_SHIELD, true)
end

local function Phase1(creature)
    creature:RegisterEvent(CastArcaneExplosion, 8000, 0)
    creature:RegisterEvent(CastMortalStrike, 12000, 0)
    creature:RegisterEvent(CastSunderArmor, 15000, 0)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitSay("You will crumble beneath my power!", 0)
    SummonInfernalOnce(creature)
    CastVoidShield(nil, nil, nil, creature)
    creature:RegisterEvent(CastHatefulStrike, 12000, 0)
    creature:RegisterEvent(CastImpale, 18000, 0)
    creature:RegisterEvent(CastDemoralizingShout, 20000, 0)
    creature:RegisterEvent(CastImpendingDoom, 25000, 0)
    creature:RegisterEvent(CastFear, 30000, 0)
    Phase1(creature)
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

local function OnCombat(event, creature, target)
    Phase1(creature)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        if creature:GetHealthPct() < 50 then
            Phase2(creature)
        end
    end, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:SendUnitSay("I've waited long enough!", 0)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitSay("Fail me and suffer for eternity!", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitSay("Pity you cannot understand the reality of your situation....", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        if player:IsPlayer() then
            player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
        end
    end
end

RegisterCreatureEvent(ENEMY_ID, 1, OnCombat)
RegisterCreatureEvent(ENEMY_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(ENEMY_ID, 3, OnKilledTarget)
RegisterCreatureEvent(ENEMY_ID, 4, OnDeath)
RegisterCreatureEvent(ENEMY_ID, 5, OnSpawn)
