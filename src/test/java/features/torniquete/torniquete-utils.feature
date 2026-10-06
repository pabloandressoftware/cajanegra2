@ignore
Feature: Utilidades para preparar el estado del Torniquete del Metro
  Escenarios reutilizables (no se ejecutan solos, se invocan con call):
  consultar el estado, reiniciar la máquina y llevarla hasta el estado inicial de cada caso.
  La API guarda un único estado compartido por todos los que la usan, por eso la preparación
  se reintenta si otra persona cambia el estado mientras se está preparando.

  Background:
    * url baseUrl
    * headers { Content-Type: 'application/json', Accept: 'application/json' }

  @consultarEstado
  Scenario: Consultar el estado actual del torniquete
    Given path 'torniquete/estado'
    When method get
    Then status 200
    * def estadoActual = response.estadoActual
    * print 'Estado actual del torniquete:', estadoActual

  @dispararEvento
  Scenario: Disparar un evento (con su guardia) sobre el torniquete
    Given path 'torniquete/evento'
    And request { evento: '#(evento)', guardia: '#(guardia)' }
    When method post
    Then status 200
    * def resultado = response

  @prepararUnaVez
  Scenario: Reiniciar a S1 (Bloqueado) y disparar las transiciones válidas hasta el estado objetivo
    * def rutas =
      """
      {
        'S1 (Bloqueado)':     [],
        'S2 (Autorizado)':    [{ evento: 'Validar Tarjeta', guardia: true }],
        'S3 (Girando)':       [{ evento: 'Validar Tarjeta', guardia: true }, { evento: 'Empujar', guardia: null }],
        'S4 (Mantenimiento)': [{ evento: 'Alarma', guardia: true }]
      }
      """
    * def ruta = rutas[estadoObjetivo]
    * if (!ruta) karate.fail('Estado objetivo desconocido: ' + estadoObjetivo)
    Given path 'torniquete/reiniciar'
    And request {}
    When method post
    Then status 200
    * call read('@dispararEvento') ruta
    * def consulta = call read('@consultarEstado')
    * def estadoFinal = consulta.estadoActual

  @llevarAEstado
  Scenario: Llevar el torniquete desde S1 (Bloqueado) hasta el estado indicado
    # 1. Consultar el estado en el que quedó la máquina
    * call read('@consultarEstado')
    # 2. Reiniciar a S1 y moverla hasta el estado objetivo (hasta 5 intentos si hay interferencia)
    * def preparar =
      """
      function(objetivo) {
        for (var i = 1; i <= 5; i++) {
          var r = karate.call('classpath:features/torniquete/torniquete-utils.feature@prepararUnaVez', { estadoObjetivo: objetivo });
          if (r.estadoFinal == objetivo) return true;
          karate.log('Intento', i, ': se esperaba', objetivo, 'pero el estado es', r.estadoFinal, '- reintentando');
          java.lang.Thread.sleep(2000);
        }
        return false;
      }
      """
    # 3. Verificar que quedó en el estado objetivo
    * assert preparar(estadoObjetivo)
