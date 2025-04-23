/datum/xeno_strain/demon
	name = RUNNER_DEMON
	description = "At the cost of your health, pounce and tail stab. You gain the ability to go at speeds yet unseen, your tail turning into a scythe to mow down that which stands against the hive. With every new level of speed, your body goes under greater and greater stress harming your health and your ability to regenerate. But with this speed, your scythe strikes ever harder."
	flavor_description = "A Demon of sinew and muscle, a creature of pure adrenaline."

	actions_to_remove = list(
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
	)
	actions_to_add = list(
		/datum/action/xeno_action/onclick/accelerate,
		/datum/action/xeno_action/activable/Tail_scythe,
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

//Tail scythe
/datum/action/xeno_action/activable/Tail_scythe/use_ability(atom/target_atom)
	var/mob/living/carbon/xenomorph/runner_user = owner

	if (!action_cooldown_check())
		return

	if (!runner_user.check_state())
		return

	// Get line of turfs
	var/list/turf/target_turfs = list()

	var/facing = Get_Compass_Dir(runner_user, target_atom)
	var/turf/turf = runner_user.loc
	var/turf/temp = runner_user.loc
	var/list/telegraph_atom_list = list()

		// Prevent targeting the front-facing direction
	if (facing == runner_user.dir)
		return

	for (var/step in 0 to 1)
		temp = get_step(turf, facing)
		if(facing in GLOB.diagonals) // check if it goes through corners
			var/reverse_face = GLOB.reverse_dir[facing]

			var/turf/back_left = get_step(temp, turn(reverse_face, 45))
			var/turf/back_right = get_step(temp, turn(reverse_face, -45))
			if((!back_left || back_left.density) && (!back_right || back_right.density))
				break
		if(!temp || temp.density || temp.opacity)
			break

		turf = temp
		target_turfs += turf
		telegraph_atom_list += new /obj/effect/xenomorph/xeno_telegraph/red(turf, 0.25 SECONDS)

	// Extract our 'optimal' turf, if it exists
	if (length(target_turfs) >= 2)
		runner_user.animation_attack_on(target_turfs[length(target_turfs)], 15)

	// Hmm today I will kill a marine while looking away from them
	runner_user.face_atom(target_atom)
	runner_user.emote("roar")
	runner_user.visible_message(SPAN_XENODANGER("[runner_user] sweeps its claws through the area in front of it!"), SPAN_XENODANGER("We sweep our claws through the area in front of us!"))

	// Loop through our turfs, finding any humans there and dealing damage to them
	for (var/turf/target_turf in target_turfs)
		for (var/mob/living/carbon/carbon_target in target_turf)
			if (carbon_target.stat == DEAD)
				continue

			if (HAS_TRAIT(carbon_target, TRAIT_NESTED))
				continue

			if(runner_user.can_not_harm(carbon_target))
				continue
			runner_user.flick_attack_overlay(carbon_target, "slash")
			carbon_target.apply_armoured_damage(damage, ARMOR_MELEE, BRUTE)
			playsound(get_turf(carbon_target), "alien_claw_flesh", 30, TRUE)

	apply_cooldown()
	return ..()
