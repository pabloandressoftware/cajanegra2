@taller @tablaDecision @dronAgricola
Feature: Sistema de Navegación de un Dron Agrícola Autónomo - Tabla de decisión
  Como operador de fumigación agrícola
  Quiero que el software de vuelo decida si interrumpe la misión según el viento, la batería y los obstáculos
  Para proteger el dron y completar la fumigación de forma segura

  Condiciones (en el orden que espera la API en "valores"):
    C1: Viento > 40 km/h
    C2: Batería < 15%
    C3: Obstáculo a menos de 2m
  Acciones:
    A1: Ejecutar maniobra de esquive de emergencia (prioridad absoluta si C3)
    A2: Abortar misión y activar retorno automático (RTL) (C1 o C2, sin obstáculo)
    A3: Continuar ruta de vuelo planificada (ninguna condición)

  Background:
    * url baseUrl
    * headers { Content-Type: 'application/json', Accept: 'application/json' }

  @REQ-DR-01 @GH-11 @smoke @smoketest
  Scenario: Consultar la definición de la tabla de decisión del dron
    # Given que el operador reinicia el historial de evaluaciones del dron
    Given path 'decision/dron-agricola/reiniciar'
    And request {}
    When method post
    Then status 200
    And match response == { ok: true }
    # When consulta la definición de la tabla
    Given path 'decision/dron-agricola/definicion'
    When method get
    # Then el sistema expone las 3 condiciones y 4 reglas del ejercicio
    Then status 200
    And match response.nombre == 'Sistema de Navegación de un Dron Agrícola Autónomo'
    And match response.condiciones == ['Viento > 40 km/h', 'Batería < 15%', 'Obstáculo a menos de 2m']
    And match response.totalReglas == 4
    And match response.historial == '#array'

  @REQ-DR-02 @GH-12 @regression
  Scenario Outline: Ejecutar maniobra de esquive cuando hay un obstáculo a menos de 2m (regla <regla>)
    # Given que el dron está fumigando
    # And la velocidad del viento supera 40 km/h es <viento>
    # And la batería es inferior al 15% es <bateria>
    # And el sensor de proximidad detecta un obstáculo a menos de 2m es <obstaculo>
    Given path 'decision/dron-agricola/evaluar'
    And request { valores: [<viento>, <bateria>, <obstaculo>] }
    # When el software de vuelo evalúa las condiciones
    When method post
    # Then el dron debe "Ejecutar maniobra de esquive de emergencia"
    Then status 200
    And match response.valores == [<viento>, <bateria>, <obstaculo>]
    And match response.accion == 'Ejecutar maniobra de esquive de emergencia'
    And match response.noDefinida == false

    Examples:
      | regla | viento | bateria | obstaculo |
      | R1    | true   | true    | true      |
      | R3    | true   | false   | true      |
      | R5    | false  | true    | true      |
      | R7    | false  | false   | true      |

  @REQ-DR-03 @GH-13 @regression
  Scenario Outline: Abortar misión y activar RTL con viento fuerte o batería baja sin obstáculo (regla <regla>)
    # Given que el dron está fumigando sin obstáculos cercanos
    # And la velocidad del viento supera 40 km/h es <viento>
    # And la batería es inferior al 15% es <bateria>
    Given path 'decision/dron-agricola/evaluar'
    And request { valores: [<viento>, <bateria>, false] }
    # When el software de vuelo evalúa las condiciones
    When method post
    # Then el dron debe "Abortar misión y activar retorno automático (RTL)"
    Then status 200
    And match response.valores == [<viento>, <bateria>, false]
    And match response.accion == 'Abortar misión y activar retorno automático (RTL)'
    And match response.noDefinida == false

    Examples:
      | regla | viento | bateria |
      | R2    | true   | true    |
      | R4    | true   | false   |
      | R6    | false  | true    |

  @REQ-DR-04 @GH-14 @regression
  Scenario: Continuar la ruta planificada cuando no se cumple ninguna condición (regla R8)
    # Given que el viento es menor o igual a 40 km/h
    # And la batería es mayor o igual al 15%
    # And no hay obstáculos a menos de 2m
    Given path 'decision/dron-agricola/evaluar'
    And request { valores: [false, false, false] }
    # When el software de vuelo evalúa las condiciones
    When method post
    # Then el dron debe "Continuar ruta de vuelo planificada"
    Then status 200
    And match response.accion == 'Continuar ruta de vuelo planificada'
    And match response.noDefinida == false

  @REQ-DR-05 @GH-15 @regression @negativo
  Scenario Outline: Rechazar una evaluación con datos de entrada inválidos (<caso>)
    # Given que el operador envía una combinación de condiciones mal formada
    Given path 'decision/dron-agricola/evaluar'
    And request <cuerpo>
    # When el software de vuelo intenta evaluarla
    When method post
    # Then la API responde 400 indicando que se esperaban 3 valores booleanos
    Then status 400
    And match response.error == 'Se esperaban 3 valores booleanos'

    Examples:
      | caso                 | cuerpo                                 |
      | menos de 3 valores   | { valores: [true, false] }             |
      | más de 3 valores     | { valores: [true, false, true, true] } |
      | sin campo valores    | {}                                     |
