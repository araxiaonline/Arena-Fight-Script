local BOSS_THRONGUS = 700811

local rewardX, rewardY, rewardZ, rewardOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local SPELL_MOLTEN_POOL = 39429
local SPELL_BLISTERING_HEAT = 67475
local SPELL_MOLTEN_FLURRY = 62531
local SPELL_MOLTEN_SPARK = 55362
local SPELL_FIERY_CLEAVE = 72493
local SPELL_ENRAGE = 23128

local FORGE_WEAPON_TIMER = 30000
local CLEAVE_TIMER = 15000
local FLURRY_TIMER = 45000
local SPARK_TIMER = 20000
local ENRAGE_TIMER = 60000

local QUOTE_AGGRO = "NO! Throngus get whipped again if he no finish!"
local QUOTE_MACE = "Oh, this is gonna HURT!"
local QUOTE_KILL = "You break easy! Throngus use your corpse on body. Somewhere..."
local QUOTE_DEATH = "Death... Good choice. Not best choice maybe, but better than fail and live."

local function CastMoltenPool(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        local target = creature:GetVictim()
        if target then
            creature:CastSpell(target, SPELL_MOLTEN_POOL, true)
        end
    end
end

local function CastFieryCleave(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        local target = creature:GetVictim()
        if target then
            creature:CastSpell(target, SPELL_FIERY_CLEAVE, true)
        end
    end
end

local function CastMoltenFlurry(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        local target = creature:GetVictim()
        if target then
            creature:CastSpell(target, SPELL_MOLTEN_FLURRY, true)
        end
    end
end

local function CastMoltenSpark(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        local target = creature:GetAITarget(1)
        if target then
            creature:CastSpell(target, SPELL_MOLTEN_SPARK, true)
        end
    end
end

local function StartForgingWeapon(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        creature:CastSpell(creature, SPELL_BLISTERING_HEAT, true)
        creature:SendUnitYell(QUOTE_MACE, 0)
    end
end

local function CastEnrage(eventId, delay, calls, creature)
    if creature and creature:IsAlive() then
        creature:CastSpell(creature, SPELL_ENRAGE, true)
    end
end

-- On Combat Start
local function OnEnterCombat(event, creature, target)
    creature:SetMaxHealth(877964)
    creature:SetHealth(877964)
    creature:SendUnitYell(QUOTE_AGGRO, 0)
    creature:RegisterEvent(CastFieryCleave, CLEAVE_TIMER, 0)
    creature:RegisterEvent(CastMoltenFlurry, FLURRY_TIMER, 0)
    creature:RegisterEvent(CastMoltenSpark, SPARK_TIMER, 0)
    creature:RegisterEvent(StartForgingWeapon, FORGE_WEAPON_TIMER, 0)
    creature:RegisterEvent(CastEnrage, ENRAGE_TIMER, 0)
end

local function OnDied(event, creature, killer)
    creature:SendUnitYell(QUOTE_DEATH, 0)
    creature:RemoveEvents()

    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        if player:IsPlayer() then
            player:Teleport(1, rewardX, rewardY, rewardZ, rewardOrientation)
        end
    end
end

local function OnKillPlayer(event, creature, victim)
    creature:SendUnitYell(QUOTE_KILL, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

RegisterCreatureEvent(BOSS_THRONGUS, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_THRONGUS, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_THRONGUS, 3, OnKillPlayer)
RegisterCreatureEvent(BOSS_THRONGUS, 4, OnDied)
