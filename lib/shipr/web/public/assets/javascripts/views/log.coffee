class @Log extends Backbone.View
  pusher: window.pusher

  initialize: ->
    @id      = @$el.data('id')
    @channel = window.pusher.subscribe @$el.data('channel')

    @channel.bind 'output', @output

  # Internal: Called when there's new log output to append.
  output: (data) =>
    sticky = $(document).scrollTop() + $(window).height() >= $(document).height() - 100
    @$el.html(@$el.html() + data.output) if data.id == @id
    $(document).scrollTop($(document).height()) if sticky
