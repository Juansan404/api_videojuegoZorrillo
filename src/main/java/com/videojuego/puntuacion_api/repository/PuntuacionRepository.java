package com.videojuego.puntuacion_api.repository;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.videojuego.puntuacion_api.model.Puntuacion;

import java.util.List;

@Repository
public interface PuntuacionRepository extends JpaRepository<Puntuacion, Integer> {

    // Obtener ranking (top puntuaciones)
    List<Puntuacion> findAllByOrderByPuntuacionTotalDesc(Pageable pageable);

    // Obtener partidas de un jugador
    List<Puntuacion> findByNombreJugadorOrderByFechaPartidaDesc(String nombreJugador);

    // Obtener mejor puntuación de un jugador
    @Query("SELECT MAX(p.puntuacionTotal) FROM Puntuacion p WHERE p.nombreJugador = :nombreJugador")
    Integer findMaxPuntuacionByNombreJugador(String nombreJugador);
}
