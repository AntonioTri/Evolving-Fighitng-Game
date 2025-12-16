extends Node
class_name PlayerProgression 

enum SwordType { SWORD, FISTS }
enum DashType { ROLL, BLINK, TELEPORT_QTE }
enum ParryType { BLOCK, REFLECT, STUN_CRIT }
enum JumpType { GROUNDED, DOUBLE_JUMP }

@export var current_sword : SwordType = SwordType.SWORD
@export var current_dash : DashType = DashType.ROLL
@export var current_parry : ParryType = ParryType.BLOCK
@export var current_jump : JumpType = JumpType.GROUNDED 
@export var punch_crit_multiplier: float = 3.0
