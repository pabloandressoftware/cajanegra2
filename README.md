# cajanegra2 — Automatización de pruebas backend con Karate

Taller **Automatización de Pruebas Backend con Karate Framework** (corte 2).
Autor: Pablo Guzmán Alarcón — A00399523

Se automatizan con [Karate](https://github.com/karatelabs/karate) dos ejercicios del taller de técnicas de caja negra, usando la API
`https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/`:

| Bloque | Ejercicio elegido | Endpoints |
|---|---|---|
| 1 · Transición de estados | **1.7 Torniquete del Metro Inteligente** | `GET torniquete/estado`, `POST torniquete/evento`, `POST torniquete/reiniciar` |
| 2 · Tablas de decisión | **2.3 Sistema de Navegación de un Dron Agrícola Autónomo** | `GET decision/dron-agricola/definicion`, `POST decision/dron-agricola/evaluar`, `POST decision/dron-agricola/reiniciar` |

**15 escenarios** (39 ejecuciones contando los `Examples`), cada uno vinculado a su Issue.

## Estructura

```
cajanegra2/
├── .github/workflows/ci.yml           # pipeline: ejecuta por tag, sube reportes y actualiza los Issues
├── build.gradle
└── src/test/java/
    ├── karate-config.js               # baseUrl, timeouts y "despertar" del servidor de Render
    ├── runners/ParallelRunner.java    # runner JUnit5 (reportes en target/karate-reports)
    └── features/
        ├── warmup.feature             # @ignore: espera a que la API responda
        ├── torniquete/
        │   ├── torniquete.feature     # 10 escenarios de transición de estados
        │   └── torniquete-utils.feature  # @ignore: consultar estado, reiniciar y llevar a un estado
        └── dron/
            └── dron.feature           # 5 escenarios de tabla de decisión
```

## Tags

| Tag | Significado |
|---|---|
| `@taller` | Toda la suite del taller (lo que corre el pipeline por defecto) |
| `@transicionEstados` / `@tablaDecision` | Bloque del taller |
| `@torniquete` / `@dronAgricola` | Ejercicio |
| `@REQ-TQ-xx` / `@REQ-DR-xx` | **Requisito** al que pertenece el escenario |
| `@GH-n` | **Issue #n** de GitHub que representa el caso de prueba |
| `@smoke` `@smoketest` / `@regression` / `@negativo` | Tipo de prueba |

## Matriz de trazabilidad (requisito ↔ issue ↔ escenario)

| Requisito | Issue | Tag | Escenario | Tipo | Gherkin |
|---|---|---|---|---|---|
| `REQ-TQ-01` | [#1](https://github.com/pabloandressoftware/cajanegra2/issues/1) | `@GH-1` | Reiniciar el torniquete lo deja en el estado inicial S1 (Bloqueado) | Positivo | Scenario |
| `REQ-TQ-02` | [#2](https://github.com/pabloandressoftware/cajanegra2/issues/2) | `@GH-2` | Validar una tarjeta con saldo positivo desbloquea el paso (S1 -> S2) | Positivo | Scenario |
| `REQ-TQ-03` | [#3](https://github.com/pabloandressoftware/cajanegra2/issues/3) | `@GH-3` | Empujar el torniquete autorizado lo pone a girar (S2 -> S3) | Positivo | Scenario |
| `REQ-TQ-04` | [#4](https://github.com/pabloandressoftware/cajanegra2/issues/4) | `@GH-4` | Completar el giro vuelve a bloquear el torniquete (S3 -> S1) | Positivo | Scenario |
| `REQ-TQ-05` | [#5](https://github.com/pabloandressoftware/cajanegra2/issues/5) | `@GH-5` | Una alarma por falla de energía envía el torniquete a mantenimiento desde "<estado_actual>" | Positivo | Scenario Outline |
| `REQ-TQ-06` | [#6](https://github.com/pabloandressoftware/cajanegra2/issues/6) | `@GH-6` | Reparar el torniquete en mantenimiento restaura el servicio (S4 -> S1) | Positivo | Scenario |
| `REQ-TQ-07` | [#7](https://github.com/pabloandressoftware/cajanegra2/issues/7) | `@GH-7` | No cambiar de estado cuando la guardia de "<evento>" es falsa en "<estado_actual>" | Negativo | Scenario Outline |
| `REQ-TQ-08` | [#8](https://github.com/pabloandressoftware/cajanegra2/issues/8) | `@GH-8` | Empujar el torniquete bloqueado sin validar tarjeta no permite el paso | Negativo | Scenario |
| `REQ-TQ-09` | [#9](https://github.com/pabloandressoftware/cajanegra2/issues/9) | `@GH-9` | Bloquear la transición no definida "<evento>" en el estado "<estado_actual>" | Negativo | Scenario Outline |
| `REQ-TQ-10` | [#10](https://github.com/pabloandressoftware/cajanegra2/issues/10) | `@GH-10` | Rechazar un evento que no existe en la máquina (<caso>) | Negativo | Scenario Outline |
| `REQ-DR-01` | [#11](https://github.com/pabloandressoftware/cajanegra2/issues/11) | `@GH-11` | Consultar la definición de la tabla de decisión del dron | Positivo | Scenario |
| `REQ-DR-02` | [#12](https://github.com/pabloandressoftware/cajanegra2/issues/12) | `@GH-12` | Ejecutar maniobra de esquive cuando hay un obstáculo a menos de 2m (regla <regla>) | Positivo | Scenario Outline |
| `REQ-DR-03` | [#13](https://github.com/pabloandressoftware/cajanegra2/issues/13) | `@GH-13` | Abortar misión y activar RTL con viento fuerte o batería baja sin obstáculo (regla <regla>) | Positivo | Scenario Outline |
| `REQ-DR-04` | [#14](https://github.com/pabloandressoftware/cajanegra2/issues/14) | `@GH-14` | Continuar la ruta planificada cuando no se cumple ninguna condición (regla R8) | Positivo | Scenario |
| `REQ-DR-05` | [#15](https://github.com/pabloandressoftware/cajanegra2/issues/15) | `@GH-15` | Rechazar una evaluación con datos de entrada inválidos (<caso>) | Negativo | Scenario Outline |

## Ejecución

```bash
./gradlew test -Dkarate.options="--tags @taller"        # toda la suite
./gradlew test -Dkarate.options="--tags @GH-3"          # un caso de prueba (issue #3)
./gradlew test -Dkarate.options="--tags @REQ-TQ-05"     # un requisito
./gradlew test -Dkarate.options="--tags @smoke,@negativo"  # OR entre tags
```

Reporte: `target/karate-reports/karate-summary.html`.

### Desde GitHub Actions / el TestCase (Issue)
1. *Actions* → **CI** → *Run workflow*, y en `testTag` escribir el tag del issue, por ejemplo `@GH-3`
   (vacío = toda la suite `@taller`). Un `push` a `main` también ejecuta toda la suite.
2. El pipeline ejecuta Karate, publica los artefactos `karate-reports` y `test-results`, y con
   `actions/github-script` lee los Cucumber JSON: por cada escenario con `@GH-n` comenta en el Issue #n
   **PASSED/FAILED** con el enlace a la ejecución y pone el label `automated-passed` o `automated-failed` (+ `bug`).

## Notas de diseño

- **Estado compartido:** la API guarda un solo estado por ejercicio para todos los estudiantes. Por eso cada
  escenario de transición primero consulta el estado, reinicia a S1 y dispara las transiciones válidas hasta el
  estado inicial del caso (`torniquete-utils.feature@llevarAEstado`), reintentando hasta 5 veces si otra persona
  cambia el estado a mitad de la preparación. Las aserciones se hacen sobre la respuesta del propio `POST evento`
  (`estadoAnterior`, `estadoNuevo`, `valida`, `accion`), que es atómica. El runner usa 1 hilo.
- **Render plan gratuito:** el servidor se duerme; `karate.callSingle` lo despierta una vez y los timeouts son de 90 s.
- Se eligió el torniquete y no el Barista Bot porque durante las pruebas había otros usuarios disparando eventos
  sobre el Barista Bot al mismo tiempo, lo que volvía las pruebas no deterministas.

## Especificación Gherkin (lenguaje de negocio)

### Bloque 1 — Torniquete del Metro Inteligente

| Estado \ Evento | Validar Tarjeta [Saldo+] | Empujar | Completar Giro | Alarma [Falla energía] | Reparar |
|---|---|---|---|---|---|
| S1 Bloqueado | S2 · *Desbloquear paso* (guardia F: se queda) | se queda (inválida) | no definida | S4 · *Cortar energía* (guardia F: se queda) | no definida |
| S2 Autorizado | no definida | S3 · *Girar molinete* | no definida | S4 · *Cortar energía* (guardia F: se queda) | no definida |
| S3 Girando | no definida | no definida | S1 | no definida | no definida |
| S4 Mantenimiento | no definida | no definida | no definida | no definida | S1 · *Restaurar servicio* |

```gherkin
Feature: Torniquete del Metro Inteligente - Transición de estados

  @REQ-TQ-01 @GH-1 @smoke @smoketest
  Scenario: Reiniciar el torniquete lo deja en el estado inicial S1 (Bloqueado)
    Given que el torniquete se encuentra en cualquier estado
    When el operador reinicia el sistema
    Then el torniquete queda en "S1 (Bloqueado)"
    And la máquina expone sus estados, eventos y guardias

  @REQ-TQ-02 @GH-2 @regression
  Scenario: Validar una tarjeta con saldo positivo desbloquea el paso (S1 -> S2)
    Given que el torniquete está en el estado "S1 (Bloqueado)"
    When el pasajero valida una tarjeta con saldo positivo
    Then el sistema pasa a "S2 (Autorizado)" y ejecuta la acción "Desbloquear paso"

  @REQ-TQ-03 @GH-3 @regression
  Scenario: Empujar el torniquete autorizado lo pone a girar (S2 -> S3)
    Given que el torniquete está en el estado "S2 (Autorizado)"
    When el pasajero empuja el torniquete
    Then el sistema pasa a "S3 (Girando)" y ejecuta la acción "Girar molinete"

  @REQ-TQ-04 @GH-4 @regression
  Scenario: Completar el giro vuelve a bloquear el torniquete (S3 -> S1)
    Given que el torniquete está en el estado "S3 (Girando)"
    When el sensor interno reporta "Completar Giro"
    Then el sistema regresa a "S1 (Bloqueado)"

  @REQ-TQ-05 @GH-5 @regression
  Scenario Outline: Una alarma por falla de energía envía el torniquete a mantenimiento desde "<estado_actual>"
    Given que el torniquete está en el estado "<estado_actual>"
    When se activa la alarma con falla de energía
    Then el sistema pasa a "S4 (Mantenimiento)" y ejecuta la acción "Cortar energía"
    Examples:
      | estado_actual   |
      | S1 (Bloqueado)  |
      | S2 (Autorizado) |

  @REQ-TQ-06 @GH-6 @regression
  Scenario: Reparar el torniquete en mantenimiento restaura el servicio (S4 -> S1)
    Given que el torniquete está en el estado "S4 (Mantenimiento)"
    When el técnico dispara el evento "Reparar"
    Then el sistema regresa a "S1 (Bloqueado)" y ejecuta la acción "Restaurar servicio"

  @REQ-TQ-07 @GH-7 @regression @negativo
  Scenario Outline: No cambiar de estado cuando la guardia de "<evento>" es falsa en "<estado_actual>"
    Given que el torniquete está en el estado "<estado_actual>"
    When se dispara "<evento>" pero la guardia "<guardia_nombre>" no se cumple
    Then el sistema rechaza la transición y permanece en "<estado_actual>"
    Examples:
      | estado_actual   | evento          | guardia_nombre    |
      | S1 (Bloqueado)  | Validar Tarjeta | Saldo Positivo    |
      | S1 (Bloqueado)  | Alarma          | Falla de Energía  |
      | S2 (Autorizado) | Alarma          | Falla de Energía  |

  @REQ-TQ-08 @GH-8 @regression @negativo
  Scenario: Empujar el torniquete bloqueado sin validar tarjeta no permite el paso
    Given que el torniquete está en el estado "S1 (Bloqueado)"
    When un pasajero intenta empujar sin haber validado su tarjeta
    Then el torniquete permanece en "S1 (Bloqueado)" y no ejecuta ninguna acción

  @REQ-TQ-09 @GH-9 @regression @negativo
  Scenario Outline: Bloquear la transición no definida "<evento>" en el estado "<estado_actual>"
    Given que el torniquete se encuentra en el estado "<estado_actual>"
    When se intenta disparar el evento "<evento>"
    Then el sistema no cambia de estado y marca la transición como no definida
    Examples:
      | estado_actual      | evento          | guardia |
      | S1 (Bloqueado)     | Completar Giro  | null    |
      | S1 (Bloqueado)     | Reparar         | null    |
      | S2 (Autorizado)    | Validar Tarjeta | true    |
      | S2 (Autorizado)    | Completar Giro  | null    |
      | S2 (Autorizado)    | Reparar         | null    |
      | S3 (Girando)       | Validar Tarjeta | true    |
      | S3 (Girando)       | Empujar         | null    |
      | S3 (Girando)       | Alarma          | true    |
      | S3 (Girando)       | Reparar         | null    |
      | S4 (Mantenimiento) | Validar Tarjeta | true    |
      | S4 (Mantenimiento) | Empujar         | null    |
      | S4 (Mantenimiento) | Completar Giro  | null    |
      | S4 (Mantenimiento) | Alarma          | true    |

  @REQ-TQ-10 @GH-10 @regression @negativo
  Scenario Outline: Rechazar un evento que no existe en la máquina (<caso>)
    Given que el torniquete está en el estado "S1 (Bloqueado)"
    When se envía un evento desconocido
    Then la API responde 400 con un mensaje de error
    Examples:
      | caso              | cuerpo                                      |
      | evento inventado  | { evento: 'Saltar Torniquete', guardia: null } |
      | evento vacío      | { evento: '', guardia: null }               |
      | sin campo evento  | {}                                          |
```

### Bloque 2 — Dron Agrícola Autónomo

| Regla | C1 Viento > 40 km/h | C2 Batería < 15% | C3 Obstáculo < 2 m | Acción |
|---|---|---|---|---|
| R1 | V | V | V | A1 Esquive de emergencia |
| R2 | V | V | F | A2 Abortar misión y RTL |
| R3 | V | F | V | A1 |
| R4 | V | F | F | A2 |
| R5 | F | V | V | A1 |
| R6 | F | V | F | A2 |
| R7 | F | F | V | A1 |
| R8 | F | F | F | A3 Continuar ruta |

```gherkin
Feature: Sistema de Navegación de un Dron Agrícola Autónomo - Tabla de decisión

  @REQ-DR-01 @GH-11 @smoke @smoketest
  Scenario: Consultar la definición de la tabla de decisión del dron
    Given que el operador reinicia el historial de evaluaciones del dron
    When consulta la definición de la tabla
    Then el sistema expone las 3 condiciones y 4 reglas del ejercicio

  @REQ-DR-02 @GH-12 @regression
  Scenario Outline: Ejecutar maniobra de esquive cuando hay un obstáculo a menos de 2m (regla <regla>)
    Given que el dron está fumigando
    And la velocidad del viento supera 40 km/h es <viento>
    And la batería es inferior al 15% es <bateria>
    And el sensor de proximidad detecta un obstáculo a menos de 2m es <obstaculo>
    When el software de vuelo evalúa las condiciones
    Then el dron debe "Ejecutar maniobra de esquive de emergencia"
    Examples:
      | regla | viento | bateria | obstaculo |
      | R1    | true   | true    | true      |
      | R3    | true   | false   | true      |
      | R5    | false  | true    | true      |
      | R7    | false  | false   | true      |

  @REQ-DR-03 @GH-13 @regression
  Scenario Outline: Abortar misión y activar RTL con viento fuerte o batería baja sin obstáculo (regla <regla>)
    Given que el dron está fumigando sin obstáculos cercanos
    And la velocidad del viento supera 40 km/h es <viento>
    And la batería es inferior al 15% es <bateria>
    When el software de vuelo evalúa las condiciones
    Then el dron debe "Abortar misión y activar retorno automático (RTL)"
    Examples:
      | regla | viento | bateria |
      | R2    | true   | true    |
      | R4    | true   | false   |
      | R6    | false  | true    |

  @REQ-DR-04 @GH-14 @regression
  Scenario: Continuar la ruta planificada cuando no se cumple ninguna condición (regla R8)
    Given que el viento es menor o igual a 40 km/h
    And la batería es mayor o igual al 15%
    And no hay obstáculos a menos de 2m
    When el software de vuelo evalúa las condiciones
    Then el dron debe "Continuar ruta de vuelo planificada"

  @REQ-DR-05 @GH-15 @regression @negativo
  Scenario Outline: Rechazar una evaluación con datos de entrada inválidos (<caso>)
    Given que el operador envía una combinación de condiciones mal formada
    When el software de vuelo intenta evaluarla
    Then la API responde 400 indicando que se esperaban 3 valores booleanos
    Examples:
      | caso                 | cuerpo                                 |
      | menos de 3 valores   | { valores: [true, false] }             |
      | más de 3 valores     | { valores: [true, false, true, true] } |
      | sin campo valores    | {}                                     |
```
