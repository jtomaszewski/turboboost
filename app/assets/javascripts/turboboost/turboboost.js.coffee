@Turboboost =
  handleFormDisabling: true
  defaultError: "Sorry, there was an error."

turboboostable = "[data-turboboost]"

enableForm = ($form) ->
  $form.find("[type='submit']").removeAttr('disabled').data('turboboostDisabled', false)

disableForm = ($form) ->
  $form.find("[type='submit']").attr('disabled', 'disabled').data('turboboostDisabled', true)

tryJSONParse = (str) ->
  try
    JSON.parse str
  catch e
    null

turboboostComplete = (e, resp) ->
  $el = $(@)
  isForm = @nodeName is "FORM"

  $el.trigger "turboboost:success", tryJSONParse resp.getResponseHeader('X-Flash')
  if (location = resp.getResponseHeader('Location')) and !$el.attr('data-no-turboboost-redirect')
    # e.preventDefault()
    # e.stopPropagation()
    # Turbolinks.visit(location)
    return
  else
    Turbolinks.replace(resp.responseText)
    $(document).trigger "page:load"

  # if resp.status in [400..599]
  #   enableForm $el if isForm and Turboboost.handleFormDisabling
  #   $el.trigger "turboboost:error", resp.responseText

  $el.trigger "turboboost:complete"

turboboostBeforeSend = (e, xhr, settings) ->
  xhr.setRequestHeader('X-Turboboost', '1')
  isForm = @nodeName is "FORM"
  return e.stopPropagation() unless isForm
  $el = $(@)
  disableForm $el if Turboboost.handleFormDisabling
  if settings.type is "GET" and !$el.attr('data-no-turboboost-redirect')
    Turbolinks.visit [@action, $el.serialize()].join("?")
    return false

maybeReenableForms = ->
  return unless Turboboost.handleFormDisabling
  $("form#{turboboostable} input[type='submit']").each ->
    enableForm $(@).closest('form') if $(@).data('turboboostDisabled')

$(document)
  .on("ajax:beforeSend", turboboostable, turboboostBeforeSend)
  .on("ajax:complete", turboboostable, turboboostComplete)
  .on("page:restore", maybeReenableForms)
