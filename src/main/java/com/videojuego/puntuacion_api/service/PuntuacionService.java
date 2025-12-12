package com.videojuego.puntuacion_api.service;

import com.videojuego.puntuacion_api.model.Puntuacion;
import java.util.List;

public interface PuntuacionService {
    Puntuacion guardarPartida(Puntuacion puntuacion);
    List<Puntuacion> obtenerRanking(int limit);
    List<Puntuacion> obtenerPartidasJugador(String nombreJugador);
}