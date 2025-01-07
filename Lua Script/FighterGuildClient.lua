local AIO = AIO or require("AIO")

-- Arena coordinates (player and boss spawn locations)
local mapId = 1  -- Arena map ID

-- Player spawn location (where the player is teleported)
local playerSpawnX, playerSpawnY, playerSpawnZ, playerOrientation = 2172.05, -4789.88, 55, 1.32696

-- Boss spawn location (where the boss is spawned)
local bossSpawnX, bossSpawnY, bossSpawnZ, bossOrientation = 2176, -4766, 55, 1.3

-- Reward coordinates (after the match)
local rewardX, rewardY, rewardZ, rewardOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404  -- Adjust orientation for post-fight

-- Check if this is the client-side addon
if AIO.AddAddon() then
    return
end

local FighterGuildHandler = AIO.AddHandlers("FighterGuildClient", {})

local selectedBoss = nil
local selectedButton = nil
local previousBossTexture = nil
local fighterGuildFrame = nil
local bossFrame = nil  -- Frame to contain boss buttons

local currentPage = 1  -- Keep track of the current page
local bossesPerPage = 9  -- Number of bosses to show per page
local selectedCategory = "Custom"  -- Track the selected category

-- Define boss categories
local bossCategories = {
    Custom = {
        {id = 700800, name = "Arian - The Demon", image = "Interface\\Buttons\\ArianTheDemon.blp", description = "Arian the Demon, a nightmarish entity born from the depths of the Twisting Nether, towers over the battlefield with his crimson, spiked armor that crackles with dark energy.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 700801, name = "Lord Cyran", image = "Interface\\Buttons\\LordCyran.blp", description = "Lord Cyran, a master of frost magic, controls the elements with icy precision, freezing foes in their tracks.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700802, name = "Tiger Boss", image = "Interface\\Buttons\\TigerBoss.blp", description = "Tiger Boss, swift and deadly, strikes fear into his enemies with unmatched speed and agility.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 700803, name = "Spellmaster", image = "Interface\\Buttons\\Spellmaster.blp", description = "Spellmaster wields arcane powers with precision, casting destructive spells from afar.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700804, name = "Bogdan - The Shadow Lord", image = "Interface\\Buttons\\Bogdan.blp", description = "Bogdan, the master of shadow magic, controls darkness itself to decimate his foes. Beware of his dark powers.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700805, name = "Cow Lord", image = "Interface\\Buttons\\CowLord.blp", description = "Cow Lord, An enraged bovine, stomps through battle with crushing force.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 700806, name = "Diablo - Lord of Terror", image = "Interface\\Buttons\\Diablo.blp", description = "Diablo's greatest power lies within utilizing his enemies' fears.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 700807, name = "Naroxius Death Guard", image = "Interface\\Buttons\\Naroxius.blp", description = "Naroxius Death Guard is a relentless juggernaut.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700817, name = "Gioran the Corrupted Paladin", image = "Interface\\Buttons\\Gioran.blp", description = "Gioran, a fallen holy warrior, now wielding both divine and unholy powers to crush his enemies.", difficulty = "Challenging", color = {1, 1, 0}},
    },
    Vanilla = {
        {id = 11519, name = "Bazzalan", image = "Interface\\Buttons\\Bazzalan.blp", description = "A cunning satyr and leader of the Searing Blade cultists in Ragefire Chasm, Bazzalan is a swift and powerful foe who swings fast and hits hard.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 3654, name = "Mutanus the Devourer", image = "Interface\\Buttons\\Mutanus.blp", description = "A monstrous murloc driven to madness by the Nightmare, Mutanus emerges from the depths of the Wailing Caverns with devastating force.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 12201, name = "Princess Theradras", image = "Interface\\Buttons\\Theradras.blp", description = "Princess Theradras, an ancient elemental and the corruptor of Maraudon.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 15990, name = "Kel'Thuzad", image = "Interface\\Buttons\\Kel.blp", description = "The Lich King's most loyal servant, Kel'Thuzad commands the necropolis Naxxramas, unleashing devastating frost and shadow magic to decimate all who challenge his master's reign.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 16028, name = "Patchwerk", image = "Interface\\Buttons\\Patchwerk.blp", description = "The most powerful abomination guarding the construct quarter in Naxxramas, Patchwerk is a towering juggernaut of sewn flesh, whose brute strength and relentless attacks make him a fearsome adversary.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 15299, name = "Viscidus", image = "Interface\\Buttons\\Viscidus.blp", description = "A menacing gelatinous horror in the Temple of Ahn'Qiraj, Viscidus is a towering slime creature that bombards adventurers with lethal poison bolts.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 16060, name = "Gothik the Harvester", image = "Interface\\Buttons\\Gothik.blp", description = "Gothik the Harvester, master necromancer of Naxxramas.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 12264, name = "Shazzrah", image = "Interface\\Buttons\\Shazzrah.blp", description = "Shazzrah is a powerful arcane elemental boss in Molten Core.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 12056, name = "Baron Geddon", image = "Interface\\Buttons\\BaronGeddon.blp", description = "Baron Geddon, lieutenant of Ragnaros.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 12017, name = "Broodlord Lashlayer", image = "Interface\\Buttons\\Broodlord.blp", description = "Broodlord Lashlayer, a black dragon from Blackwing Lair.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 12018, name = "Majordomo Executus", image = "Interface\\Buttons\\Majordomo.blp", description = "Majordomo Executus, servant of Ragnaros.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 11501, name = "King Gordok", image = "Interface\\Buttons\\Gordok.blp", description = "Gordok's mind is plagued with whispers from the Emerald Nightmare that are urging him to madness and slaughter.", difficulty = "Challenging", color = {1, 1, 0}},
    },
    BC = {
        {id = 21215, name = "Leotheras the Blind", image = "Interface\\Buttons\\Leotheras.blp", description = "Leotheras, a former night elf who succumbed to demonic corruption, now a formidable demon hunter in Serpentshrine Cavern.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 24723, name = "Selin Fireheart", image = "Interface\\Buttons\\SelinFireheart.blp", description = "Selin Fireheart, a blood elf driven mad by his addiction to fel magic, fights within Magisters' Terrace.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 17308, name = "Omor the Unscarred", image = "Interface\\Buttons\\Omor.blp", description = "Omor the Unscarred, a powerful pit lord serving the Burning Legion, resides in Hellfire Ramparts.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 17797, name = "Hydromancer Thespia", image = "Interface\\Buttons\\Thespia.blp", description = "Hydromancer Thespia, a naga sorceress controlling water elementals, defends the Steamvault in Coilfang Reservoir.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 16809, name = "Warbringer O'mrogg", image = "Interface\\Buttons\\Omrogg.blp", description = "Warbringer O'mrogg, a brutal two-headed ogre serving the Fel Horde in the Shattered Halls.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 16807, name = "Grand Warlock Nethekurse", image = "Interface\\Buttons\\Nethekurse.blp", description = "Grand Warlock Nethekurse, a twisted orc warlock and former Shadow Council member, now commands the Fel Horde in the Shattered Halls.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 17977, name = "Warp Splinter", image = "Interface\\Buttons\\WarpSplinter.blp", description = "Warp Splinter, an ancient protector twisted by arcane energy, guards the Botanica in Tempest Keep.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 24239, name = "Hex Lord Malacrass", image = "Interface\\Buttons\\Malacrass.blp", description = "Hex Lord Malacrass, a cunning troll witch doctor, leads the Amani's forces in Zul'Aman.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 18805, name = "High Astromancer Solarian", image = "Interface\\Buttons\\Solarian.blp", description = "High Astromancer Solarian, a powerful blood elf adept in arcane magic, resides in The Eye of Tempest Keep.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 22871, name = "Teron Gorefiend", image = "Interface\\Buttons\\Gorefiend.blp", description = "Teron Gorefiend, the first death knight created by Gul'dan, serves Illidan in the Black Temple.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 17888, name = "Kaz'rogal", image = "Interface\\Buttons\\Kazrogal.blp", description = "Kaz'rogal, a mighty Doomguard commander of the Burning Legion, appears in the Battle for Mount Hyjal.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 31395, name = "Illidan Stormrage", image = "Interface\\Buttons\\Illidan.blp", description = "Illidan Stormrage, the infamous Betrayer, rules the Black Temple and commands the forces of Outland.", difficulty = "Hard", color = {1, 0, 0}},
    },
    WOTLK = {
        {id = 27447, name = "Varos Cloudstrider", image = "Interface\\Buttons\\Cloudstrider.blp", description = "Varos Cloudstrider, a storm drake rider in The Oculus.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 36497, name = "Bronjahm", image = "Interface\\Buttons\\Bronjahm.blp", description = "Bronjahm, the soul-trader who guards the Forge of Souls.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 29309, name = "Elder Nadox", image = "Interface\\Buttons\\ElderNadox.blp", description = "Elder Nadox, an ancient nerubian lord who guards Ahn'kahet.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 26630, name = "Trollgore", image = "Interface\\Buttons\\Trollgore.blp", description = "Trollgore, a monstrous Drakkari troll in Drak'Tharon Keep.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 29310, name = "Jedoga Shadowseeker", image = "Interface\\Buttons\\Jedoga.blp", description = "Jedoga Shadowseeker, a Twilight's Hammer cultist in Ahn'kahet.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 26529, name = "Meathook", image = "Interface\\Buttons\\Meathook.blp", description = "Meathook, a brutal undead monstrosity in the Culling of Stratholme.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 32845, name = "Hodir", image = "Interface\\Buttons\\Hodir.blp", description = "Hodir, the frost giant guardian in Ulduar, master of ice and snow.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 32906, name = "Freya", image = "Interface\\Buttons\\Freya.blp", description = "Freya, the Keeper of Life and guardian of Ulduar's Conservatory.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 29304, name = "Slad'ran", image = "Interface\\Buttons\\Sladran.blp", description = "Slad'ran, a Drakkari troll in Gundrak who controls venomous serpents.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 29305, name = "Moorabi", image = "Interface\\Buttons\\Moorabi.blp", description = "Moorabi, a Drakkari troll in Gundrak who seeks to transform into a mammoth god.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 38433, name = "Toravon the Ice Watcher", image = "Interface\\Buttons\\Toravon.blp", description = "Toravon the Ice Watcher, a frost giant defending Wintergrasp Fortress.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 700809, name = "The Lich King", image = "Interface\\Buttons\\LichKing.blp", description = "The Lich King, the ultimate master of death and necromancy, and ruler of Icecrown Citadel.", difficulty = "Hard", color = {1, 0, 0}},
    },    
    CATA = {
        {id = 700808, name = "Al'Akir", image = "Interface\\Buttons\\Alaqir.blp", description = "Al'Akir, gifted with great intelligence and cunning, Al'Akir the Windlord once served as the foremost tactician in the Old Gods' horrific armies.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 700810, name = "Cho'gall", image = "Interface\\Buttons\\Chogall.blp", description = "Cho'gall, the twisted ogre infused with the power of the Old Gods.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 700811, name = "Forgemaster Throngus", image = "Interface\\Buttons\\Throngus.blp", description = "Forgemaster Throngus, a giant overseeing the forging of powerful weapons and armor in Grim Batol.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 700812, name = "Ozruk", image = "Interface\\Buttons\\Ozruk.blp", description = "Ozruk, the stone giant guardian of the World's Heart and a fearsome foe in the Stonecore.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700813, name = "Argaloth", image = "Interface\\Buttons\\Argaloth.blp", description = "Argaloth, a pit lord of the Burning Legion, is a fearsome boss imprisoned within Baradin Hold.", difficulty = "Hard", color = {1, 0, 0}}, 
        {id = 700814, name = "Setesh", image = "Interface\\Buttons\\Setesh.blp", description = "Setesh, the Master of Chaos, summons void creatures and unleashes destructive energy to dominate the arena.", difficulty = "Easy", color = {0, 1, 0}},
        {id = 700815, name = "Therazane", image = "Interface\\Buttons\\Therazane.blp", description = "Therazane, the Stonemother, commands the very earth to crush her enemies and reshape the arena with her unyielding power.", difficulty = "Challenging", color = {1, 1, 0}},    
    },
    MOP = {
        {id = 700816, name = "Elegon", image = "Interface\\Buttons\\Elegon.blp", description = "Elegon, the celestial guardian of the Engine of Nalak'sha.", difficulty = "Hard", color = {1, 0, 0}},        
        {id = 700818, name = "Amber-Shaper Un'sok", image = "Interface\\Buttons\\Unsok.blp", description = "A master alchemist and manipulator, Amber-Shaper Un'sok experiments with volatile amber magic, transforming enemies into monstrous creations.", difficulty = "Hard", color = {1, 0, 0}},        
        {id = 700819, name = "Imperial Vizier Zor'lok", image = "Interface\\Buttons\\Zorlok.blp", description = "As the voice of the Empress, Zor'lok commands unmatched authority, using his resonating power to control and influence the battlefield.", difficulty = "Hard", color = {1, 0, 0}},           
        {id = 700820, name = "Garrosh Hellscream", image = "Interface\\Buttons\\Hellscream.blp", description = "A former Warchief of the Horde chosen by Thrall to replace him in the wake of the Cataclysm.", difficulty = "Hard", color = {1, 0, 0}},           
        {id = 700821, name = "Thok the Bloodthirsty", image = "Interface\\Buttons\\Thok.blp", description = "This titanic devilsaur is a native of the Isle of Giants which Garrosh Hellscream wishes to subjugate to his will, but the dinosaur refuses to submit.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700822, name = "General Pa'valak", image = "Interface\\Buttons\\Pavalak.blp", description = "The pragmatic General Pa'valak does not fear the pandaren or their allies, and he does not differentiate between using his own might and that of his mantid armies to defeat his enemies.", difficulty = "Easy", color = {0, 1, 0}},  
        {id = 700823, name = "Gekkan", image = "Interface\\Buttons\\Gekkan.blp", description = "Gekkan is a saurok and the second boss found in the Vault of Kings Past of the Mogu'shan Palace.", difficulty = "Easy", color = {0, 1, 0}},  
    },
    WoD = {
        {id = 700824, name = "Blackhand", image = "Interface\\Buttons\\Blackhand.blp", description = "A ruthless tyrant and fierce warrior, Blackhand is Warlord of the Blackrock clan, second only to Grommash in stature within the Iron Horde.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700825, name = "Kargath Bladefist", image = "Interface\\Buttons\\Bladefist.blp", description = "Kargath Bladefist was the Warchief of the Fel Horde and Chieftain of the Shattered Hand clan.", difficulty = "Hard", color = {1, 0, 0}},
        {id = 700826, name = "High Sage Viryx", image = "Interface\\Buttons\\Viryx.blp", description = "A Arakkoa leader of the Adherents of Rukhmar after betraying her former clutch-brother Iskar.", difficulty = "Easy", color = {0, 1, 0}},  
        {id = 700827, name = "The Butcher", image = "Interface\\Buttons\\Butcher.blp", description = "Born in the fetid Underbelly of Highmaul, this ogre may have once had a proper name, but it is long forgotten.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700828, name = "Brackenspore", image = "Interface\\Buttons\\Brackenspore.blp", description = "This aquatic giant spreads fungal growth and moss in its wake, and is driven by primal instinct to eradicate any traces of civilization on Draenor.", difficulty = "Hard", color = {1, 0, 0}},   
        {id = 700829, name = "Mannoroth", image = "Interface\\Buttons\\Mannoroth.blp", description = "A Pit Lord lieutenant in the Burning Legion and the original architect, along with Kil'Jaeden, of the Orcs corruption on Draenor.", difficulty = "Hard", color = {1, 0, 0}},       
        {id = 700830, name = "Lady Temptessa", image = "Interface\\Buttons\\Temptessa.blp", description = "A tall 6-armed female Shivarra, devout and exceedingly charismatic, this priestess lives only to evangelize the power of Sargeras dread vision.", difficulty = "Easy", color = {0, 1, 0}},     
    },
    Legion = {
        {id = 700831, name = "Kil'Jaeden", image = "Interface\\Buttons\\Kiljaeden.blp", description = "A powerful eredar demon lord and the second in rank of the Burning Legion. 13,000 years ago, he was a leader of the benevolent eredar people of Argus.", difficulty = "Hard", color = {1, 0, 0}}, 
        {id = 700832, name = "Gul'dan", image = "Interface\\Buttons\\Guldan.blp", description = "The first orcish warlock as well as the de facto founder of the Horde. He betrayed both his people and his mentor Ner'zhul to the demon lord Kil'jaeden for personal gain and power.", difficulty = "Hard", color = {1, 0, 0}}, 
        {id = 700833, name = "Tichondrius", image = "Interface\\Buttons\\Tichondrius.blp", description = "The leader of the nathrezim of the Burning Legion, under the command of Kil'jaeden and Archimonde. A powerful and cunning Dreadlord.", difficulty = "Hard", color = {1, 0, 0}},    
        {id = 700834, name = "Xavius", image = "Interface\\Buttons\\Xavius.blp", description = "One of the Highborne's most powerful sorcerers and the high councilor to Queen Azshara during the time of the War of the Ancients.", difficulty = "Hard", color = {1, 0, 0}},     
        {id = 700835, name = "Varimathras", image = "Interface\\Buttons\\Varimathras.blp", description = "He was tortured by the Coven of Shivarra, stripping away both flesh and sanity, leaving only a singular desire to inflict suffering upon the mortals who cost him everything.", difficulty = "Challenging", color = {1, 1, 0}},
        {id = 700836, name = "Imonar the Soulhunter", image = "Interface\\Buttons\\Imonar.blp", description = "Serves as the Legions bloodhound, capable of tracking prey across the cosmos. With a vast array of gadgets and traps at his disposal, Imonar has yet to lose a bounty.", difficulty = "Challenging", color = {1, 1, 0}},      
    },
}

-- Function to create the boss selection frame
local function CreateBossSelectionFrame()
    -- Create the main frame (scaled background image to 800x600)
    fighterGuildFrame = CreateFrame("Frame", "FighterGuildFrame", UIParent)
    fighterGuildFrame:SetSize(800, 700)
    fighterGuildFrame:SetPoint("CENTER")

    -- Adding the custom background and scaling it down
    local background = fighterGuildFrame:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Buttons\\ArenaBG.blp")
    background:SetAllPoints(fighterGuildFrame)

    -- Crop the texture to fit the frame using SetTexCoord
    background:SetTexCoord(0, 0.78, 0, 0.78)

    -- Frame border
    fighterGuildFrame:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    fighterGuildFrame:SetBackdropColor(0, 0, 0, 1)
    fighterGuildFrame:SetMovable(true)
    fighterGuildFrame:EnableMouse(true)
    fighterGuildFrame:RegisterForDrag("LeftButton")
    fighterGuildFrame:SetScript("OnDragStart", fighterGuildFrame.StartMoving)
    fighterGuildFrame:SetScript("OnDragStop", fighterGuildFrame.StopMovingOrSizing)

    local closeButton = CreateFrame("Button", nil, fighterGuildFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", fighterGuildFrame, "TOPRIGHT")

    local title = fighterGuildFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", fighterGuildFrame, "TOP", 0, -10)
    title:SetText("Select Your Boss")

    -- Create category buttons (size 128x64 for categories)
    local categories = {
        {name = "Custom", bgColor = {0, 0.4, 1}},     -- Blue
        {name = "Vanilla", bgColor = {0.54, 0.27, 0.07}}, -- Brown
        {name = "BC", bgColor = {0, 1, 0}},           -- Green
        {name = "WOTLK", bgColor = {0, 0, 1}},        -- Blue
        {name = "CATA", bgColor = {0.54, 0.27, 0.07}}, -- Brown
        {name = "MOP", bgColor = {1, 0.4, 0}}, -- Orange
        {name = "WoD", bgColor = {1, 0.4, 0}}, -- Orange
        {name = "Legion", bgColor = {1, 0.4, 0}}, -- Orange
    }

    for i, category in ipairs(categories) do
        local button = CreateFrame("Button", "CategoryButton" .. i, fighterGuildFrame, "UIPanelButtonTemplate")
        button:SetSize(128, 64)
        button:SetPoint("TOPLEFT", fighterGuildFrame, "TOPLEFT", 10, -50 - (i - 1) * 70)
        button:SetText(category.name)
        button:SetBackdropColor(unpack(category.bgColor))  -- Set button background color
        button:GetFontString():SetTextColor(1, 1, 0)  -- Set text color to yellow
        button:SetScript("OnClick", function()
            currentPage = 1  -- Reset page when switching category
            selectedCategory = category.name  -- Track the selected category
            DisplayBosses(selectedCategory)
            -- Highlight the selected category button
            if selectedButton then
                selectedButton:SetBackdrop(nil)
            end
            selectedButton = button
            button:SetBackdrop({
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, edgeSize = 16,
                insets = {left = -6, right = -6, top = -6, bottom = -6}
            })
            button:SetBackdropBorderColor(1, 0.5, 0) -- Gold color to indicate selection
        end)
    end

    -- Frame to contain the boss buttons
    bossFrame = CreateFrame("Frame", "BossFrame", fighterGuildFrame)
    bossFrame:SetSize(500, 500)
    bossFrame:SetPoint("TOPRIGHT", fighterGuildFrame, "TOPRIGHT", -10, -50)

    -- Page controls: Next and Previous buttons
    local nextButton = CreateFrame("Button", nil, fighterGuildFrame, "UIPanelButtonTemplate")
    nextButton:SetSize(80, 50)
    nextButton:SetPoint("BOTTOMRIGHT", fighterGuildFrame, "BOTTOMRIGHT", -10, 10)
    nextButton:SetText("Next")
    nextButton:SetScript("OnClick", function()
        currentPage = currentPage + 1
        DisplayBosses(selectedCategory)
    end)

    local prevButton = CreateFrame("Button", nil, fighterGuildFrame, "UIPanelButtonTemplate")
    prevButton:SetSize(80, 50)
    prevButton:SetPoint("BOTTOMLEFT", fighterGuildFrame, "BOTTOMLEFT", 10, 10)
    prevButton:SetText("Previous")
    prevButton:SetScript("OnClick", function()
        currentPage = currentPage - 1
        DisplayBosses(selectedCategory)
    end)

    DisplayBosses("Custom")  -- Load the first category by default
end

-- Function to display bosses based on the selected category and current page
function DisplayBosses(category)
    if not bossCategories[category] then return end  -- Safety check

    -- Clear previous buttons
    if bossFrame then
        for i, child in ipairs({bossFrame:GetChildren()}) do
            child:Hide()
        end
    end

    local bosses = bossCategories[category]
    local numColumns = 3
    local spacing = 30
    local bossSize = 128
    local totalBosses = #bosses

    -- Calculate how many pages are needed
    local totalPages = math.ceil(totalBosses / bossesPerPage)

    -- Ensure we don't go out of bounds for page numbers
    if currentPage > totalPages then
        currentPage = totalPages
    elseif currentPage < 1 then
        currentPage = 1
    end

    -- Determine which bosses to show on the current page
    local startIndex = (currentPage - 1) * bossesPerPage + 1
    local endIndex = math.min(startIndex + bossesPerPage - 1, totalBosses)

    -- Create new boss buttons for the current page
    for i = startIndex, endIndex do
        local boss = bosses[i]
        local row = math.floor((i - startIndex) / numColumns)
        local col = (i - startIndex) % numColumns

        local bossButton = CreateFrame("Button", "BossImageButton" .. i, bossFrame)
        bossButton:SetSize(128, 64)
        bossButton:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", col * (bossSize + spacing), -row * (bossSize + spacing))
        bossButton.boss = boss

        local texture = bossButton:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(bossButton)
        texture:SetTexture(boss.image)

        -- Tooltip
        bossButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetMinimumWidth(200)
            GameTooltip:AddLine(boss.name, unpack(boss.color))
            GameTooltip:AddLine(boss.difficulty, unpack(boss.color))
            GameTooltip:AddLine(boss.description, 1, 1, 1, true)
            GameTooltip:Show()
        end)

        bossButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Select boss
        bossButton:SetScript("OnClick", function(self)
            if selectedButton then
                selectedButton:SetBackdrop(nil)
                -- Remove desaturation from the previously selected boss
                if previousBossTexture then
                    previousBossTexture:SetDesaturated(false)
                end
            end
            selectedBoss = self.boss
            selectedButton = self
            previousBossTexture = texture  -- Save the current texture

            -- Gray out the selected boss
            texture:SetDesaturated(true)
        end)
    end

    -- Queue button
    local queueButton = CreateFrame("Button", "QueueButton", fighterGuildFrame, "UIPanelButtonTemplate")
    queueButton:SetSize(140, 50)
    queueButton:SetPoint("BOTTOM", fighterGuildFrame, "BOTTOM", 0, 10)
    queueButton:SetText("Queue for Fight")

    queueButton:SetScript("OnClick", function()
        if selectedBoss then
            AIO.Handle("FighterGuildServer", "StartFight", selectedBoss.id)
            if fighterGuildFrame then
                fighterGuildFrame:Hide()
            end
        else
            print("No boss selected!")
        end
    end)
end

-- Show the boss selection frame
function FighterGuildHandler.ShowBossSelectionFrame()
    CreateBossSelectionFrame()
end
