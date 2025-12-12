-- =====================================================
-- Base de datos: videojuego_jsa
-- Sistema de puntuación para videojuego Unity
-- =====================================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS videojuego_jsa
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE videojuego_jsa;

-- =====================================================
-- Tabla: puntuacion
-- Descripción: Almacena las estadísticas y puntuación de cada partida
-- =====================================================

DROP TABLE IF EXISTS puntuacion;

CREATE TABLE puntuacion (
    -- Clave primaria
    id_partida INT AUTO_INCREMENT PRIMARY KEY,

    -- Información del jugador
    nombre_jugador VARCHAR(50) NOT NULL,

    -- Estadísticas de la partida
    vidas_gastadas INT DEFAULT 0 COMMENT 'Número de veces que el jugador perdió vida',
    gemas_recogidas INT DEFAULT 0 COMMENT 'Total de gemas recolectadas',
    enemigos_eliminados INT DEFAULT 0 COMMENT 'Total de enemigos derrotados',
    danio_recibido INT DEFAULT 0 COMMENT 'Cantidad total de daño recibido',
    tiempo_partida DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Tiempo total de juego en segundos',

    -- Campos adicionales para mejorar el sistema de puntuación
    saltos_realizados INT DEFAULT 0 COMMENT 'Total de saltos ejecutados',
    disparos_realizados INT DEFAULT 0 COMMENT 'Total de disparos efectuados',
    muertes_totales INT DEFAULT 0 COMMENT 'Número de veces que murió completamente',

    -- Puntuación final
    puntuacion_total INT DEFAULT 0 COMMENT 'Puntuación total calculada',

    -- Metadatos
    fecha_partida TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la partida',

    -- Índices para mejorar consultas
    INDEX idx_nombre_jugador (nombre_jugador),
    INDEX idx_puntuacion (puntuacion_total DESC),
    INDEX idx_fecha (fecha_partida DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla de puntuaciones y estadísticas de partidas';

-- =====================================================
-- Tabla: ranking (opcional - para top scores)
-- =====================================================

DROP TABLE IF EXISTS ranking;

CREATE TABLE ranking (
    id_ranking INT AUTO_INCREMENT PRIMARY KEY,
    id_partida INT NOT NULL,
    posicion INT NOT NULL COMMENT 'Posición en el ranking',
    fecha_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_partida) REFERENCES puntuacion(id_partida) ON DELETE CASCADE,
    INDEX idx_posicion (posicion ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla de ranking - mejores puntuaciones';

-- =====================================================
-- Vista: top_10_puntuaciones
-- Descripción: Muestra las 10 mejores puntuaciones
-- =====================================================

CREATE OR REPLACE VIEW top_10_puntuaciones AS
SELECT
    id_partida,
    nombre_jugador,
    puntuacion_total,
    gemas_recogidas,
    enemigos_eliminados,
    tiempo_partida,
    fecha_partida
FROM puntuacion
ORDER BY puntuacion_total DESC
LIMIT 10;

-- =====================================================
-- Vista: estadisticas_jugador
-- Descripción: Estadísticas generales por jugador
-- =====================================================

CREATE OR REPLACE VIEW estadisticas_jugador AS
SELECT
    nombre_jugador,
    COUNT(*) as partidas_jugadas,
    MAX(puntuacion_total) as mejor_puntuacion,
    AVG(puntuacion_total) as promedio_puntuacion,
    SUM(gemas_recogidas) as total_gemas,
    SUM(enemigos_eliminados) as total_enemigos,
    AVG(tiempo_partida) as tiempo_promedio,
    SUM(muertes_totales) as total_muertes
FROM puntuacion
GROUP BY nombre_jugador
ORDER BY mejor_puntuacion DESC;

-- =====================================================
-- Procedimiento almacenado: calcular_puntuacion
-- Descripción: Calcula la puntuación total basada en estadísticas
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS calcular_puntuacion//

CREATE PROCEDURE calcular_puntuacion(IN p_id_partida INT)
BEGIN
    DECLARE v_puntuacion INT DEFAULT 0;
    DECLARE v_gemas INT;
    DECLARE v_enemigos INT;
    DECLARE v_vidas_gastadas INT;
    DECLARE v_danio INT;
    DECLARE v_tiempo DECIMAL(10,2);

    -- Obtener datos de la partida
    SELECT
        gemas_recogidas,
        enemigos_eliminados,
        vidas_gastadas,
        danio_recibido,
        tiempo_partida
    INTO
        v_gemas,
        v_enemigos,
        v_vidas_gastadas,
        v_danio,
        v_tiempo
    FROM puntuacion
    WHERE id_partida = p_id_partida;

    -- Fórmula de puntuación:
    -- + 100 puntos por cada gema
    -- + 50 puntos por cada enemigo eliminado
    -- - 200 puntos por cada vida gastada
    -- - 10 puntos por cada punto de daño recibido
    -- + Bonificación por tiempo (máximo 1000 puntos si termina rápido)

    SET v_puntuacion = (v_gemas * 100)
                     + (v_enemigos * 50)
                     - (v_vidas_gastadas * 200)
                     - (v_danio * 10);

    -- Bonificación por tiempo (menos tiempo = más puntos, máximo 1000)
    IF v_tiempo > 0 THEN
        SET v_puntuacion = v_puntuacion + GREATEST(0, 1000 - (v_tiempo * 2));
    END IF;

    -- Asegurar que la puntuación no sea negativa
    SET v_puntuacion = GREATEST(0, v_puntuacion);

    -- Actualizar la puntuación en la tabla
    UPDATE puntuacion
    SET puntuacion_total = v_puntuacion
    WHERE id_partida = p_id_partida;

END//

DELIMITER ;

-- =====================================================
-- Procedimiento almacenado: insertar_partida
-- Descripción: Inserta una nueva partida y calcula su puntuación
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS insertar_partida//

CREATE PROCEDURE insertar_partida(
    IN p_nombre_jugador VARCHAR(50),
    IN p_vidas_gastadas INT,
    IN p_gemas_recogidas INT,
    IN p_enemigos_eliminados INT,
    IN p_danio_recibido INT,
    IN p_tiempo_partida DECIMAL(10,2),
    IN p_saltos_realizados INT,
    IN p_disparos_realizados INT,
    IN p_muertes_totales INT,
    OUT p_id_partida INT
)
BEGIN
    -- Insertar la partida
    INSERT INTO puntuacion (
        nombre_jugador,
        vidas_gastadas,
        gemas_recogidas,
        enemigos_eliminados,
        danio_recibido,
        tiempo_partida,
        saltos_realizados,
        disparos_realizados,
        muertes_totales
    ) VALUES (
        p_nombre_jugador,
        p_vidas_gastadas,
        p_gemas_recogidas,
        p_enemigos_eliminados,
        p_danio_recibido,
        p_tiempo_partida,
        p_saltos_realizados,
        p_disparos_realizados,
        p_muertes_totales
    );

    -- Obtener el ID de la partida insertada
    SET p_id_partida = LAST_INSERT_ID();

    -- Calcular la puntuación
    CALL calcular_puntuacion(p_id_partida);

END//

DELIMITER ;

-- =====================================================
-- Datos de ejemplo (opcional - puedes comentar o eliminar)
-- =====================================================

-- Insertar algunas partidas de ejemplo
CALL insertar_partida('Player1', 2, 15, 8, 25, 120.50, 45, 30, 1, @id);
CALL insertar_partida('Player2', 3, 10, 5, 40, 150.00, 50, 25, 2, @id);
CALL insertar_partida('Player3', 1, 20, 12, 15, 90.25, 40, 35, 0, @id);

-- =====================================================
-- Consultas útiles
-- =====================================================

-- Ver top 10 puntuaciones
-- SELECT * FROM top_10_puntuaciones;

-- Ver estadísticas por jugador
-- SELECT * FROM estadisticas_jugador;

-- Ver todas las partidas ordenadas por puntuación
-- SELECT * FROM puntuacion ORDER BY puntuacion_total DESC;

-- Ver partidas de un jugador específico
-- SELECT * FROM puntuacion WHERE nombre_jugador = 'Player1' ORDER BY puntuacion_total DESC;
