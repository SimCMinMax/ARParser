--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Priest then Spell.Priest = {} end
Spell.Priest.Shadow = {
  ShadowformBuff                        = Spell(232698),
  Shadowform                            = Spell(232698),
  MindBlast                             = Spell(8092),
  ShadowWordVoid                        = Spell(205351),
  VoidEruption                          = Spell(228260),
  DarkAscension                         = Spell(280711),
  VoidformBuff                          = Spell(194249),
  WhispersoftheDamned                   = Spell(),
  Mindbender                            = Spell(200174),
  Shadowfiend                           = Spell(34433),
  VoidBolt                              = Spell(205448),
  DarkVoid                              = Spell(263346),
  ShadowWordPainDebuff                  = Spell(589),
  SurrenderToMadness                    = Spell(193223),
  ShadowCrash                           = Spell(205385),
  MindSear                              = Spell(48045),
  ShadowWordPain                        = Spell(589),
  ShadowWordDeath                       = Spell(32379),
  Misery                                = Spell(238558),
  VampiricTouch                         = Spell(34914),
  VampiricTouchDebuff                   = Spell(34914),
  VoidTorrent                           = Spell(263165),
  MindFlay                              = Spell(15407)
};
local S = Spell.Priest.Shadow;

-- Items
if not Item.Priest then Item.Priest = {} end
Item.Priest.Shadow = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Priest.Shadow;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Priest.Commons,
  Shadow = HR.GUISettings.APL.Priest.Shadow
};

-- Variables

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cleave, Single
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- shadowform,if=!buff.shadowform.up
    if S.Shadowform:IsCastableP() and Player:BuffDownP(S.ShadowformBuff) and (not Player:BuffP(S.ShadowformBuff)) then
      if HR.Cast(S.Shadowform) then return ""; end
    end
    -- mind_blast
    if S.MindBlast:IsCastableP() then
      if HR.Cast(S.MindBlast) then return ""; end
    end
    -- shadow_word_void
    if S.ShadowWordVoid:IsCastableP() then
      if HR.Cast(S.ShadowWordVoid) then return ""; end
    end
  end
  Aoe = function()
    -- void_eruption
    if S.VoidEruption:IsCastableP() then
      if HR.Cast(S.VoidEruption) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&azerite.whispers_of_the_damned.rank=0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and S.WhispersoftheDamned:AzeriteRank() == 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&(cooldown.mindbender.remains>0|cooldown.shadowfiend.remains>0)&azerite.whispers_of_the_damned.rank>0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and (S.Mindbender:CooldownRemainsP() > 0 or S.Shadowfiend:CooldownRemainsP() > 0) and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- void_bolt,if=talent.dark_void.enabled&dot.shadow_word_pain.remains>travel_time
    if S.VoidBolt:IsCastableP() and (S.DarkVoid:IsAvailable() and Target:DebuffRemainsP(S.ShadowWordPainDebuff) > S.VoidBolt:TravelTime()) then
      if HR.Cast(S.VoidBolt) then return ""; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
    if S.SurrenderToMadness:IsCastableP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness) then return ""; end
    end
    -- dark_void
    if S.DarkVoid:IsCastableP() then
      if HR.Cast(S.DarkVoid) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if S.ShadowCrash:IsCastableP() and (10000000000 > 5 and raid_event.adds.duration < 20) then
      if HR.Cast(S.ShadowCrash) then return ""; end
    end
    -- mind_sear,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindSear:IsCastableP() then
      if HR.Cast(S.MindSear) then return ""; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return ""; end
    end
  end
  Cleave = function()
    -- void_eruption
    if S.VoidEruption:IsCastableP() then
      if HR.Cast(S.VoidEruption) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&azerite.whispers_of_the_damned.rank=0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and S.WhispersoftheDamned:AzeriteRank() == 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&(cooldown.mindbender.remains>0|cooldown.shadowfiend.remains>0)&azerite.whispers_of_the_damned.rank>0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and (S.Mindbender:CooldownRemainsP() > 0 or S.Shadowfiend:CooldownRemainsP() > 0) and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- void_bolt
    if S.VoidBolt:IsCastableP() then
      if HR.Cast(S.VoidBolt) then return ""; end
    end
    -- shadow_word_death,target_if=target.time_to_die<3|buff.voidform.down
    if S.ShadowWordDeath:IsCastableP() and (Target:TimeToDie() < 3 or Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
    if S.SurrenderToMadness:IsCastableP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness) then return ""; end
    end
    -- dark_void
    if S.DarkVoid:IsCastableP() then
      if HR.Cast(S.DarkVoid) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- mind_blast,if=buff.voidform.down&talent.misery.enabled
    if S.MindBlast:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and S.Misery:IsAvailable()) then
      if HR.Cast(S.MindBlast) then return ""; end
    end
    -- shadow_crash,if=(raid_event.adds.in>5&raid_event.adds.duration<2)|raid_event.adds.duration>2
    if S.ShadowCrash:IsCastableP() and ((10000000000 > 5 and raid_event.adds.duration < 2) or raid_event.adds.duration > 2) then
      if HR.Cast(S.ShadowCrash) then return ""; end
    end
    -- shadow_word_pain,target_if=refreshable&target.time_to_die>4,if=!talent.misery.enabled&!talent.dark_void.enabled
    if S.ShadowWordPain:IsCastableP() and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff) and Target:TimeToDie() > 4) and (not S.Misery:IsAvailable() and not S.DarkVoid:IsAvailable()) then
      if HR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,target_if=refreshable,if=(target.time_to_die>6)
    if S.VampiricTouch:IsCastableP() and (Target:DebuffRefreshableCP(S.VampiricTouchDebuff)) and ((Target:TimeToDie() > 6)) then
      if HR.Cast(S.VampiricTouch) then return ""; end
    end
    -- vampiric_touch,target_if=dot.shadow_word_pain.refreshable,if=(talent.misery.enabled&target.time_to_die>4)
    if S.VampiricTouch:IsCastableP() and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff)) and ((S.Misery:IsAvailable() and Target:TimeToDie() > 4)) then
      if HR.Cast(S.VampiricTouch) then return ""; end
    end
    -- void_torrent
    if S.VoidTorrent:IsCastableP() then
      if HR.Cast(S.VoidTorrent) then return ""; end
    end
    -- mind_blast,if=dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking&azerite.whispers_of_the_damned.rank>0&talent.dark_ascension.enabled
    if S.MindBlast:IsCastableP() and (Target:DebuffP(S.ShadowWordPainDebuff) and Target:DebuffP(S.VampiricTouchDebuff) and S.WhispersoftheDamned:AzeriteRank() > 0 and S.DarkAscension:IsAvailable()) then
      if HR.Cast(S.MindBlast) then return ""; end
    end
    -- mind_sear,target_if=spell_targets.mind_sear>2,chain=1,interrupt=1
    if S.MindSear:IsCastableP() and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.MindSear) then return ""; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return ""; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return ""; end
    end
  end
  Single = function()
    -- void_eruption
    if S.VoidEruption:IsCastableP() then
      if HR.Cast(S.VoidEruption) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&azerite.whispers_of_the_damned.rank=0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and S.WhispersoftheDamned:AzeriteRank() == 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- dark_ascension,if=buff.voidform.down&(cooldown.mindbender.remains>0|cooldown.shadowfiend.remains>0)&azerite.whispers_of_the_damned.rank>0
    if S.DarkAscension:IsCastableP() and (Player:BuffDownP(S.VoidformBuff) and (S.Mindbender:CooldownRemainsP() > 0 or S.Shadowfiend:CooldownRemainsP() > 0) and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.DarkAscension) then return ""; end
    end
    -- void_bolt
    if S.VoidBolt:IsCastableP() then
      if HR.Cast(S.VoidBolt) then return ""; end
    end
    -- shadow_word_death,if=target.time_to_die<3|cooldown.shadow_word_death.charges=2
    if S.ShadowWordDeath:IsCastableP() and (Target:TimeToDie() < 3 or S.ShadowWordDeath:ChargesP() == 2) then
      if HR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)&target.time_to_die>200|target.time_to_die<75
    if S.SurrenderToMadness:IsCastableP() and (Player:BuffStackP(S.VoidformBuff) >= (15 + num(Player:HasHeroism())) and Target:TimeToDie() > 200 or Target:TimeToDie() < 75) then
      if HR.Cast(S.SurrenderToMadness) then return ""; end
    end
    -- dark_void
    if S.DarkVoid:IsCastableP() then
      if HR.Cast(S.DarkVoid) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- shadowfiend,if=!talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Shadowfiend:IsCastableP() and (not S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Shadowfiend) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&buff.voidform.up&talent.dark_ascension.enabled&azerite.whispers_of_the_damned.rank>0
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and Player:BuffP(S.VoidformBuff) and S.DarkAscension:IsAvailable() and S.WhispersoftheDamned:AzeriteRank() > 0) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- mindbender,if=talent.mindbender.enabled&(!talent.dark_ascension.enabled|azerite.whispers_of_the_damned.rank=0)
    if S.Mindbender:IsCastableP() and (S.Mindbender:IsAvailable() and (not S.DarkAscension:IsAvailable() or S.WhispersoftheDamned:AzeriteRank() == 0)) then
      if HR.Cast(S.Mindbender) then return ""; end
    end
    -- mind_blast,if=(dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking)|(talent.shadow_word_void.enabled&cooldown.shadow_word_void.charges=2)
    if S.MindBlast:IsCastableP() and ((Target:DebuffP(S.ShadowWordPainDebuff) and Target:DebuffP(S.VampiricTouchDebuff)) or (S.ShadowWordVoid:IsAvailable() and S.ShadowWordVoid:ChargesP() == 2)) then
      if HR.Cast(S.MindBlast) then return ""; end
    end
    -- shadow_word_death,if=!buff.voidform.up|(cooldown.shadow_word_death.charges=2&buff.voidform.stack<15)
    if S.ShadowWordDeath:IsCastableP() and (not Player:BuffP(S.VoidformBuff) or (S.ShadowWordDeath:ChargesP() == 2 and Player:BuffStackP(S.VoidformBuff) < 15)) then
      if HR.Cast(S.ShadowWordDeath) then return ""; end
    end
    -- shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if S.ShadowCrash:IsCastableP() and (10000000000 > 5 and raid_event.adds.duration < 20) then
      if HR.Cast(S.ShadowCrash) then return ""; end
    end
    -- mind_blast,if=dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking
    if S.MindBlast:IsCastableP() and (Target:DebuffP(S.ShadowWordPainDebuff) and Target:DebuffP(S.VampiricTouchDebuff)) then
      if HR.Cast(S.MindBlast) then return ""; end
    end
    -- void_torrent,if=dot.shadow_word_pain.remains>4&dot.vampiric_touch.remains>4
    if S.VoidTorrent:IsCastableP() and (Target:DebuffRemainsP(S.ShadowWordPainDebuff) > 4 and Target:DebuffRemainsP(S.VampiricTouchDebuff) > 4) then
      if HR.Cast(S.VoidTorrent) then return ""; end
    end
    -- shadow_word_pain,if=refreshable&target.time_to_die>4&!talent.misery.enabled&!talent.dark_void.enabled
    if S.ShadowWordPain:IsCastableP() and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff) and Target:TimeToDie() > 4 and not S.Misery:IsAvailable() and not S.DarkVoid:IsAvailable()) then
      if HR.Cast(S.ShadowWordPain) then return ""; end
    end
    -- vampiric_touch,if=refreshable&target.time_to_die>6|(talent.misery.enabled&dot.shadow_word_pain.refreshable)
    if S.VampiricTouch:IsCastableP() and (Target:DebuffRefreshableCP(S.VampiricTouchDebuff) and Target:TimeToDie() > 6 or (S.Misery:IsAvailable() and Target:DebuffRefreshableCP(S.ShadowWordPainDebuff))) then
      if HR.Cast(S.VampiricTouch) then return ""; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return ""; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- potion,if=buff.bloodlust.react|target.time_to_die<=80|target.health.pct<35
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 80 or Target:HealthPercentage() < 35) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- run_action_list,name=aoe,if=spell_targets.mind_sear>(5+1*talent.misery.enabled)
    if (Cache.EnemiesCount[40] > (5 + 1 * num(S.Misery:IsAvailable()))) then
      return Aoe();
    end
    -- run_action_list,name=cleave,if=active_enemies>1
    if (Cache.EnemiesCount[40] > 1) then
      return Cleave();
    end
    -- run_action_list,name=single,if=active_enemies=1
    if (Cache.EnemiesCount[40] == 1) then
      return Single();
    end
  end
end

HR.SetAPL(258, APL)
