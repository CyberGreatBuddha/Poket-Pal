import 'response_tracker.dart';
import 'skill_evaluator_balancing.dart';

// DifficultyModel pro Pal ist monoton (resolved) -- der Evaluator kennt daher
// keine "levelDown"-Entscheidung. Bei anhaltend negativem Skill Gap wird statt
// eines Downgrades angeboten, einen neuen Pal auf passenderem Level zu starten.
enum SkillDecisionKind { holdLevel, levelUp, offerNewPal }

class SkillEvaluator {
  const SkillEvaluator();

  SkillDecisionKind evaluate(SkillSignal? signal) {
    if (signal == null) {
      return SkillDecisionKind.holdLevel;
    }
    if (signal.averageCorrectness >= SkillEvaluatorBalancing.levelUpCorrectnessThreshold) {
      return SkillDecisionKind.levelUp;
    }
    if (signal.averageCorrectness <= SkillEvaluatorBalancing.newPalOfferCorrectnessThreshold) {
      return SkillDecisionKind.offerNewPal;
    }
    return SkillDecisionKind.holdLevel;
  }
}
