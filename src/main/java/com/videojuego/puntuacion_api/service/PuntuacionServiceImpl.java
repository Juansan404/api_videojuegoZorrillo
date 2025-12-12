package com.videojuego.puntuacion_api.service;

import com.videojuego.puntuacion_api.model.Puntuacion;
import com.videojuego.puntuacion_api.repository.PuntuacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PuntuacionServiceImpl implements PuntuacionService {

    @Autowired
    private PuntuacionRepository puntuacionRepository;

    @Override
    public Puntuacion guardarPartida(Puntuacion puntuacion) {
        return puntuacionRepository.save(puntuacion);
    }

    @Override
    public List<Puntuacion> obtenerRanking(int limit) {
        return puntuacionRepository.findAllByOrderByPuntuacionTotalDesc(
                PageRequest.of(0, limit));
    }

    @Override
    public List<Puntuacion> obtenerPartidasJugador(String nombreJugador) {
        return puntuacionRepository.findByNombreJugadorOrderByFechaPartidaDesc(nombreJugador);
    }
}
