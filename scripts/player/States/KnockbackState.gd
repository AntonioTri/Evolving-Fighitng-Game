extends PlayerAbstractState
# ====== STATO DI KNOCKBACK DEL PLAYER ====== #

# Variabile per tracciare la direzione della spinta (1 o -1)
var knockback_direction: int = 0
var fall_gravity: float = 0.0

# -------------------------------------------------------------
# ENTRATA NELLO STATO
# 
# @param direction: La direzione (1 = destra, -1 = sinistra) in cui il player è spinto.
# -------------------------------------------------------------

func enter():
	# Calcola il vettore di spinta (vettore diagonale)
	var angle_rad = deg_to_rad(player.knockback_angle_degree)

	# Calcola le componenti X e Y. Nota: Y è negativo per spingere verso l'alto
	var push_x = player.knockback_force * cos(angle_rad) * float(knockback_direction)
	var push_y = player.knockback_force * sin(angle_rad) * -1.0 

	# Assegna la nuova velocità
	player.velocity = Vector2(push_x, push_y)
	# Esegue animazione di knockback
	# player.animator.play("knockback")
	
# -------------------------------------------------------------
# LOGICA FISICA
# -------------------------------------------------------------
func on_physics_process(_delta: float) -> void:

	# 1. Applicazione della Gravità
	# Applica la gravità di caduta (fall_gravity) per creare la parabola.
	player.velocity.y += fall_gravity * _delta
	# 2. Controllo Collisione Orizzontale (Muri)
	# Se il player colpisce un muro orizzontalmente, azzera la velocità X.
	if player.is_on_wall():
		player.velocity.x = 0
		
	# 3. Transizione allo Stato di Atterraggio
	# Lo stato di knockback termina NON appena il player tocca il terreno.
	if player.is_on_floor() and player.velocity.y > 0:
		# Transizione a Idle (o Move se l'input è attivo, ma in knockback è disabilitato)
		transition.emit(self, "Idle")
		return

	# 4. Esecuzione del movimento
	player.move_and_slide()

# -------------------------------------------------------------
# USCITA DALLO STATO
# -------------------------------------------------------------
func exit() -> void:
	# Opzionale: Azzera la velocity.x alla fine, per evitare di scivolare troppo
	player.velocity.x = 0
	# Imposta animazione a Idle o Fall
	# player.animator.play("idle") # Esempio
	pass


# -------------------------------------------------------------
# Metodo di Inizializzazione Fisica
# Chiamato dal Player al _ready()
func initialize_physics_constants():
	# Usiamo la gravità di caduta, dato che il knockback è una caduta forzata.
	fall_gravity = (( -2.0 * player.jump_height ) / ( player.jump_time_to_descend * player.jump_time_to_descend )) * -1

# -------------------------------------------------------------
# Metodo di Setup: Chiamato *PRIMA* della transizione (dalla State Machine)
# -------------------------------------------------------------
func setup_knockback(direction: int):
	# La spinta deve essere opposta alla direzione del nemico o dell'attacco.
	self.knockback_direction = direction
