vote = ->
  $('.vote').bind 'ajax:success', (e) ->
    $(this).parent().find('p.total_votes').html(e.detail[0])


$(document).ready(vote) # "вешаем" функцию ready на событие document.ready
$(document).on('turbolinks:load', vote)  # "вешаем" функцию ready на событие page:load
