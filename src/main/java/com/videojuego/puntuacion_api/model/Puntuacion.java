package com.videojuego.puntuacion_api.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "puntuacion")
public class Puntuacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_partida")
    private Integer idPartida;

    @Column(name = "nombre_jugador", nullable = false, length = 50)
    private String nombreJugador;

    @Column(name = "vidas_gastadas")
    private Integer vidasGastadas = 0;

    @Column(name = "gemas_recogidas")
    private Integer gemasRecogidas = 0;

    @Column(name = "enemigos_eliminados")
    private Integer enemigosEliminados = 0;

    @Column(name = "danio_recibido")
    private Integer danioRecibido = 0;

    @Column(name = "tiempo_partida")
    private Float tiempoPartida = 0.0f;

    @Column(name = "saltos_realizados")
    private Integer saltosRealizados = 0;

    @Column(name = "disparos_realizados")
    private Integer disparosRealizados = 0;

    @Column(name = "muertes_totales")
    private Integer muertesTotales = 0;

    @Column(name = "puntuacion_total")
    private Integer puntuacionTotal = 0;

    @Column(name = "fecha_partida")
    private LocalDateTime fechaPartida;

    @PrePersist
    protected void onCreate() {
        fechaPartida = LocalDateTime.now();
        calcularPuntuacion();
    }

    private void calcularPuntuacion() {
        int puntos = (gemasRecogidas * 100)
                   + (enemigosEliminados * 50)
                   - (vidasGastadas * 200)
                   - (danioRecibido * 10);

        // Bonificación por tiempo
        if (tiempoPartida > 0) {
            puntos += Math.max(0, 1000 - (int)(tiempoPartida * 2));
        }

        puntuacionTotal = Math.max(0, puntos);
    }

    // Getters y Setters
    public Integer getIdPartida() { return idPartida; }
    public void setIdPartida(Integer idPartida) { this.idPartida = idPartida; }

    public String getNombreJugador() { return nombreJugador; }
    public void setNombreJugador(String nombreJugador) { this.nombreJugador = nombreJugador; }

    public Integer getVidasGastadas() { return vidasGastadas; }
    public void setVidasGastadas(Integer vidasGastadas) { this.vidasGastadas = vidasGastadas; }

    public Integer getGemasRecogidas() { return gemasRecogidas; }
    public void setGemasRecogidas(Integer gemasRecogidas) { this.gemasRecogidas = gemasRecogidas; }

    public Integer getEnemigosEliminados() { return enemigosEliminados; }
    public void setEnemigosEliminados(Integer enemigosEliminados) { this.enemigosEliminados = enemigosEliminados; }

    public Integer getDanioRecibido() { return danioRecibido; }
    public void setDanioRecibido(Integer danioRecibido) { this.danioRecibido = danioRecibido; }

    public Float getTiempoPartida() { return tiempoPartida; }
    public void setTiempoPartida(Float tiempoPartida) { this.tiempoPartida = tiempoPartida; }

    public Integer getSaltosRealizados() { return saltosRealizados; }
    public void setSaltosRealizados(Integer saltosRealizados) { this.saltosRealizados = saltosRealizados; }

    public Integer getDisparosRealizados() { return disparosRealizados; }
    public void setDisparosRealizados(Integer disparosRealizados) { this.disparosRealizados = disparosRealizados; }

    public Integer getMuertesTotales() { return muertesTotales; }
    public void setMuertesTotales(Integer muertesTotales) { this.muertesTotales = muertesTotales; }

    public Integer getPuntuacionTotal() { return puntuacionTotal; }
    public void setPuntuacionTotal(Integer puntuacionTotal) { this.puntuacionTotal = puntuacionTotal; }

    public LocalDateTime getFechaPartida() { return fechaPartida; }
    public void setFechaPartida(LocalDateTime fechaPartida) { this.fechaPartida = fechaPartida; }
}
