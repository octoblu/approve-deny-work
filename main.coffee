request     = require 'request'
_           = require 'lodash'
MeshbluHttp = require 'meshblu-http'
meshbluJson = require './meshblu.json'
messageSchema = require './approve-deny-schema'


bluprintUrl = 'https://app.octoblu.com/api/templates/dddbcda3-34ee-4ffe-831b-557ddfe19788'

auth =
  username: meshbluJson.uuid
  password: meshbluJson.token


meshblu = new MeshbluHttp meshbluJson
getBluprint = (callback=->) ->
  request.get bluprintUrl, json: true, auth: auth, (error, res, body) ->
    callback error, body

importBlueprint = (callback=->) ->
  request.post "#{bluprintUrl}/flows", json: true, auth: auth, (error, res, body) ->
    callback error, body


updateMessageSchema = ({flowId, triggerId}, callback) ->
  newSchema = _.cloneDeep messageSchema
  newSchema.messageSchema.properties.from = triggerId

  meshblu.update flowId, newSchema, (error, result) ->
    console.log {error, result}


importBlueprint (error, flow) ->
  return callback(error) if error?
  inputTrigger = _.find flow.nodes, class: 'trigger', name: 'Input'
  updateMessageSchema {flowId: flow.flowId, triggerId: inputTrigger.id}
