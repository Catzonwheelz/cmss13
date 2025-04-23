/datum/xeno_strain/demon
	name = RUNNER_DEMON
	description = "At the cost of your health, pounce and tail stab. You gain the ability to go at speeds yet unseen, your tail turning into a scythe to mow down that which stands against the hive. With every new level of speed, your body goes under greater and greater stress harming your health and your ability to regenerate. But with this speed, your scythe strikes ever harder."
	flavor_description = "A Demon of sinew and muscle, a creature of pure adrenaline."

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
	)

	behavior_delegate_type = /datum/behavior_delegate/runner_base

/datum/xeno_strain/demon/apply_strain(mob/living/carbon/xenomorph/runner/runner)
	runner.speed_modifier += XENO_SPEED_FASTMOD_TIER_10
	runner.recalculate_everything()
