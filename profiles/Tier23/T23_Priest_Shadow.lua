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
  WhispersoftheDamned                   = Spell(275722),
  SearingDialogue                       = Spell(272788),
  DeathThroes                           = Spell(278659),
  ThoughtHarvester                      = Spell(288340),
  SpitefulApparitions                   = Spell(277682),
  ShadowformBuff                        = Spell(232698),
  Shadowform                            = Spell(232698),
  MindBlast                             = Spell(8092),
  VampiricTouchDebuff                   = Spell(34914),
  VampiricTouch                         = Spell(34914),
  VoidEruption                          = Spell(228260),
  DarkAscension                         = Spell(280711),
  VoidformBuff                          = Spell(194249),
  MindSear                              = Spell(48045),
  HarvestedThoughtsBuff                 = Spell(288343),
  VoidBolt                              = Spell(205448),
  ShadowWordDeath                       = Spell(32379),
  SurrenderToMadness                    = Spell(193223),
  DarkVoid                              = Spell(263346),
  ShadowWordPainDebuff                  = Spell(589),
  Mindbender                            = Spell(200174),
  ShadowCrash                           = Spell(205385),
  ShadowWordPain                        = Spell(589),
  Misery                                = Spell(238558),
  VoidTorrent                           = Spell(263165),
  MindFlay                              = Spell(15407),
  ShadowWordVoid                        = Spell(205351)
};
local S = Spell.Priest.Shadow;

-- Items
if not Item.Priest then Item.Priest = {} end
Item.Priest.Shadow = {
  BattlePotionofIntellect          = Item(163222)
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
local VarMindBlastTargets = 0;
local VarSwpTraitRanksCheck = 0;
local VarVtTraitRanksCheck = 0;
local VarVtMisTraitRanksCheck = 0;
local VarVtMisSdCheck = 0;
local VarDotsUp = 0;

HL:RegisterForEvent(function()
  VarMindBlastTargets = 0
  VarSwpTraitRanksCheck = 0
  VarVtTraitRanksCheck = 0
  VarVtMisTraitRanksCheck = 0
  VarVtMisSdCheck = 0
  VarDotsUp = 0
end, "PLAYER_REGEN_ENABLED")

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

local function InsanityThreshold ()
	return S.LegacyOfTheVoid:IsAvailable() and 60 or 90;
end
local function ExecuteRange ()
	return 20;
end

local function EvaluateCycleShadowWordDeath84(TargetUnit)
  return TargetUnit:TimeToDie() < 3 or Player:BuffDownP(S.VoidformBuff)
end

local function EvaluateCycleMindBlast103(TargetUnit)
  return Cache.EnemiesCount[40] < VarMindBlastTargets
end

local function EvaluateCycleShadowWordPain114(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.ShadowWordPainDebuff) and TargetUnit:TimeToDie() > ((num(true) - 1.2 + 3.3 * Cache.EnemiesCount[40]) * VarSwpTraitRanksCheck * (1 - 0.012 * S.SearingDialogue:AzeriteRank() * Cache.EnemiesCount[40]))) and (not S.Misery:IsAvailable())
end

local function EvaluateCycleVampiricTouch133(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.VampiricTouchDebuff)) and (TargetUnit:TimeToDie() > ((1 + 3.3 * Cache.EnemiesCount[40]) * VarVtTraitRanksCheck * (1 + 0.10 * S.SearingDialogue:AzeriteRank() * Cache.EnemiesCount[40])))
end

local function EvaluateCycleVampiricTouch150(TargetUnit)
  return (TargetUnit:DebuffRefreshableCP(S.ShadowWordPainDebuff)) and ((S.Misery:IsAvailable() and TargetUnit:TimeToDie() > ((1.0 + 2.0 * Cache.EnemiesCount[40]) * VarVtMisTraitRanksCheck * (VarVtMisSdCheck * Cache.EnemiesCount[40]))))
end

local function EvaluateCycleMindSear169(TargetUnit)
  return Cache.EnemiesCount[40] > 1
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cleave, Single
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 4"; end
    end
    -- variable,name=mind_blast_targets,op=set,value=floor((4.5+azerite.whispers_of_the_damned.rank)%(1+0.27*azerite.searing_dialogue.rank))
    if (true) then
      VarMindBlastTargets = math.floor ((4.5 + S.WhispersoftheDamned:AzeriteRank()) / (1 + 0.27 * S.SearingDialogue:AzeriteRank()))
    end
    -- variable,name=swp_trait_ranks_check,op=set,value=(1-0.07*azerite.death_throes.rank+0.2*azerite.thought_harvester.rank)*(1-0.09*azerite.thought_harvester.rank*azerite.searing_dialogue.rank)
    if (true) then
      VarSwpTraitRanksCheck = (1 - 0.07 * S.DeathThroes:AzeriteRank() + 0.2 * S.ThoughtHarvester:AzeriteRank()) * (1 - 0.09 * S.ThoughtHarvester:AzeriteRank() * S.SearingDialogue:AzeriteRank())
    end
    -- variable,name=vt_trait_ranks_check,op=set,value=(1-0.04*azerite.thought_harvester.rank-0.05*azerite.spiteful_apparitions.rank)
    if (true) then
      VarVtTraitRanksCheck = (1 - 0.04 * S.ThoughtHarvester:AzeriteRank() - 0.05 * S.SpitefulApparitions:AzeriteRank())
    end
    -- variable,name=vt_mis_trait_ranks_check,op=set,value=(1-0.07*azerite.death_throes.rank-0.03*azerite.thought_harvester.rank-0.055*azerite.spiteful_apparitions.rank)*(1-0.027*azerite.thought_harvester.rank*azerite.searing_dialogue.rank)
    if (true) then
      VarVtMisTraitRanksCheck = (1 - 0.07 * S.DeathThroes:AzeriteRank() - 0.03 * S.ThoughtHarvester:AzeriteRank() - 0.055 * S.SpitefulApparitions:AzeriteRank()) * (1 - 0.027 * S.ThoughtHarvester:AzeriteRank() * S.SearingDialogue:AzeriteRank())
    end
    -- variable,name=vt_mis_sd_check,op=set,value=1-0.014*azerite.searing_dialogue.rank
    if (true) then
      VarVtMisSdCheck = 1 - 0.014 * S.SearingDialogue:AzeriteRank()
    end
    -- shadowform,if=!buff.shadowform.up
    if S.Shadowform:IsCastableP() and Player:BuffDownP(S.ShadowformBuff) and (not Player:BuffP(S.ShadowformBuff)) then
      if HR.Cast(S.Shadowform, Settings.Shadow.GCDasOffGCD.Shadowform) then return "shadowform 44"; end
    end
    -- mind_blast,if=spell_targets.mind_sear<2|azerite.thought_harvester.rank=0
    if S.MindBlast:IsReadyP() and Everyone.TargetIsValid() and (Cache.EnemiesCount[40] < 2 or S.ThoughtHarvester:AzeriteRank() == 0) then
      if HR.Cast(S.MindBlast) then return "mind_blast 50"; end
    end
    -- vampiric_touch
    if S.VampiricTouch:IsCastableP() and Player:DebuffDownP(S.VampiricTouchDebuff) and Everyone.TargetIsValid() then
      if HR.Cast(S.VampiricTouch) then return "vampiric_touch 54"; end
    end
  end
  Cleave = function()
    -- void_eruption
    if S.VoidEruption:IsReadyP() then
      if HR.Cast(S.VoidEruption) then return "void_eruption 58"; end
    end
    -- dark_ascension,if=buff.voidform.down
    if S.DarkAscension:IsReadyP() and (Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.DarkAscension) then return "dark_ascension 60"; end
    end
    -- vampiric_touch,if=!ticking&azerite.thought_harvester.rank>=1
    if S.VampiricTouch:IsCastableP() and (not Target:DebuffP(S.VampiricTouchDebuff) and S.ThoughtHarvester:AzeriteRank() >= 1) then
      if HR.Cast(S.VampiricTouch) then return "vampiric_touch 64"; end
    end
    -- mind_sear,if=buff.harvested_thoughts.up
    if S.MindSear:IsCastableP() and (Player:BuffP(S.HarvestedThoughtsBuff)) then
      if HR.Cast(S.MindSear) then return "mind_sear 74"; end
    end
    -- void_bolt
    if S.VoidBolt:IsReadyP() then
      if HR.Cast(S.VoidBolt) then return "void_bolt 78"; end
    end
    -- shadow_word_death,target_if=target.time_to_die<3|buff.voidform.down
    if S.ShadowWordDeath:IsReadyP() then
      if HR.CastCycle(S.ShadowWordDeath, 40, EvaluateCycleShadowWordDeath84) then return "shadow_word_death 88" end
    end
    -- surrender_to_madness,if=buff.voidform.stack>10+(10*buff.bloodlust.up)
    if S.SurrenderToMadness:IsReadyP() and (Player:BuffStackP(S.VoidformBuff) > 10 + (10 * num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness, Settings.Shadow.OffGCDasOffGCD.SurrenderToMadness) then return "surrender_to_madness 89"; end
    end
    -- dark_void,if=raid_event.adds.in>10&(dot.shadow_word_pain.refreshable|target.time_to_die>30)
    if S.DarkVoid:IsReadyP() and (10000000000 > 10 and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff) or Target:TimeToDie() > 30)) then
      if HR.Cast(S.DarkVoid) then return "dark_void 93"; end
    end
    -- mindbender
    if S.Mindbender:IsReadyP() then
      if HR.Cast(S.Mindbender, Settings.Shadow.GCDasOffGCD.Mindbender) then return "mindbender 97"; end
    end
    -- mind_blast,target_if=spell_targets.mind_sear<variable.mind_blast_targets
    if S.MindBlast:IsReadyP() then
      if HR.CastCycle(S.MindBlast, 40, EvaluateCycleMindBlast103) then return "mind_blast 107" end
    end
    -- shadow_crash,if=(raid_event.adds.in>5&raid_event.adds.duration<2)|raid_event.adds.duration>2
    if S.ShadowCrash:IsReadyP() and ((10000000000 > 5 and raid_event.adds.duration < 2) or raid_event.adds.duration > 2) then
      if HR.Cast(S.ShadowCrash) then return "shadow_crash 108"; end
    end
    -- shadow_word_pain,target_if=refreshable&target.time_to_die>((-1.2+3.3*spell_targets.mind_sear)*variable.swp_trait_ranks_check*(1-0.012*azerite.searing_dialogue.rank*spell_targets.mind_sear)),if=!talent.misery.enabled
    if S.ShadowWordPain:IsCastableP() then
      if HR.CastCycle(S.ShadowWordPain, 40, EvaluateCycleShadowWordPain114) then return "shadow_word_pain 128" end
    end
    -- vampiric_touch,target_if=refreshable,if=target.time_to_die>((1+3.3*spell_targets.mind_sear)*variable.vt_trait_ranks_check*(1+0.10*azerite.searing_dialogue.rank*spell_targets.mind_sear))
    if S.VampiricTouch:IsCastableP() then
      if HR.CastCycle(S.VampiricTouch, 40, EvaluateCycleVampiricTouch133) then return "vampiric_touch 145" end
    end
    -- vampiric_touch,target_if=dot.shadow_word_pain.refreshable,if=(talent.misery.enabled&target.time_to_die>((1.0+2.0*spell_targets.mind_sear)*variable.vt_mis_trait_ranks_check*(variable.vt_mis_sd_check*spell_targets.mind_sear)))
    if S.VampiricTouch:IsCastableP() then
      if HR.CastCycle(S.VampiricTouch, 40, EvaluateCycleVampiricTouch150) then return "vampiric_touch 160" end
    end
    -- void_torrent,if=buff.voidform.up
    if S.VoidTorrent:IsReadyP() and (Player:BuffP(S.VoidformBuff)) then
      if HR.Cast(S.VoidTorrent) then return "void_torrent 161"; end
    end
    -- mind_sear,target_if=spell_targets.mind_sear>1,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2
    if S.MindSear:IsCastableP() then
      if HR.CastCycle(S.MindSear, 40, EvaluateCycleMindSear169) then return "mind_sear 171" end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return "mind_flay 172"; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 174"; end
    end
  end
  Single = function()
    -- void_eruption
    if S.VoidEruption:IsReadyP() then
      if HR.Cast(S.VoidEruption) then return "void_eruption 176"; end
    end
    -- dark_ascension,if=buff.voidform.down
    if S.DarkAscension:IsReadyP() and (Player:BuffDownP(S.VoidformBuff)) then
      if HR.Cast(S.DarkAscension) then return "dark_ascension 178"; end
    end
    -- void_bolt
    if S.VoidBolt:IsReadyP() then
      if HR.Cast(S.VoidBolt) then return "void_bolt 182"; end
    end
    -- mind_sear,if=buff.harvested_thoughts.up&cooldown.void_bolt.remains>=1.5&azerite.searing_dialogue.rank>=1
    if S.MindSear:IsCastableP() and (Player:BuffP(S.HarvestedThoughtsBuff) and S.VoidBolt:CooldownRemainsP() >= 1.5 and S.SearingDialogue:AzeriteRank() >= 1) then
      if HR.Cast(S.MindSear) then return "mind_sear 184"; end
    end
    -- shadow_word_death,if=target.time_to_die<3|cooldown.shadow_word_death.charges=2|(cooldown.shadow_word_death.charges=1&cooldown.shadow_word_death.remains<gcd.max)
    if S.ShadowWordDeath:IsReadyP() and (Target:TimeToDie() < 3 or S.ShadowWordDeath:ChargesP() == 2 or (S.ShadowWordDeath:ChargesP() == 1 and S.ShadowWordDeath:CooldownRemainsP() < Player:GCD())) then
      if HR.Cast(S.ShadowWordDeath) then return "shadow_word_death 192"; end
    end
    -- surrender_to_madness,if=buff.voidform.stack>10+(10*buff.bloodlust.up)
    if S.SurrenderToMadness:IsReadyP() and (Player:BuffStackP(S.VoidformBuff) > 10 + (10 * num(Player:HasHeroism()))) then
      if HR.Cast(S.SurrenderToMadness, Settings.Shadow.OffGCDasOffGCD.SurrenderToMadness) then return "surrender_to_madness 200"; end
    end
    -- dark_void,if=raid_event.adds.in>10
    if S.DarkVoid:IsReadyP() and (10000000000 > 10) then
      if HR.Cast(S.DarkVoid) then return "dark_void 204"; end
    end
    -- mindbender,if=talent.mindbender.enabled|(buff.voidform.stack>18|target.time_to_die<15)
    if S.Mindbender:IsReadyP() and (S.Mindbender:IsAvailable() or (Player:BuffStackP(S.VoidformBuff) > 18 or Target:TimeToDie() < 15)) then
      if HR.Cast(S.Mindbender, Settings.Shadow.GCDasOffGCD.Mindbender) then return "mindbender 206"; end
    end
    -- shadow_word_death,if=!buff.voidform.up|(cooldown.shadow_word_death.charges=2&buff.voidform.stack<15)
    if S.ShadowWordDeath:IsReadyP() and (not Player:BuffP(S.VoidformBuff) or (S.ShadowWordDeath:ChargesP() == 2 and Player:BuffStackP(S.VoidformBuff) < 15)) then
      if HR.Cast(S.ShadowWordDeath) then return "shadow_word_death 212"; end
    end
    -- shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if S.ShadowCrash:IsReadyP() and (10000000000 > 5 and raid_event.adds.duration < 20) then
      if HR.Cast(S.ShadowCrash) then return "shadow_crash 220"; end
    end
    -- mind_blast,if=variable.dots_up&((raid_event.movement.in>cast_time+0.5&raid_event.movement.in<4)|!talent.shadow_word_void.enabled|buff.voidform.down|buff.voidform.stack>14&(insanity<70|charges_fractional>1.33)|buff.voidform.stack<=14&(insanity<60|charges_fractional>1.33))
    if S.MindBlast:IsReadyP() and (bool(VarDotsUp) and ((10000000000 > S.MindBlast:CastTime() + 0.5 and 10000000000 < 4) or not S.ShadowWordVoid:IsAvailable() or Player:BuffDownP(S.VoidformBuff) or Player:BuffStackP(S.VoidformBuff) > 14 and (Player:Insanity() < 70 or S.MindBlast:ChargesFractionalP() > 1.33) or Player:BuffStackP(S.VoidformBuff) <= 14 and (Player:Insanity() < 60 or S.MindBlast:ChargesFractionalP() > 1.33))) then
      if HR.Cast(S.MindBlast) then return "mind_blast 222"; end
    end
    -- void_torrent,if=dot.shadow_word_pain.remains>4&dot.vampiric_touch.remains>4&buff.voidform.up
    if S.VoidTorrent:IsReadyP() and (Target:DebuffRemainsP(S.ShadowWordPainDebuff) > 4 and Target:DebuffRemainsP(S.VampiricTouchDebuff) > 4 and Player:BuffP(S.VoidformBuff)) then
      if HR.Cast(S.VoidTorrent) then return "void_torrent 246"; end
    end
    -- shadow_word_pain,if=refreshable&target.time_to_die>4&!talent.misery.enabled&!talent.dark_void.enabled
    if S.ShadowWordPain:IsCastableP() and (Target:DebuffRefreshableCP(S.ShadowWordPainDebuff) and Target:TimeToDie() > 4 and not S.Misery:IsAvailable() and not S.DarkVoid:IsAvailable()) then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 254"; end
    end
    -- vampiric_touch,if=refreshable&target.time_to_die>6|(talent.misery.enabled&dot.shadow_word_pain.refreshable)
    if S.VampiricTouch:IsCastableP() and (Target:DebuffRefreshableCP(S.VampiricTouchDebuff) and Target:TimeToDie() > 6 or (S.Misery:IsAvailable() and Target:DebuffRefreshableCP(S.ShadowWordPainDebuff))) then
      if HR.Cast(S.VampiricTouch) then return "vampiric_touch 266"; end
    end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
    if S.MindFlay:IsCastableP() then
      if HR.Cast(S.MindFlay) then return "mind_flay 278"; end
    end
    -- shadow_word_pain
    if S.ShadowWordPain:IsCastableP() then
      if HR.Cast(S.ShadowWordPain) then return "shadow_word_pain 280"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- use_item,slot=trinket2
    -- potion,if=buff.bloodlust.react|target.time_to_die<=80|target.health.pct<35
    if I.BattlePotionofIntellect:IsReady() and Settings.Commons.UsePotions and (Player:HasHeroism() or Target:TimeToDie() <= 80 or Target:HealthPercentage() < 35) then
      if HR.CastSuggested(I.BattlePotionofIntellect) then return "battle_potion_of_intellect 283"; end
    end
    -- variable,name=dots_up,op=set,value=dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking
    if (true) then
      VarDotsUp = num(Target:DebuffP(S.ShadowWordPainDebuff) and Target:DebuffP(S.VampiricTouchDebuff))
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
