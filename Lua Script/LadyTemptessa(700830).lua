-- Lady Temtessa Arena Boss script made by Manmadedrummer for Araxia Online

local BOSS_LADY_TEMPTESSA = 700830
local MAX_HEALTH = 115030
local SPELL_CRIMSON_SLASH = 71154
local SPELL_SCYTHING_WHIRL = 62376
local SPELL_SHADOW_SLASH = 69181
local SPELL_SPECTRAL_SLASH = 72688
local SPELL_TEMPEST_OF_BLADES = 63808
local SPELL_PUNCTURE_STRIKE = 70279
local SPELL_CRUSADER_STRIKE = 71549
local SPELL_ENRAGE = 72148
local currentPhase = 1
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local QUOTE_START = "Mow them down."
local QUOTE_DEATH = "They will... overrun... you..."

local function CastRandomSpell(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(1) then return end
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {
        SPELL_CRIMSON_SLASH, SPELL_SCYTHING_WHIRL, SPELL_SHADOW_SLASH,
        SPELL_SPECTRAL_SLASH, SPELL_TEMPEST_OF_BLADES, SPELL_PUNCTURE_STRIKE, SPELL_CRUSADER_STRIKE
    }
    local spell = spellList[math.random(1, #spellList)]
    creature:CastSpell(target, spell, true)
end

local function Phase1(creature)
    creature:SendUnitYell(QUOTE_START, 0)
    creature:RegisterEvent(CastRandomSpell, 3000, 0)
end

local function CheckHealth(eventId, delay, repeats, creature)
    if not creature or creature:HealthBelowPct(1) then return end
    if creature:HealthBelowPct(30) and currentPhase < 2 then
        currentPhase = 2
        creature:CastSpell(creature, SPELL_ENRAGE, true)
    end
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

local function OnEnterCombat(event, creature, target)
    currentPhase = 1
    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell(QUOTE_DEATH, 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(50)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_LADY_TEMPTESSA, 5, OnSpawn)
RegisterCreatureEvent(BOSS_LADY_TEMPTESSA, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_LADY_TEMPTESSA, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_LADY_TEMPTESSA, 4, OnDeath)
