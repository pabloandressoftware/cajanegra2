@ignore
Feature: Calentamiento del servidor de Render

  Scenario: Despertar la API antes de ejecutar la suite
    Given url baseUrl
    And path 'ejercicios'
    And configure retry = { count: 5, interval: 10000 }
    And retry until responseStatus == 200
    When method get
    Then status 200
