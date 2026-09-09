package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ParallelRunner {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:features")
                .outputCucumberJson(true) // <--- AQUI SE CONFIGURA
                .parallel(1);             // Define el numero de hilos concurrentes

        // Asercion para asegurar que el build de Gradle/Maven falle si alguna prueba no pasa
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
