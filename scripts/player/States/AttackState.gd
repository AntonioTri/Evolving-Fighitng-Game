extends PlayerAbstractState
# ====== STATO DI ATTACK DEL PLAYER ====== #

# Reference al nodo che gestisce il combattimento (Assumo che sia un fratello del Player)
# NOTA: Se ComboSystem è figlio diretto del Player, usa "$CombatSystem"
@onready var combat_system: ComboSystem = $"../../CombatSystem" 

# Nella funzione process ascoltiamo gli input e chiamiamo il metodo della combo
func on_process(_delta: float) -> void:
	# L'input viene controllato nel loop process per minimizzare il ritardo
	if player.inputs.is_attack_buffered():
		player.inputs.consume_attack() # Consumiamo l'attacco bufferato
		combat_system.start_combo()

# All'ingresso colleghiamo al segnale contenuto nel combat system alla funzione per tornare ad idle state
func enter() -> void:
	# Eseguiamo il primo attacco se entriamo, ma solo se non siamo già in un attacco
	if combat_system.current_attack == null:
		combat_system.start_combo()

	# Connettiamo il segnale per uscire
	combat_system.attack_ended.connect(_on_attack_ended)

func exit() -> void:
	# Scolleghiamo il segnale quando usciamo dallo stato
	# Questo è FONDAMENTALE per prevenire che segnali futuri facciano transizioni indesiderate.
	if combat_system.attack_ended.is_connected(_on_attack_ended):
		combat_system.attack_ended.disconnect(_on_attack_ended)
	# Quando la FSM ci porta fuori da qui (anche forzatamente), 
	# dobbiamo pulire il sistema di combo.
	player.combat_system._reset_combo_state()
	print("Uscita dallo stato Attack: Combo resettata.")

# La funzione di transizione viene chiamata dal segnale inviato dal combo manager
func _on_attack_ended():
	# NOTA: Qui potresti volere una logica più complessa, es.
	# Se player.inputs.move_direction.x != 0, transiziona a "Move" invece che "Idle"
	transition.emit(self, "Idle")
