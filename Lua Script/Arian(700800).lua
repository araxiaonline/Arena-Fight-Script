-- Original Script made By Torgash! of ac-web/mmopro.net/mmorush.com
-- Converted by Manmadedrummer for Araxia on Azerothcore https://github.com/araxiaonline

local ENEMY_ID = 700800
local SPELL_BLAST_WAVE = 38536
local SPELL_FIRE_BLAST = 20679
local SPELL_CONE_OF_FIRE = 36876
local SPELL_FIREBALL_VOLLEY = 15243
local SPELL_FIRE_BLOSSOM = 19636
local SPELL_RAIN_OF_FIRE = 39363

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

-- Core Functions
local function CastBlastWave(eventId, delay, repeats, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_BLAST_WAVE, true)
end

local function CastFireBlast(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_FIRE_BLAST, true)
    end
end

local function CastConeOfFire(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_CONE_OF_FIRE, true)
end

local function CastFireballVolley(eventId, delay, repeats, creature)
    local tank = creature:GetAITarget(1)
    if tank then
        creature:CastSpell(tank, SPELL_FIREBALL_VOLLEY, true)
    end
end

local function CastFireBlossom(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_FIRE_BLOSSOM, true)
    end
end

local function CastRainOfFire(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_RAIN_OF_FIRE, true)
end

local function Phase1(creature)
    creature:RegisterEvent(CastBlastWave, 10000, 0)
    creature:RegisterEvent(CastFireBlast, 12000, 0)
    creature:RegisterEvent(CastConeOfFire, 15000, 0)
    creature:RegisterEvent(CastFireballVolley, 20000, 0)
    creature:RegisterEvent(CastFireBlossom, 25000, 0)
    creature:RegisterEvent(CastRainOfFire, 30000, 0)
end

-- Combat Events
local function OnCombat(event, creature, target)
    creature:SendUnitYell("Another step towards destruction!", 0)
    Phase1(creature)
end

local function OnLeaveCombat(event, creature)
    creature:SendUnitYell("I have waited long enough!", 0)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("Fail me and suffer for eternity!", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("All my plans have led to this!", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

-- Registration of Events
RegisterCreatureEvent(ENEMY_ID, 1, OnCombat)
RegisterCreatureEvent(ENEMY_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(ENEMY_ID, 3, OnKilledTarget)
RegisterCreatureEvent(ENEMY_ID, 4, OnDeath)
