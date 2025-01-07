-- Thok the Bloodthirsty made by Manmadedrummer for Araxia Online

local BOSS_THOK = 700821
local MAX_HEALTH = 2460681

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local SPELL_FEARsome_ROAR = 59422
local SPELL_DEAFENING_SCREECH = 3589
local SPELL_TAIL_LASH = 74531
local SPELL_SHOCK_BLAST = 63631
local SPELL_BLOOD_FRENZY = 29859

local SPELL_FIXATE = 41294
local SPELL_ACID_BREATH = 67577
local SPELL_CORROSIVE_BLOOD = 46293

local SPELL_FREEZING_BREATH = 64649
local SPELL_ICY_BLOOD = 72090
local SPELL_FIRE_BREATH = 59197
local SPELL_BURNING_BLOOD = 58579

local function CastRandomSpell(eventId, delay, repeats, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end

    local target = creature:GetAITarget(0)
    if not target then return end

    local spellList = {
        SPELL_FEARsome_ROAR, SPELL_DEAFENING_SCREECH, SPELL_TAIL_LASH,
        SPELL_SHOCK_BLAST, SPELL_BLOOD_FRENZY, SPELL_FIXATE,
        SPELL_ACID_BREATH, SPELL_CORROSIVE_BLOOD, SPELL_FREEZING_BREATH,
        SPELL_ICY_BLOOD, SPELL_FIRE_BREATH, SPELL_BURNING_BLOOD
    }

    local spell = spellList[math.random(1, #spellList)]
    if spell == SPELL_BLOOD_FRENZY then
        creature:CastSpell(creature, spell, true)
    else
        creature:CastSpell(target, spell, true)
    end
end

local function Phase1(creature)
    creature:RegisterEvent(CastRandomSpell, 5000, 0)
end

local function Phase2(creature)
    creature:SendUnitYell("Your blood will fuel my fury!", 0)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpell, 3000, 0)
end

local function Phase3(creature)
    creature:SendUnitYell("Feel the searing flames and freezing cold!", 0)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpell, 2000, 0)
end

local function CheckHealth(eventId, delay, repeats, creature)
    if not creature or creature:GetHealthPct() <= 0 then return end

    local healthPct = creature:GetHealthPct()

    if healthPct <= 55 and currentPhase < 2 then
        currentPhase = 2
        Phase2(creature)
    elseif healthPct <= 30 and currentPhase < 3 then
        currentPhase = 3
        Phase3(creature)
    end
end

local function OnEnterCombat(event, creature, target)
    currentPhase = 1
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)

    creature:SendUnitYell("You cannot escape the jaws of death!", 0)

    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("I... will return...", 0)
    creature:RemoveEvents()

    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_THOK, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_THOK, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_THOK, 4, OnDeath)