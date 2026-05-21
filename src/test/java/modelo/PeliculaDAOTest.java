package modelo;

import java.time.LocalDate;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class PeliculaDAOTest {
    /* @Test
    public void testCrearPeliculaEnMemoria() {
        Protagonista protagonista = new Protagonista("Juan");

        // Prueba con todo Correcto
        Pelicula pelicula = new Pelicula(
            "It 2",                     // titulo
            "Jean",                     // director
            "Jose",                     // escritor
            LocalDate.of(2020, 6, 12),  // fechaEstreno
            148,                        // duracionM
            4,                          // calificacion
            "Película de terror",       // sinopsis
            "PG-13",                    // clasificacion
            "USA",                      // paisOrigen
            "Terror",                   // categoria
            "Inglés",                   // idiomaOriginal
            protagonista                // protagonista
        );
        
        // Pruebas de errores ejemplo: 
        Pelicula pelicula = new Pelicula(
            "it 1",                     // probar titulo vacio o con puros numeros
            "Diego",                    // probar si esta vacio
            "Jose",                     // probar si esta vacio
            LocalDate.of(2022, 6, 12),  // probar fecha fuera de rango
            250,                        // probar si esta vacio o si la duracion supera lo permitido
            4,                          // probar si esta vacio solo acepta numeros 0 - 5
            "Película de terror",       // probar si esta vacio o sinopsis corta min 10 caracteres
            "PG-13",                    // probar si esta vacio
            "USA",                      // probar si esta vacio 
            "Terror",                 // probar si esta vacio
            "Inglés",                   // probar si esta vacio
            protagonista                // probar si esta vacio
        );

        // VALIDACIONES
        Assertions.assertEquals("It 2", pelicula.getTitulo());
        Assertions.assertEquals("Jean", pelicula.getDirector());
        Assertions.assertEquals("Jose", pelicula.getEscritor());
        Assertions.assertEquals(LocalDate.of(2020, 6, 12), pelicula.getFechaEstreno());
        Assertions.assertEquals(Integer.valueOf(148), pelicula.getDuracionM());
        Assertions.assertEquals(Integer.valueOf(4), pelicula.getCalificacion());
        Assertions.assertEquals("Terror", pelicula.getCategoria());
        Assertions.assertNotNull(pelicula.getProtagonista());
        Assertions.assertEquals("Juan", pelicula.getProtagonista().getNombre());
    }*/
}