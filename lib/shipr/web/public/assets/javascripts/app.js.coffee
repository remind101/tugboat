#= require underscore
#= require backbone
#= require views/log

$ ->
  window.pusher = new Pusher(
    $("meta[name='pusher.key']").attr('content')
  )

  $('#log').each -> new window.Log(el: this)
