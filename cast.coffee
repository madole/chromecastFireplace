session = null
loaded = null
window.onload = ->
  if !chrome.cast || !chrome.cast.isAvailable
    setTimeout initialiseCastApi, 1000

initialiseCastApi = ->
  sessionRequest = new chrome.cast.SessionRequest chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID
  apiConfig = new chrome.cast.ApiConfig sessionRequest, sessionListener, receiverListener
  chrome.cast.initialize apiConfig, onInitSuccess, onLaunchError

onInitSuccess = (e) ->
  console.log 'successful initialisation'
  receiverListener e

receiverListener = (e) ->
  if e is chrome.cast.ReceiverAvailability.AVAILABLE
    console.log 'device available'
    loaded = true

window.launch = ->
  if loaded is true
    chrome.cast.requestSession onRequestSessionSuccess, onLaunchError
  else
    initialiseCastApi()

onRequestSessionSuccess = (e) ->
  console.log 'here'
  
  session = e
  mediaInfo = new chrome.cast.media.MediaInfo 'http://media.giphy.com/media/6gy3wSuc2EnIs/giphy.gif', 'image/gif'
#  mediaInfo = new chrome.cast.media.MediaInfo 'http://dc437.4shared.com/img/jMdBfbDe/s3/1334fc01420/cute-cat.jpg', 'image/jpg'
  request = new chrome.cast.media.LoadRequest mediaInfo
  console.log request
  session.loadMedia request, onMediaDiscovered.bind(this, 'loadMedia'), onMediaError


onMediaDiscovered = (how, media) ->
  currentMedia = media
  console.log "onMediaDiscovered #{how} - #{media}"

onLaunchError = (e) ->
  console.log 'Launch Failed' + JSON.stringify e

onMediaError = ->
  console.log 'Media Failed'

sessionListener = (e) ->
  session = e
  if session.media.length is not 0
    onMediaDiscovered 'onRequestSessionSuccess', session.media[0]

window.stopApp = ->
  session.stop onSuccess, onError

onSuccess = ->
  console.log 'Successfull kill of app'
onError = ->
  console.log 'App is already dead... Restarting'
  session = null
  launch()
  