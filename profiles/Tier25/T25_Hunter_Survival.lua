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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.Survival = {
  SummonPet                             = Spell(883),
  GuardianofAzeroth                     = Spell(),
  CoordinatedAssaultBuff                = Spell(266779),
  CoordinatedAssault                    = Spell(266779),
  WorldveinResonance                    = Spell(),
  SteelTrapDebuff                       = Spell(162487),
  SteelTrap                             = Spell(162488),
  Harpoon                               = Spell(190925),
  MongooseBite                          = Spell(259387),
  BlurofTalonsBuff                      = Spell(277969),
  RaptorStrike                          = Spell(186270),
  FlankingStrike                        = Spell(269751),
  KillCommand                           = Spell(259489),
  BloodseekerDebuff                     = Spell(259277),
  WildfireBomb                          = Spell(259495),
  WildfireBombDebuff                    = Spell(269747),
  MemoryofLucidDreamsBuff               = Spell(),
  MongooseFuryBuff                      = Spell(259388),
  SerpentSting                          = Spell(259491),
  SerpentStingDebuff                    = Spell(259491),
  AMurderofCrows                        = Spell(131894),
  TipoftheSpearBuff                     = Spell(260286),
  ShrapnelBombDebuff                    = Spell(270339),
  Chakrams                              = Spell(259391),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  Berserking                            = Spell(26297),
  BerserkingBuff                        = Spell(26297),
  GuardianofAzerothBuff                 = Spell(),
  BloodFuryBuff                         = Spell(20572),
  PotionofUnbridledFuryBuff             = Spell(),
  AspectoftheEagle                      = Spell(186289),
  RazorCoralDebuffDebuff                = Spell(),
  MemoryofLucidDreams                   = Spell(),
  WildfireInfusion                      = Spell(271014),
  FocusedAzeriteBeam                    = Spell(),
  BirdsofPrey                           = Spell(260331),
  BloodoftheEnemy                       = Spell(),
  PurifyingBlast                        = Spell(),
  RippleInSpace                         = Spell(),
  ConcentratedFlame                     = Spell(),
  TheUnboundForce                       = Spell(),
  RecklessForceBuff                     = Spell(),
  ReapingFlames                         = Spell(),
  VipersVenomBuff                       = Spell(268552),
  Carve                                 = Spell(187708),
  GuerrillaTactics                      = Spell(264332),
  LatentPoisonDebuff                    = Spell(273286),
  Butchery                              = Spell(212436),
  InternalBleedingDebuff                = Spell(270343),
  TermsofEngagement                     = Spell(265895),
  VipersVenom                           = Spell(268501),
  AlphaPredator                         = Spell(269737),
  ArcaneTorrent                         = Spell(50613),
  BagofTricks                           = Spell()
};
local S = Spell.Hunter.Survival;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Survival = {
  AzsharasFontofPower              = Item(),
  BattlePotionofAgility            = Item(163223),
  AshvanesRazorCoral               = Item(),
  DribblingInkpod                  = Item(),
  GalecallersBoon                  = Item()
};
local I = Item.Hunter.Survival;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  Survival = HR.GUISettings.APL.Hunter.Survival
};

-- Variables
local VarCarveCdr = 0;

HL:RegisterForEvent(function()
  VarCarveCdr = 0
end, "PLAYER_REGEN_ENABLED")

local EnemyRanges = {8}
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

S.WildfireBombNormal  = Spell(259495)
S.ShrapnelBomb        = Spell(270335)
S.PheromoneBomb       = Spell(270323)
S.VolatileBomb        = Spell(271045)

local WildfireInfusions = {
  S.ShrapnelBomb,
  S.PheromoneBomb,
  S.VolatileBomb,
}

local function CurrentWildfireInfusion ()
  if S.WildfireInfusion:IsAvailable() then
    for _, infusion in pairs(WildfireInfusions) do
      if infusion:IsLearned() then return infusion end
    end
  end
  return S.WildfireBombNormal
end

S.RaptorStrikeNormal  = Spell(186270)
S.RaptorStrikeEagle   = Spell(265189)
S.MongooseBiteNormal  = Spell(259387)
S.MongooseBiteEagle   = Spell(265888)

local function CurrentRaptorStrike ()
  return S.RaptorStrikeEagle:IsLearned() and S.RaptorStrikeEagle or S.RaptorStrikeNormal
end

local function CurrentMongooseBite ()
  return S.MongooseBiteEagle:IsLearned() and S.MongooseBiteEagle or S.MongooseBiteNormal
end

local function EvaluateTargetIfFilterKillCommand55(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.BloodseekerDebuff)
end

local function EvaluateTargetIfKillCommand72(TargetUnit)
  return S.KillCommand:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax()
end

local function EvaluateTargetIfFilterKillCommand134(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.BloodseekerDebuff)
end

local function EvaluateTargetIfKillCommand153(TargetUnit)
  return Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and (Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())
end

local function EvaluateCycleCarveCdr496(TargetUnit)
  return (Cache.EnemiesCount[8] < 5) and (Cache.EnemiesCount[8] < 5)
end

local function EvaluateTargetIfFilterMongooseBite532(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function EvaluateTargetIfMongooseBite541(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff) == 10
end

local function EvaluateTargetIfFilterKillCommand549(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.BloodseekerDebuff)
end

local function EvaluateTargetIfKillCommand562(TargetUnit)
  return Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax()
end

local function EvaluateTargetIfFilterSerpentSting598(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff)
end

local function EvaluateTargetIfSerpentSting615(TargetUnit)
  return bool(Player:BuffStackP(S.VipersVenomBuff))
end

local function EvaluateTargetIfFilterSerpentSting633(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.SerpentStingDebuff)
end

local function EvaluateTargetIfSerpentSting656(TargetUnit)
  return TargetUnit:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffStackP(S.TipoftheSpearBuff) < 3
end

local function EvaluateTargetIfFilterMongooseBite662(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function EvaluateTargetIfFilterRaptorStrike673(TargetUnit)
  return TargetUnit:DebuffStackP(S.LatentPoisonDebuff)
end

local function EvaluateTargetIfFilterKillCommand716(TargetUnit)
  return TargetUnit:DebuffRemainsP(S.BloodseekerDebuff)
end

local function EvaluateTargetIfKillCommand729(TargetUnit)
  return Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax()
end
--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Apst, Apwfi, Cds, Cleave, St, Wfi
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  S.WildfireBomb = CurrentWildfireInfusion()
  S.RaptorStrike = CurrentRaptorStrike()
  S.MongooseBite = CurrentMongooseBite()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet, Settings.Survival.GCDasOffGCD.SummonPet) then return "summon_pet 3"; end
    end
    -- snapshot_stats
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 6"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 8"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and Player:BuffDownP(S.CoordinatedAssaultBuff) and HR.CDsON() then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 10"; end
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 14"; end
    end
    -- potion,dynamic_prepot=1
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 16"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() and Player:DebuffDownP(S.SteelTrapDebuff) and Everyone.TargetIsValid() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 18"; end
    end
    -- harpoon
    if S.Harpoon:IsCastableP() and Everyone.TargetIsValid() then
      if HR.Cast(S.Harpoon, Settings.Survival.GCDasOffGCD.Harpoon) then return "harpoon 22"; end
    end
  end
  Apst = function()
    -- mongoose_bite,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 24"; end
    end
    -- raptor_strike,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 34"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 44"; end
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() then
      if HR.CastTargetIf(S.KillCommand, 8, "min", EvaluateTargetIfFilterKillCommand55, EvaluateTargetIfKillCommand72) then return "kill_command 74" end
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.SteelTrap) then return "steel_trap 75"; end
    end
    -- wildfire_bomb,if=focus+cast_regen<focus.max&!ticking&!buff.memory_of_lucid_dreams.up&(full_recharge_time<1.5*gcd|!dot.wildfire_bomb.ticking&!buff.coordinated_assault.up|!dot.wildfire_bomb.ticking&buff.mongoose_fury.stack<1)|time_to_die<18&!dot.wildfire_bomb.ticking
    if S.WildfireBomb:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.MemoryofLucidDreamsBuff) and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff) or not Target:DebuffP(S.WildfireBombDebuff) and Player:BuffStackP(S.MongooseFuryBuff) < 1) or Target:TimeToDie() < 18 and not Target:DebuffP(S.WildfireBombDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 85"; end
    end
    -- serpent_sting,if=!dot.serpent_sting.ticking&!buff.coordinated_assault.up
    if S.SerpentSting:IsReadyP() and (not Target:DebuffP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 125"; end
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() then
      if HR.CastTargetIf(S.KillCommand, 8, "min", EvaluateTargetIfFilterKillCommand134, EvaluateTargetIfKillCommand153) then return "kill_command 155" end
    end
    -- serpent_sting,if=refreshable&!buff.coordinated_assault.up&buff.mongoose_fury.stack<5
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff) and Player:BuffStackP(S.MongooseFuryBuff) < 5) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 156"; end
    end
    -- a_murder_of_crows,if=!buff.coordinated_assault.up
    if S.AMurderofCrows:IsCastableP() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.AMurderofCrows, Settings.Survival.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 168"; end
    end
    -- coordinated_assault,if=!buff.coordinated_assault.up
    if S.CoordinatedAssault:IsCastableP() and HR.CDsON() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 172"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus+cast_regen>focus.max-10|buff.coordinated_assault.up
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 10 or Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 176"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 188"; end
    end
    -- wildfire_bomb,if=!ticking
    if S.WildfireBomb:IsCastableP() and (not Target:DebuffP(S.WildfireBombDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 190"; end
    end
  end
  Apwfi = function()
    -- mongoose_bite,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 198"; end
    end
    -- raptor_strike,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 204"; end
    end
    -- serpent_sting,if=!dot.serpent_sting.ticking
    if S.SerpentSting:IsReadyP() and (not Target:DebuffP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 210"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Survival.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 214"; end
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd|focus+cast_regen<focus.max&(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) and Target:DebuffRefreshableCP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 216"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 252"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.remains&next_wi_bomb.pheromone
    if S.MongooseBite:IsReadyP() and (bool(Player:BuffRemainsP(S.MongooseFuryBuff)) and S.PheromoneBomb:IsLearned()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 254"; end
    end
    -- kill_command,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max-20
    if S.KillCommand:IsCastableP() and (S.KillCommand:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() - 20) then
      if HR.Cast(S.KillCommand) then return "kill_command 258"; end
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.SteelTrap) then return "steel_trap 270"; end
    end
    -- raptor_strike,if=buff.tip_of_the_spear.stack=3|dot.shrapnel_bomb.ticking
    if S.RaptorStrike:IsReadyP() and (Player:BuffStackP(S.TipoftheSpearBuff) == 3 or Target:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 280"; end
    end
    -- mongoose_bite,if=dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 286"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&focus>30&dot.serpent_sting.remains>5*gcd
    if S.WildfireBomb:IsCastableP() and (S.ShrapnelBomb:IsLearned() and Player:Focus() > 30 and Target:DebuffRemainsP(S.SerpentStingDebuff) > 5 * Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 290"; end
    end
    -- chakrams,if=!buff.mongoose_fury.remains
    if S.Chakrams:IsCastableP() and (not bool(Player:BuffRemainsP(S.MongooseFuryBuff))) then
      if HR.Cast(S.Chakrams) then return "chakrams 294"; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 298"; end
    end
    -- kill_command,if=focus+cast_regen<focus.max&(buff.mongoose_fury.stack<5|focus<action.mongoose_bite.cost)
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and (Player:BuffStackP(S.MongooseFuryBuff) < 5 or Player:Focus() < S.MongooseBite:Cost())) then
      if HR.Cast(S.KillCommand) then return "kill_command 306"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 320"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus>40|dot.shrapnel_bomb.ticking
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 40 or Target:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 322"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel&focus>50
    if S.WildfireBomb:IsCastableP() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() or S.ShrapnelBomb:IsLearned() and Player:Focus() > 50) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 328"; end
    end
  end
  Cds = function()
    -- blood_fury,if=cooldown.coordinated_assault.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 332"; end
    end
    -- ancestral_call,if=cooldown.coordinated_assault.remains>30
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 336"; end
    end
    -- fireblood,if=cooldown.coordinated_assault.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 340"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 344"; end
    end
    -- berserking,if=cooldown.coordinated_assault.remains>60|time_to_die<13
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.CoordinatedAssault:CooldownRemainsP() > 60 or Target:TimeToDie() < 13) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 346"; end
    end
    -- potion,if=buff.guardian_of_azeroth.up&(buff.berserking.up|buff.blood_fury.up|!race.troll)|(consumable.potion_of_unbridled_fury&target.time_to_die<61|target.time_to_die<26)|!essence.condensed_lifeforce.major&buff.coordinated_assault.up
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.GuardianofAzerothBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll")) or (Player:Buff(S.PotionofUnbridledFuryBuff) and Target:TimeToDie() < 61 or Target:TimeToDie() < 26) or not bool(essence.condensed_lifeforce.major) and Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 356"; end
    end
    -- aspect_of_the_eagle,if=target.distance>=6
    if S.AspectoftheEagle:IsCastableP() and HR.CDsON() and (target.distance >= 6) then
      if HR.Cast(S.AspectoftheEagle, Settings.Survival.OffGCDasOffGCD.AspectoftheEagle) then return "aspect_of_the_eagle 368"; end
    end
    -- use_item,name=ashvanes_razor_coral,if=equipped.dribbling_inkpod&(debuff.razor_coral_debuff.down|time_to_pct_30<1|(health.pct<30&buff.guardian_of_azeroth.up|buff.memory_of_lucid_dreams.up))|(!equipped.dribbling_inkpod&(buff.memory_of_lucid_dreams.up|buff.guardian_of_azeroth.up&cooldown.guardian_of_azeroth.remains>175)|debuff.razor_coral_debuff.down)|target.time_to_die<20
    if I.AshvanesRazorCoral:IsReady() and (I.DribblingInkpod:IsEquipped() and (Target:DebuffDownP(S.RazorCoralDebuffDebuff) or time_to_pct_30 < 1 or (health.pct < 30 and Player:BuffP(S.GuardianofAzerothBuff) or Player:BuffP(S.MemoryofLucidDreamsBuff))) or (not I.DribblingInkpod:IsEquipped() and (Player:BuffP(S.MemoryofLucidDreamsBuff) or Player:BuffP(S.GuardianofAzerothBuff) and S.GuardianofAzeroth:CooldownRemainsP() > 175) or Target:DebuffDownP(S.RazorCoralDebuffDebuff)) or Target:TimeToDie() < 20) then
      if HR.CastSuggested(I.AshvanesRazorCoral) then return "ashvanes_razor_coral 370"; end
    end
    -- use_item,name=galecallers_boon,if=cooldown.memory_of_lucid_dreams.remains|talent.wildfire_infusion.enabled&cooldown.coordinated_assault.remains|!essence.memory_of_lucid_dreams.major&cooldown.coordinated_assault.remains
    if I.GalecallersBoon:IsReady() and (bool(S.MemoryofLucidDreams:CooldownRemainsP()) or S.WildfireInfusion:IsAvailable() and bool(S.CoordinatedAssault:CooldownRemainsP()) or not bool(essence.memory_of_lucid_dreams.major) and bool(S.CoordinatedAssault:CooldownRemainsP())) then
      if HR.CastSuggested(I.GalecallersBoon) then return "galecallers_boon 390"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsReady() then
      if HR.CastSuggested(I.AzsharasFontofPower) then return "azsharas_font_of_power 400"; end
    end
    -- focused_azerite_beam,if=raid_event.adds.in>90&focus<focus.max-25|(active_enemies>1&!talent.birds_of_prey.enabled|active_enemies>2)&(buff.blur_of_talons.up&buff.blur_of_talons.remains>3*gcd|!buff.blur_of_talons.up)
    if S.FocusedAzeriteBeam:IsCastableP() and (10000000000 > 90 and Player:Focus() < Player:FocusMax() - 25 or (Cache.EnemiesCount[8] > 1 and not S.BirdsofPrey:IsAvailable() or Cache.EnemiesCount[8] > 2) and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) > 3 * Player:GCD() or not Player:BuffP(S.BlurofTalonsBuff))) then
      if HR.Cast(S.FocusedAzeriteBeam) then return "focused_azerite_beam 402"; end
    end
    -- blood_of_the_enemy,if=buff.coordinated_assault.up
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.BloodoftheEnemy) then return "blood_of_the_enemy 424"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast) then return "purifying_blast 428"; end
    end
    -- guardian_of_azeroth
    if S.GuardianofAzeroth:IsCastableP() then
      if HR.Cast(S.GuardianofAzeroth) then return "guardian_of_azeroth 430"; end
    end
    -- ripple_in_space
    if S.RippleInSpace:IsCastableP() then
      if HR.Cast(S.RippleInSpace) then return "ripple_in_space 432"; end
    end
    -- concentrated_flame,if=full_recharge_time<1*gcd
    if S.ConcentratedFlame:IsCastableP() and (S.ConcentratedFlame:FullRechargeTimeP() < 1 * Player:GCD()) then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 434"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff)) then
      if HR.Cast(S.TheUnboundForce) then return "the_unbound_force 440"; end
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance) then return "worldvein_resonance 444"; end
    end
    -- reaping_flames,if=target.health.pct>80|target.health.pct<=20|target.time_to_pct_20>30
    if S.ReapingFlames:IsCastableP() and (Target:HealthPercentage() > 80 or Target:HealthPercentage() <= 20 or target.time_to_pct_20 > 30) then
      if HR.Cast(S.ReapingFlames) then return "reaping_flames 446"; end
    end
    -- serpent_sting,if=essence.memory_of_lucid_dreams.major&refreshable&buff.vipers_venom.up&!cooldown.memory_of_lucid_dreams.remains
    if S.SerpentSting:IsReadyP() and (bool(essence.memory_of_lucid_dreams.major) and Target:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffP(S.VipersVenomBuff) and not bool(S.MemoryofLucidDreams:CooldownRemainsP())) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 448"; end
    end
    -- mongoose_bite,if=essence.memory_of_lucid_dreams.major&!cooldown.memory_of_lucid_dreams.remains
    if S.MongooseBite:IsReadyP() and (bool(essence.memory_of_lucid_dreams.major) and not bool(S.MemoryofLucidDreams:CooldownRemainsP())) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 460"; end
    end
    -- wildfire_bomb,if=essence.memory_of_lucid_dreams.major&full_recharge_time<1.5*gcd&focus<action.mongoose_bite.cost&!cooldown.memory_of_lucid_dreams.remains
    if S.WildfireBomb:IsCastableP() and (bool(essence.memory_of_lucid_dreams.major) and S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() < S.MongooseBite:Cost() and not bool(S.MemoryofLucidDreams:CooldownRemainsP())) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 464"; end
    end
    -- memory_of_lucid_dreams,if=focus<action.mongoose_bite.cost&buff.coordinated_assault.up
    if S.MemoryofLucidDreams:IsCastableP() and (Player:Focus() < S.MongooseBite:Cost() and Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.MemoryofLucidDreams) then return "memory_of_lucid_dreams 478"; end
    end
  end
  Cleave = function()
    -- variable,name=carve_cdr,op=setif,value=active_enemies,value_else=5,condition=active_enemies<5
    if  then
      if HR.CastCycle(VarCarveCdr, 8, EvaluateCycleCarveCdr496) then return "carve_cdr 510" end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Survival.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 511"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 513"; end
    end
    -- carve,if=dot.shrapnel_bomb.ticking
    if S.Carve:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff)) then
      if HR.Cast(S.Carve) then return "carve 515"; end
    end
    -- wildfire_bomb,if=!talent.guerrilla_tactics.enabled|full_recharge_time<gcd
    if S.WildfireBomb:IsCastableP() and (not S.GuerrillaTactics:IsAvailable() or S.WildfireBomb:FullRechargeTimeP() < Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 519"; end
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack,if=debuff.latent_poison.stack=10
    if S.MongooseBite:IsReadyP() then
      if HR.CastTargetIf(S.MongooseBite, 8, "max", EvaluateTargetIfFilterMongooseBite532, EvaluateTargetIfMongooseBite541) then return "mongoose_bite 543" end
    end
    -- chakrams
    if S.Chakrams:IsCastableP() then
      if HR.Cast(S.Chakrams) then return "chakrams 544"; end
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() then
      if HR.CastTargetIf(S.KillCommand, 8, "min", EvaluateTargetIfFilterKillCommand549, EvaluateTargetIfKillCommand562) then return "kill_command 564" end
    end
    -- butchery,if=full_recharge_time<gcd|!talent.wildfire_infusion.enabled|dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3
    if S.Butchery:IsCastableP() and (S.Butchery:FullRechargeTimeP() < Player:GCD() or not S.WildfireInfusion:IsAvailable() or Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleedingDebuff) < 3) then
      if HR.Cast(S.Butchery, Settings.Survival.GCDasOffGCD.Butchery) then return "butchery 565"; end
    end
    -- carve,if=talent.guerrilla_tactics.enabled
    if S.Carve:IsReadyP() and (S.GuerrillaTactics:IsAvailable()) then
      if HR.Cast(S.Carve) then return "carve 577"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 581"; end
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable|talent.wildfire_infusion.enabled
    if S.WildfireBomb:IsCastableP() and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) or S.WildfireInfusion:IsAvailable()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 589"; end
    end
    -- serpent_sting,target_if=min:remains,if=buff.vipers_venom.react
    if S.SerpentSting:IsReadyP() then
      if HR.CastTargetIf(S.SerpentSting, 8, "min", EvaluateTargetIfFilterSerpentSting598, EvaluateTargetIfSerpentSting615) then return "serpent_sting 617" end
    end
    -- carve,if=cooldown.wildfire_bomb.remains>variable.carve_cdr%2
    if S.Carve:IsReadyP() and (S.WildfireBomb:CooldownRemainsP() > VarCarveCdr / 2) then
      if HR.Cast(S.Carve) then return "carve 618"; end
    end
    -- steel_trap
    if S.SteelTrap:IsCastableP() then
      if HR.Cast(S.SteelTrap) then return "steel_trap 624"; end
    end
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
      if HR.Cast(S.Harpoon, Settings.Survival.GCDasOffGCD.Harpoon) then return "harpoon 626"; end
    end
    -- serpent_sting,target_if=min:remains,if=refreshable&buff.tip_of_the_spear.stack<3
    if S.SerpentSting:IsReadyP() then
      if HR.CastTargetIf(S.SerpentSting, 8, "min", EvaluateTargetIfFilterSerpentSting633, EvaluateTargetIfSerpentSting656) then return "serpent_sting 658" end
    end
    -- mongoose_bite,target_if=max:debuff.latent_poison.stack
    if S.MongooseBite:IsReadyP() then
      if HR.CastTargetIf(S.MongooseBite, 8, "max", EvaluateTargetIfFilterMongooseBite662) then return "mongoose_bite 669" end
    end
    -- raptor_strike,target_if=max:debuff.latent_poison.stack
    if S.RaptorStrike:IsReadyP() then
      if HR.CastTargetIf(S.RaptorStrike, 8, "max", EvaluateTargetIfFilterRaptorStrike673) then return "raptor_strike 680" end
    end
  end
  St = function()
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (S.TermsofEngagement:IsAvailable()) then
      if HR.Cast(S.Harpoon, Settings.Survival.GCDasOffGCD.Harpoon) then return "harpoon 681"; end
    end
    -- flanking_strike,if=focus+cast_regen<focus.max
    if S.FlankingStrike:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.FlankingStrike:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.FlankingStrike) then return "flanking_strike 685"; end
    end
    -- raptor_strike,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 693"; end
    end
    -- mongoose_bite,if=buff.coordinated_assault.up&(buff.coordinated_assault.remains<1.5*gcd|buff.blur_of_talons.up&buff.blur_of_talons.remains<1.5*gcd)
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffRemainsP(S.CoordinatedAssaultBuff) < 1.5 * Player:GCD() or Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < 1.5 * Player:GCD())) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 703"; end
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max
    if S.KillCommand:IsCastableP() then
      if HR.CastTargetIf(S.KillCommand, 8, "min", EvaluateTargetIfFilterKillCommand716, EvaluateTargetIfKillCommand729) then return "kill_command 731" end
    end
    -- serpent_sting,if=buff.vipers_venom.up&buff.vipers_venom.remains<1*gcd
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Player:BuffRemainsP(S.VipersVenomBuff) < 1 * Player:GCD()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 732"; end
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.SteelTrap) then return "steel_trap 738"; end
    end
    -- wildfire_bomb,if=focus+cast_regen<focus.max&!ticking&!buff.memory_of_lucid_dreams.up&(full_recharge_time<1.5*gcd|!dot.wildfire_bomb.ticking&!buff.coordinated_assault.up|!dot.wildfire_bomb.ticking&buff.mongoose_fury.stack<1)|time_to_die<18&!dot.wildfire_bomb.ticking
    if S.WildfireBomb:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() and not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.MemoryofLucidDreamsBuff) and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() or not Target:DebuffP(S.WildfireBombDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff) or not Target:DebuffP(S.WildfireBombDebuff) and Player:BuffStackP(S.MongooseFuryBuff) < 1) or Target:TimeToDie() < 18 and not Target:DebuffP(S.WildfireBombDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 748"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up&dot.serpent_sting.remains<4*gcd|dot.serpent_sting.refreshable&!buff.coordinated_assault.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Target:DebuffRemainsP(S.SerpentStingDebuff) < 4 * Player:GCD() or Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 788"; end
    end
    -- a_murder_of_crows,if=!buff.coordinated_assault.up
    if S.AMurderofCrows:IsCastableP() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.AMurderofCrows, Settings.Survival.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 798"; end
    end
    -- coordinated_assault,if=!buff.coordinated_assault.up
    if S.CoordinatedAssault:IsCastableP() and HR.CDsON() and (not Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 802"; end
    end
    -- mongoose_bite,if=buff.mongoose_fury.up|focus+cast_regen>focus.max-20&talent.vipers_venom.enabled|focus+cast_regen>focus.max-1&talent.terms_of_engagement.enabled|buff.coordinated_assault.up
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 20 and S.VipersVenom:IsAvailable() or Player:Focus() + Player:FocusCastRegen(S.MongooseBite:ExecuteTime()) > Player:FocusMax() - 1 and S.TermsofEngagement:IsAvailable() or Player:BuffP(S.CoordinatedAssaultBuff)) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 806"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 828"; end
    end
    -- wildfire_bomb,if=dot.wildfire_bomb.refreshable
    if S.WildfireBomb:IsCastableP() and (Target:DebuffRefreshableCP(S.WildfireBombDebuff)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 830"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 834"; end
    end
  end
  Wfi = function()
    -- harpoon,if=focus+cast_regen<focus.max&talent.terms_of_engagement.enabled
    if S.Harpoon:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.Harpoon:ExecuteTime()) < Player:FocusMax() and S.TermsofEngagement:IsAvailable()) then
      if HR.Cast(S.Harpoon, Settings.Survival.GCDasOffGCD.Harpoon) then return "harpoon 838"; end
    end
    -- mongoose_bite,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.MongooseBite:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 848"; end
    end
    -- raptor_strike,if=buff.blur_of_talons.up&buff.blur_of_talons.remains<gcd
    if S.RaptorStrike:IsReadyP() and (Player:BuffP(S.BlurofTalonsBuff) and Player:BuffRemainsP(S.BlurofTalonsBuff) < Player:GCD()) then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 854"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up&buff.vipers_venom.remains<1.5*gcd|!dot.serpent_sting.ticking
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Player:BuffRemainsP(S.VipersVenomBuff) < 1.5 * Player:GCD() or not Target:DebuffP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 860"; end
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd&focus+cast_regen<focus.max|(next_wi_bomb.volatile&dot.serpent_sting.ticking&dot.serpent_sting.refreshable|next_wi_bomb.pheromone&!buff.mongoose_fury.up&focus+cast_regen<focus.max-action.kill_command.cast_regen*3)
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD() and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() or (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) and Target:DebuffRefreshableCP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() and not Player:BuffP(S.MongooseFuryBuff) and Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() - Player:FocusCastRegen(S.KillCommand:ExecuteTime()) * 3)) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 868"; end
    end
    -- kill_command,if=focus+cast_regen<focus.max-focus.regen
    if S.KillCommand:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() - Player:FocusRegen()) then
      if HR.Cast(S.KillCommand) then return "kill_command 904"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Survival.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 912"; end
    end
    -- steel_trap,if=focus+cast_regen<focus.max
    if S.SteelTrap:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.SteelTrap:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.SteelTrap) then return "steel_trap 914"; end
    end
    -- wildfire_bomb,if=full_recharge_time<1.5*gcd
    if S.WildfireBomb:IsCastableP() and (S.WildfireBomb:FullRechargeTimeP() < 1.5 * Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 924"; end
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.CoordinatedAssault, Settings.Survival.GCDasOffGCD.CoordinatedAssault) then return "coordinated_assault 932"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up&dot.serpent_sting.remains<4*gcd
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff) and Target:DebuffRemainsP(S.SerpentStingDebuff) < 4 * Player:GCD()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 934"; end
    end
    -- mongoose_bite,if=dot.shrapnel_bomb.ticking|buff.mongoose_fury.stack=5
    if S.MongooseBite:IsReadyP() and (Target:DebuffP(S.ShrapnelBombDebuff) or Player:BuffStackP(S.MongooseFuryBuff) == 5) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 940"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.shrapnel&dot.serpent_sting.remains>5*gcd
    if S.WildfireBomb:IsCastableP() and (S.ShrapnelBomb:IsLearned() and Target:DebuffRemainsP(S.SerpentStingDebuff) > 5 * Player:GCD()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 946"; end
    end
    -- serpent_sting,if=refreshable
    if S.SerpentSting:IsReadyP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 950"; end
    end
    -- chakrams,if=!buff.mongoose_fury.remains
    if S.Chakrams:IsCastableP() and (not bool(Player:BuffRemainsP(S.MongooseFuryBuff))) then
      if HR.Cast(S.Chakrams) then return "chakrams 958"; end
    end
    -- mongoose_bite
    if S.MongooseBite:IsReadyP() then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 962"; end
    end
    -- raptor_strike
    if S.RaptorStrike:IsReadyP() then
      if HR.Cast(S.RaptorStrike) then return "raptor_strike 964"; end
    end
    -- serpent_sting,if=buff.vipers_venom.up
    if S.SerpentSting:IsReadyP() and (Player:BuffP(S.VipersVenomBuff)) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 966"; end
    end
    -- wildfire_bomb,if=next_wi_bomb.volatile&dot.serpent_sting.ticking|next_wi_bomb.pheromone|next_wi_bomb.shrapnel
    if S.WildfireBomb:IsCastableP() and (S.VolatileBomb:IsLearned() and Target:DebuffP(S.SerpentStingDebuff) or S.PheromoneBomb:IsLearned() or S.ShrapnelBomb:IsLearned()) then
      if HR.Cast(S.WildfireBomb) then return "wildfire_bomb 970"; end
    end
  end
  if Everyone.TargetIsValid() then
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
    -- auto_attack
    -- use_items
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- mongoose_bite,if=active_enemies=1&target.time_to_die<focus%(action.mongoose_bite.cost-cast_regen)*gcd
    if S.MongooseBite:IsReadyP() and (Cache.EnemiesCount[8] == 1 and Target:TimeToDie() < Player:Focus() / (S.MongooseBite:Cost() - Player:FocusCastRegen(S.MongooseBite:ExecuteTime())) * Player:GCD()) then
      if HR.Cast(S.MongooseBite) then return "mongoose_bite 979"; end
    end
    -- call_action_list,name=apwfi,if=active_enemies<3&talent.chakrams.enabled&talent.alpha_predator.enabled
    if (Cache.EnemiesCount[8] < 3 and S.Chakrams:IsAvailable() and S.AlphaPredator:IsAvailable()) then
      local ShouldReturn = Apwfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=wfi,if=active_enemies<3&talent.chakrams.enabled
    if (Cache.EnemiesCount[8] < 3 and S.Chakrams:IsAvailable()) then
      local ShouldReturn = Wfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3&!talent.alpha_predator.enabled&!talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and not S.AlphaPredator:IsAvailable() and not S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=apst,if=active_enemies<3&talent.alpha_predator.enabled&!talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and S.AlphaPredator:IsAvailable() and not S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Apst(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=apwfi,if=active_enemies<3&talent.alpha_predator.enabled&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and S.AlphaPredator:IsAvailable() and S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Apwfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=wfi,if=active_enemies<3&!talent.alpha_predator.enabled&talent.wildfire_infusion.enabled
    if (Cache.EnemiesCount[8] < 3 and not S.AlphaPredator:IsAvailable() and S.WildfireInfusion:IsAvailable()) then
      local ShouldReturn = Wfi(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cleave,if=active_enemies>1&!talent.birds_of_prey.enabled|active_enemies>2
    if (Cache.EnemiesCount[8] > 1 and not S.BirdsofPrey:IsAvailable() or Cache.EnemiesCount[8] > 2) then
      local ShouldReturn = Cleave(); if ShouldReturn then return ShouldReturn; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      if HR.Cast(S.ConcentratedFlame) then return "concentrated_flame 1083"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 1085"; end
    end
    -- bag_of_tricks
    if S.BagofTricks:IsCastableP() then
      if HR.Cast(S.BagofTricks) then return "bag_of_tricks 1087"; end
    end
  end
end

HR.SetAPL(255, APL)
