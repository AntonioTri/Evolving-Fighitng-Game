extends Node
class_name ComboSystem

# ===================================================================
#  PROPRIETÀ EXPORT E RIFERIMENTI
# ===================================================================

@export var first_attack: ComboAttack
@export var animator : AnimationPlayer = null

# Assumo che player sia definito nella classe base o che questo script sia figlio diretto del player.
# Se il Player è il nonno, usa get_parent().get_parent()
@onready var player: Player = $".." 

# ===================================================================
#  STATO INTERNO
# ===================================================================

var current_attack: ComboAttack = null # L'attacco attualmente in esecuzione.
var queued_attack: ComboAttack = null # L'attacco in coda, premuto nella finestra can_chain.
var can_chain := false # Finestra in cui è possibile mettere in coda il prossimo attacco.
var in_recovery := false # Finestra in cui non si può concatenare o mettere in coda.

# Il segnale usato per comunicare con l'attack state del player.
# L'AttackState lo userà per transizionare ad Idle/Move.
signal attack_ended

# ===================================================================
#  LIFECYCLE E CHIAMATE ESTERNE (CHIAMATO DALL'ATTACK STATE)
# ===================================================================

func _ready() -> void:
	# Colleghiamo il segnale dell'AnimationPlayer qui per gestire la fine dell'attacco.
	if animator:
		animator.animation_finished.connect(_on_animation_player_animation_finished)
	#Colleghiamo il segnale per gestire il parry
	player.parried.connect(_on_player_stunned)


# Chiamato dall'AttackState quando viene premuto l'input Attack
func start_combo():
	# Caso 1: Non stiamo attaccando (primo attacco o dopo reset completo)
	if current_attack == null:
		_make_first_attack()
		return

	# Caso 2: Siamo nella finestra di concatenazione e c'è un prossimo attacco e non in recovery
	if can_chain and current_attack.next_attack and not in_recovery:
		_enqueue_next_attack()


# ===================================================================
#  LOGICA DI ESECUZIONE (CHIAMATO DA start_combo o dai segnali)
# ===================================================================

# Funzione per eseguire il primo attacco della combo
func _make_first_attack():
	_reset_combo_state_partial() # Reset parziale prima del nuovo attacco
	current_attack = first_attack
	_play_attack()

# Funzione per eseguire l'attacco corrente
func _play_attack():
	# Stato transitorio
	can_chain = false
	in_recovery = false
	
	if current_attack == null or animator == null:
		# Gestione errore se non c'è attacco da suonare
		_reset_combo_state() 
		return
		
	animator.play(current_attack.animation_name)

# ===================================================================
#  FINESTRE DI TIMING (CHIAMATE DALL'ANIMATION PLAYER)
# ===================================================================

# Chiamato dall'AnimationPlayer all'interno della finestra di concatenazione
func enable_chain():
	# Se un attacco è già in coda, non fare nulla, aspetta la fine dell'animazione
	if queued_attack == null:
		can_chain = true

# Chiamato dall'AnimationPlayer per iniziare la recovery
func start_recovery():
	# Se un attacco è in coda, SKIPPAMO la recovery e passiamo al colpo successivo
	if queued_attack != null:
		current_attack = queued_attack
		queued_attack = null
		_play_attack()
		return
		
	# Nessun attacco in coda, entriamo in recovery (il player non può agire)
	in_recovery = true

# Funzione per gestire le animazioni prima di chiamare lo stato di stunned
func _on_player_stunned():
	current_attack = null
	queued_attack = null
	can_chain = false
	in_recovery = false
	animator.stop()
	player.stunned.emit()


# Callback di Godot: si attiva quando l'AnimationPlayer finisce
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Controlla se siamo già passati al prossimo attacco in start_recovery
	if current_attack != null and current_attack.animation_name != anim_name:
		# Se l'animazione finita NON è l'attacco corrente, non resettare.
		# Esempio: Il colpo 1 è finito, ma start_recovery() ha già lanciato il colpo 2.
		return 
		
	# Se arriviamo qui, l'animazione dell'ultimo colpo è finita E non c'era nulla in coda
	_reset_combo_state()


# ===================================================================
# 🧹 GESTIONE DELLO STATO INTERNO
# ===================================================================

# Mette in coda il prossimo attacco se premuto nella finestra can_chain
func _enqueue_next_attack():
	queued_attack = current_attack.next_attack
	can_chain = false # Non permettere di mettere in coda un secondo attacco

# Resetta solo i flag transitori, non lo stato di attacco/coda
func _reset_combo_state_partial():
	can_chain = false
	in_recovery = false

# Resetta completamente il sistema e segnala la fine allo stato Player
func _reset_combo_state():
	current_attack = null
	queued_attack = null
	can_chain = false
	in_recovery = false
	# Alla fine di uno qualsiasi degli attacchi, viene inviato il segnale
	attack_ended.emit()
