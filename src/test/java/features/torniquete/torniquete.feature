@taller @transicionEstados @torniquete
Feature: Torniquete del Metro Inteligente - Transición de estados
  Como operador del sistema de metro
  Quiero que el torniquete solo cambie de estado ante los eventos y guardias permitidos
  Para que solo pasen pasajeros con saldo y el equipo se proteja ante fallas de energía

  Estados: S1 (Bloqueado), S2 (Autorizado), S3 (Girando), S4 (Mantenimiento). Inicia en S1.
  Eventos: Validar Tarjeta [Saldo Positivo], Empujar, Completar Giro, Alarma [Falla de Energía], Reparar.
  Antes de cada caso se consulta el estado, se reinicia la máquina a S1 (Bloqueado) y se
  disparan las transiciones válidas necesarias hasta llegar al estado inicial del caso.

  Background:
    * url baseUrl
    * headers { Content-Type: 'application/json', Accept: 'application/json' }

  # ---------------------------------------------------------------------------
  # Escenarios positivos: transiciones válidas
  # ---------------------------------------------------------------------------

  @REQ-TQ-01 @GH-1 @smoke @smoketest
  Scenario: Reiniciar el torniquete lo deja en el estado inicial S1 (Bloqueado)
    # Given que el torniquete se encuentra en cualquier estado
    * call read('torniquete-utils.feature@consultarEstado')
    # When el operador reinicia el sistema
    Given path 'torniquete/reiniciar'
    And request {}
    When method post
    # Then el torniquete queda en "S1 (Bloqueado)"
    Then status 200
    And match response == { estadoActual: 'S1 (Bloqueado)' }
    # And la máquina expone sus estados, eventos y guardias
    Given path 'torniquete/estado'
    When method get
    Then status 200
    And match response.maquina.nombre == 'Torniquete del Metro Inteligente'
    And match response.maquina.estados == ['S1 (Bloqueado)', 'S2 (Autorizado)', 'S3 (Girando)', 'S4 (Mantenimiento)']
    And match response.maquina.eventos contains only ['Validar Tarjeta', 'Empujar', 'Completar Giro', 'Alarma', 'Reparar']
    And match response.maquina.guardias == { 'Validar Tarjeta': 'Saldo Positivo', 'Alarma': 'Falla de Energía' }

  @REQ-TQ-02 @GH-2 @regression
  Scenario: Validar una tarjeta con saldo positivo desbloquea el paso (S1 -> S2)
    # Given que el torniquete está en el estado "S1 (Bloqueado)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S1 (Bloqueado)' }
    # When el pasajero valida una tarjeta con saldo positivo
    Given path 'torniquete/evento'
    And request { evento: 'Validar Tarjeta', guardia: true }
    When method post
    # Then el sistema pasa a "S2 (Autorizado)" y ejecuta la acción "Desbloquear paso"
    Then status 200
    And match response contains { estadoAnterior: 'S1 (Bloqueado)', evento: 'Validar Tarjeta', guardia: true, estadoNuevo: 'S2 (Autorizado)', valida: true, accion: 'Desbloquear paso' }

  @REQ-TQ-03 @GH-3 @regression
  Scenario: Empujar el torniquete autorizado lo pone a girar (S2 -> S3)
    # Given que el torniquete está en el estado "S2 (Autorizado)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S2 (Autorizado)' }
    # When el pasajero empuja el torniquete
    Given path 'torniquete/evento'
    And request { evento: 'Empujar', guardia: null }
    When method post
    # Then el sistema pasa a "S3 (Girando)" y ejecuta la acción "Girar molinete"
    Then status 200
    And match response contains { estadoAnterior: 'S2 (Autorizado)', evento: 'Empujar', estadoNuevo: 'S3 (Girando)', valida: true, accion: 'Girar molinete' }

  @REQ-TQ-04 @GH-4 @regression
  Scenario: Completar el giro vuelve a bloquear el torniquete (S3 -> S1)
    # Given que el torniquete está en el estado "S3 (Girando)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S3 (Girando)' }
    # When el sensor interno reporta "Completar Giro"
    Given path 'torniquete/evento'
    And request { evento: 'Completar Giro', guardia: null }
    When method post
    # Then el sistema regresa a "S1 (Bloqueado)"
    Then status 200
    And match response contains { estadoAnterior: 'S3 (Girando)', evento: 'Completar Giro', estadoNuevo: 'S1 (Bloqueado)', valida: true }

  @REQ-TQ-05 @GH-5 @regression
  Scenario Outline: Una alarma por falla de energía envía el torniquete a mantenimiento desde "<estado_actual>"
    # Given que el torniquete está en el estado "<estado_actual>"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: '<estado_actual>' }
    # When se activa la alarma con falla de energía
    Given path 'torniquete/evento'
    And request { evento: 'Alarma', guardia: true }
    When method post
    # Then el sistema pasa a "S4 (Mantenimiento)" y ejecuta la acción "Cortar energía"
    Then status 200
    And match response contains { estadoAnterior: '<estado_actual>', evento: 'Alarma', guardia: true, estadoNuevo: 'S4 (Mantenimiento)', valida: true, accion: 'Cortar energía' }

    Examples:
      | estado_actual   |
      | S1 (Bloqueado)  |
      | S2 (Autorizado) |

  @REQ-TQ-06 @GH-6 @regression
  Scenario: Reparar el torniquete en mantenimiento restaura el servicio (S4 -> S1)
    # Given que el torniquete está en el estado "S4 (Mantenimiento)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S4 (Mantenimiento)' }
    # When el técnico dispara el evento "Reparar"
    Given path 'torniquete/evento'
    And request { evento: 'Reparar', guardia: null }
    When method post
    # Then el sistema regresa a "S1 (Bloqueado)" y ejecuta la acción "Restaurar servicio"
    Then status 200
    And match response contains { estadoAnterior: 'S4 (Mantenimiento)', evento: 'Reparar', estadoNuevo: 'S1 (Bloqueado)', valida: true, accion: 'Restaurar servicio' }

  # ---------------------------------------------------------------------------
  # Escenarios negativos: guardias falsas, transiciones no definidas y eventos inválidos
  # ---------------------------------------------------------------------------

  @REQ-TQ-07 @GH-7 @regression @negativo
  Scenario Outline: No cambiar de estado cuando la guardia de "<evento>" es falsa en "<estado_actual>"
    # Given que el torniquete está en el estado "<estado_actual>"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: '<estado_actual>' }
    # When se dispara "<evento>" pero la guardia "<guardia_nombre>" no se cumple
    Given path 'torniquete/evento'
    And request { evento: '<evento>', guardia: false }
    When method post
    # Then el sistema rechaza la transición y permanece en "<estado_actual>"
    Then status 200
    And match response contains { estadoAnterior: '<estado_actual>', evento: '<evento>', guardia: false, estadoNuevo: '<estado_actual>', valida: false }

    Examples:
      | estado_actual   | evento          | guardia_nombre    |
      | S1 (Bloqueado)  | Validar Tarjeta | Saldo Positivo    |
      | S1 (Bloqueado)  | Alarma          | Falla de Energía  |
      | S2 (Autorizado) | Alarma          | Falla de Energía  |

  @REQ-TQ-08 @GH-8 @regression @negativo
  Scenario: Empujar el torniquete bloqueado sin validar tarjeta no permite el paso
    # Given que el torniquete está en el estado "S1 (Bloqueado)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S1 (Bloqueado)' }
    # When un pasajero intenta empujar sin haber validado su tarjeta
    Given path 'torniquete/evento'
    And request { evento: 'Empujar', guardia: null }
    When method post
    # Then el torniquete permanece en "S1 (Bloqueado)" y no ejecuta ninguna acción
    Then status 200
    And match response contains { estadoAnterior: 'S1 (Bloqueado)', evento: 'Empujar', estadoNuevo: 'S1 (Bloqueado)', valida: false, accion: null }

  @REQ-TQ-09 @GH-9 @regression @negativo
  Scenario Outline: Bloquear la transición no definida "<evento>" en el estado "<estado_actual>"
    # Given que el torniquete se encuentra en el estado "<estado_actual>"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: '<estado_actual>' }
    # When se intenta disparar el evento "<evento>"
    Given path 'torniquete/evento'
    And request { evento: '<evento>', guardia: <guardia> }
    When method post
    # Then el sistema no cambia de estado y marca la transición como no definida
    Then status 200
    And match response contains { estadoAnterior: '<estado_actual>', evento: '<evento>', estadoNuevo: '<estado_actual>', valida: false, noDefinida: true }

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
    # Given que el torniquete está en el estado "S1 (Bloqueado)"
    * call read('torniquete-utils.feature@llevarAEstado') { estadoObjetivo: 'S1 (Bloqueado)' }
    # When se envía un evento desconocido
    Given path 'torniquete/evento'
    And request <cuerpo>
    When method post
    # Then la API responde 400 con un mensaje de error
    Then status 400
    And match response.error contains 'Evento desconocido'

    Examples:
      | caso              | cuerpo                                      |
      | evento inventado  | { evento: 'Saltar Torniquete', guardia: null } |
      | evento vacío      | { evento: '', guardia: null }               |
      | sin campo evento  | {}                                          |
