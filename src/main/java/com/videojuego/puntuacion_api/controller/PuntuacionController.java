package com.videojuego.puntuacion_api.controller;

import com.videojuego.puntuacion_api.dto.ApiResponse;
import com.videojuego.puntuacion_api.model.Puntuacion;
import com.videojuego.puntuacion_api.service.PuntuacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/puntuaciones")
public class PuntuacionController {

    @Autowired
    private PuntuacionService puntuacionService;

    // Insertar nueva partida
    @PostMapping
    public ResponseEntity<ApiResponse<Puntuacion>> insertarPartida(@RequestBody Puntuacion puntuacion) {
        try {
            Puntuacion nuevaPartida = puntuacionService.guardarPartida(puntuacion);
            return ResponseEntity.ok(new ApiResponse<>(true, "Partida guardada exitosamente", nuevaPartida));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ApiResponse<>(false, "Error al guardar partida: " + e.getMessage(), null));
        }
    }

    // Obtener ranking
    @GetMapping("/ranking")
    public ResponseEntity<ApiResponse<List<Puntuacion>>> obtenerRanking(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Puntuacion> ranking = puntuacionService.obtenerRanking(limit);
            return ResponseEntity.ok(new ApiResponse<>(true, "Ranking obtenido", ranking));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ApiResponse<>(false, "Error al obtener ranking: " + e.getMessage(), null));
        }
    }

    // Obtener partidas de un jugador
    @GetMapping("/jugador/{nombre}")
    public ResponseEntity<ApiResponse<List<Puntuacion>>> obtenerPartidasJugador(@PathVariable String nombre) {
        try {
            List<Puntuacion> partidas = puntuacionService.obtenerPartidasJugador(nombre);
            return ResponseEntity.ok(new ApiResponse<>(true, "Partidas obtenidas", partidas));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ApiResponse<>(false, "Error al obtener partidas: " + e.getMessage(), null));
        }
    }

    // Health check
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(new ApiResponse<>(true, "API funcionando correctamente", "OK"));
    }
}
