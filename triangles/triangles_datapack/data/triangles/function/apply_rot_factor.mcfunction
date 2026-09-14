
attribute @s block_interaction_range modifier remove triangles:rot_factor
$attribute @s block_interaction_range modifier add triangles:rot_factor $(rot_factor) add_multiplied_base
attribute @s entity_interaction_range modifier remove triangles:rot_factor
$attribute @s entity_interaction_range modifier add triangles:rot_factor $(rot_factor) add_multiplied_base
attribute @s attack_knockback modifier remove triangles:rot_factor
$attribute @s attack_knockback modifier add triangles:rot_factor $(rot_factor) add_multiplied_base
