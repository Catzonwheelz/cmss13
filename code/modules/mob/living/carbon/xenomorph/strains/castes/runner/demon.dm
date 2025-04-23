/datum/xeno_strain/demon
	name = RUNNER_DEMON
	description = "At the cost of your health, pounce and tail stab. You gain the ability to go at speeds yet unseen, your tail turning into a scythe to mow down that which stands against the hive. With every new level of speed, your body goes under greater and greater stress harming your health and your ability to regenerate. But with this speed, your scythe strikes ever harder."
	flavor_description = "A Demon of sinew and muscle, a creature of pure adrenaline."

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
	)
	actions_to_add = list(
		/datum/action/xeno_action/onclick/accelerate
	)

	behavior_delegate_type = /datum/behavior_delegate/runner_base

/datum/xeno_strain/demon/apply_strain(mob/living/carbon/xenomorph/runner/runner)
	runner.speed_modifier += XENO_SPEED_FASTMOD_TIER_1
	runner.health_modifier -= XENO_HEALTH_MOD_LARGE
	runner.damage_modifier += XENO_DAMAGE_MOD_VERY_SMALL
	runner.recalculate_everything()

/datum/action/xeno_action/onclick/accelerate/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if (!istype(xeno))
		return

	if (!action_cooldown_check())
		return

	if (!xeno.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	xeno.speed_modifier -= speed_buff
	xeno.recalculate_speed()

	addtimer(CALLBACK(src, PROC_REF(accelerate_off)), buff_duration, TIMER_UNIQUE)
	xeno.add_filter("accelerate_on", 1, list("type" = "outline", "color" = "#522020ff", "size" = 1)) // Dark red because the berserker is scary in this state

	apply_cooldown()
	return ..()

/datum/action/xeno_action/onclick/accelerate/proc/accelerate_off()
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.remove_filter("accelerate_on")
	if (istype(xeno))
		xeno.speed_modifier += speed_buff
		xeno.recalculate_speed()
		to_chat(xeno, SPAN_XENOHIGHDANGER("We feel our speed wane!"))
