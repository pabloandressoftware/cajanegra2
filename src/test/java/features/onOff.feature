Feature: Yo como tester quiero probar la funcionalidad de interruptor inteligente

  Scenario: Verificar el estado del interruptor en un momento dado
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/state'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    When method GET
    Then status 200
    * print 'Estado actual del interruptor:', response.state

  @smokeTest
  Scenario: Verificar que el interruptor acepta solicitudes
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/state'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    When method GET
    Then status 200
    * print 'Get status:' , responseStatus

  @ignore @doOn
  Scenario: Do Turn On
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/on'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And headers 'Content-Length': '0'
    When method post
    * print 'Response status when state is Off and do On :', responseStatus
    * match responseStatus == 200
    * match response == { state: 'on' }

  @ignore  @invalidTransicion @invalidtransicionDoOn
  Scenario: Do Turn On
    Given url 'https://statemachine--maria7221.replit.app/api/'
    And path 'switch/on'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And headers 'Content-Length': '0'
    When method post
    * print 'Response status when state is On and do On :', responseStatus
    * match responseStatus == 409
    * match response == { error: 'Invalid transition: the switch is already on' }

  @startOn
  Scenario: Verificar que el interruptor pueda encenderse
    * def response = call read('@smoketest')
    * eval if (response.state == 'off') karate.call(read('@doOn'))
    * eval if (response.state == 'on') karate.call(read('@invalididtrancisionDoON'))
