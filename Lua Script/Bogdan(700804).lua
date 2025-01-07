-- Original Bogdan script made by Bogdan https://www.mmopro.org/archive/index.php/t-2200.html
-- Converted to Azerothcore Araxia Online by Manmadedrummer

local BOSS_BOGDAN = 700804
local SPELL_SHADOW_BOLT_VOLLEY = 17228
local SPELL_DARK_MENDING = 379
local SPELL_SOUL_DRAIN = 72963
local SPELL_DARK_BLAST = 37668

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastShadowBoltVolley(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_SHADOW_BOLT_VOLLEY, true)
end

local function CastDarkMending(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_DARK_MENDING, true)
end

local function CastSoulDrain(eventId, delay, calls, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_SOUL_DRAIN, true)
    end
end

local function CastDarkBlast(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_DARK_BLAST, true)
end

local function Phase1(creature)
    creature:RegisterEvent(CastShadowBoltVolley, 10000, 0)
    creature:RegisterEvent(CastDarkMending, 15000, 0)
    creature:RegisterEvent(CastSoulDrain, 20000, 0)
    creature:RegisterEvent(CastDarkBlast, 25000, 0)
end

local function OnCombat(event, creature, target)
    creature:SendUnitYell("The shadows will consume you!", 0)
    Phase1(creature)
end

local function OnLeaveCombat(event, creature)
    creature:SendUnitYell("You cannot escape the darkness...", 0)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("You will join the shadows!", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("The darkness... fades...", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_BOGDAN, 1, OnCombat)
RegisterCreatureEvent(BOSS_BOGDAN, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_BOGDAN, 3, OnKilledTarget)
RegisterCreatureEvent(BOSS_BOGDAN, 4, OnDeath)
