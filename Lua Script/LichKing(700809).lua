-- Lich King Custom Script for AzerothCore Araxia Online by Manmadedrummer
local BOSS_LICH_KING = 700809

local SPELL_SHOCKWAVE = 75418
local SPELL_REMORSELESS_WINTER = 68983
local SPELL_PAIN_AND_SUFFERING = 74117
local SPELL_LIFE_SIPHON = 73784
local SPELL_VILE_SPIRITS = 70498
local SPELL_HARVEST_SOUL = 74327
local SPELL_FURY_OF_FROSTMOURNE = 72350
local SPELL_MELEE_STRIKE = 73708

local SPELL_CAST_INTERVAL = math.random(5000, 10000)

local function CastRandomSpell(creature)
    local spells = {
        SPELL_SHOCKWAVE,
        SPELL_REMORSELESS_WINTER,
        SPELL_PAIN_AND_SUFFERING,
        SPELL_LIFE_SIPHON,
        SPELL_VILE_SPIRITS,
        SPELL_HARVEST_SOUL,
        SPELL_FURY_OF_FROSTMOURNE,
        SPELL_MELEE_STRIKE
    }

    local randomSpell = spells[math.random(1, #spells)]
    local target = creature:GetAITarget(0)

    if target then
        creature:CastSpell(target, randomSpell, true)
    end
end

local function RandomSpellCasting(eventId, delay, calls, creature)
    CastRandomSpell(creature)
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("You dare challenge the might of the Lich King!", 0)

    creature:RegisterEvent(RandomSpellCasting, SPELL_CAST_INTERVAL, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:SendUnitYell("You cannot escape... I will return!", 0)
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("Another soul claimed by the Lich King!", 0)
end

local function OnDeath(event, creature, killer)
    creature:RemoveEvents()
    creature:SendUnitYell("No... this cannot be!", 0)
end

RegisterCreatureEvent(BOSS_LICH_KING, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_LICH_KING, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_LICH_KING, 3, OnKilledTarget)
RegisterCreatureEvent(BOSS_LICH_KING, 4, OnDeath)
