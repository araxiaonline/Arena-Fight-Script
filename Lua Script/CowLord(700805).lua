--Original Cow Lord script by Murlock https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-emulator-servers/107481-release-cow-lord-custom-scripted-raid-boss.html
--Converted to Azerothcore Araxia Online by Manmadedrummer
local BOSS_ID = 700805
local STOMP_SPELL = 34716
local PHASE_2_SPELL = 33061
local PHASE_3_SPELL_1 = 29947
local PHASE_3_SPELL_2 = 41447
local RANDOM_TARGET_SPELL = 40370

local function CowLord_Phase3(event, delay, calls, creature)
    if creature:GetHealthPct() < 20 then
        creature:RemoveEvents()
        creature:SendUnitYell("YOU HAVE ANGERED ME!!.. MOO!!!", 0)
        creature:CastSpell(creature, PHASE_3_SPELL_1, true)
        creature:CastSpell(creature, PHASE_3_SPELL_2, true)
        creature:RegisterEvent(CowLord_Stomp, 10000, 0)
    end
end

local function CowLord_Phase2(event, delay, calls, creature)
    if creature:GetHealthPct() < 50 then
        creature:RemoveEvents()
        creature:SendUnitYell("You think you can win... Moo!?!", 0)
        local target = creature:GetAITarget(0)
        if target then
            creature:CastSpell(target, PHASE_2_SPELL, true)
        end
        creature:RegisterEvent(CowLord_Stomp, 15000, 0)
        creature:RegisterEvent(CowLord_Phase3, 1000, 0)
    end
end

local function CowLord_Stomp(event, delay, calls, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, STOMP_SPELL, true)
    end
end

local function CowLord_OnCombat(event, creature, target)
    creature:SendUnitYell("You will die... Moo!!", 0)
    local initialTarget = creature:GetAITarget(0)
    if initialTarget then
        creature:CastSpell(initialTarget, RANDOM_TARGET_SPELL, true)
    end
    creature:RegisterEvent(CowLord_Stomp, 20000, 0)
    creature:RegisterEvent(CowLord_Phase2, 1000, 0)
end

local function CowLord_OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function CowLord_OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("I am victorious... Moo!!", 0)
end

local function CowLord_OnDied(event, creature, killer)
    creature:SendUnitYell("I have failed... Moo..", 0)
    creature:RemoveEvents()
end

RegisterCreatureEvent(BOSS_ID, 1, CowLord_OnCombat)
RegisterCreatureEvent(BOSS_ID, 2, CowLord_OnLeaveCombat)
RegisterCreatureEvent(BOSS_ID, 3, CowLord_OnKilledTarget)
RegisterCreatureEvent(BOSS_ID, 4, CowLord_OnDied)
