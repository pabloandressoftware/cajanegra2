package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ParallelRunner {

    @Test
    void testParallel() {
        // Los tags se pasan desde la línea de comandos / pipeline con -Dkarate.options="--tags @GH-1"
        Results results = Runner.path("classpath:features")
                .reportDir("target/karate-reports")
                .outputCucumberJson(true) // genera los .json que el pipeline lee para actualizar los Issues
                .parallel(1);             // 1 hilo: la API guarda un único estado compartido por ejercicio

        // Asercion para asegurar que el build de Gradle/Maven falle si alguna prueba no pasa
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
