---
---
selectDate = (k, v) ->
  $('ul.archive').fadeOut ->
    $("[data-item-"+k+"]").each (i) ->
      if ($(@).attr 'data-item-'+k) == v
        $(@).show()
      else
        $(@).hide()
    $('ul.archive').fadeIn()

clearDate = ->
  $('ul.archive').fadeOut ->
    $("*[data-item-year]").each (i) ->
      $(@).show()
    $('ul.archive').fadeIn()

$( document ).ready ->
  $("#yearSelect*").click (e) ->
    year = $(e.target).attr 'date-select-year'
    selectDate 'year', year

  $("#monthSelect*").click (e) ->
    month = $(e.target).attr 'date-select-month'
    selectDate 'month', month

  $("#allSelect*").click (e) ->
    clearDate()
