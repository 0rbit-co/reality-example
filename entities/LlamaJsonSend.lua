local json = require('json')

-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'TPJR7LLxa6T8ARfRcMCKJk-528qzrOFIZPRMjtxeSN8'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_TOKEN_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"

ReceivedData = ReceivedData or {}

function Validate0rbtQuantity(quantity)
  return quantity == 1000000000000
end

function ValidateJsonResource(resource)
  return resource ~= nil and type(resource) == 'string'
end




Handlers.add(
  "CreditNoticeHandler",
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  function(msg)
    -- print("CreditNoticeHandler")
    if msg.From ~= _0RBT_TOKEN_PROCESS then
      return print("Credit Notice not from $0RBT")
    end

    -- if msg.Tags.Sender == "TvAU5PdmCQ1XIWjtLOIpp_S47eDhCSBzNnFsSlT7WVs" then
    --     return print("Just refill")
    -- end

    -- Sender is from a trusted process
    local sender = msg.Tags.Sender
    local messageId = msg.Id

    local quantity = tonumber(msg.Tags.Quantity)
    if not Validate0rbtQuantity(quantity) then
      return print("Invalid quantity")
    end

    local url = "https://dummyjson.com/products"


    Send({
      Target = _0RBT_TOKEN_PROCESS,
        Action = 'Transfer',
        Recipient = _0RBIT,
        Quantity = msg.Tags.Quantity,
        ["X-Url"] = msg.Tags['X-UrlToSend'],
        ["X-Action"] = "Get-Real-Data"
    }) 
    -- DispatchJokeMessage(jokeTopic)
  end
)

Handlers.add(
    "Receive-Data",
    Handlers.utils.hasMatchingTag("Action", "Receive-Response"),
    function(msg)
        local res = json.decode(msg.Data)
        local constrainedString = string.sub(json.encode(res), 1, 40)
        ReceivedData = res
        print(Colors.green .. "You have received the data from the 0rbit process.")
        -- Write in Chat
        Send({
          Target = CHAT_TARGET,
          Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Llama Json',
          },
          Data = "Dtat is:" .. constrainedString ,
        })
        print("Dtat is:" .. constrainedString)
    end
)



function JsonSchemaTags()
  return [[
{
"type": "object",
"required": [
  "Action",
  "Recipient",
  "Quantity",
  "X-UrlToSend",
],
"properties": {
  "Action": {
    "type": "string",
    "const": "Transfer"
  },
  "Recipient": {
    "type": "string",
    "const": "]] .. ao.id .. [["
  },
  "Quantity": {
    "type": "string",
    "const": "1000000000000"
  },
  "X-UrlToSend": {
    "type": "string",
    "minLength": 1,
    "maxLength": 150,
    "default": "https://dummyjson.com/products",
    "title": "Url for your request",
  }
}
}
]]
end

Handlers.add(
  'TokenBalanceResponse',
  function(msg)
    local fromToken = msg.From == _0RBT_TOKEN_PROCESS
    local hasBalance = msg.Tags.Balance ~= nil
    return fromToken and hasBalance
  end,
  function(msg)
    local account = msg.Tags.Account
    local balance = msg.Tags.Balance
    print('Account: ' .. account .. ', Balance: ' .. balance)

    if (balance >= "1000000000000") then
      print("bal pass")
      Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          GetData = {
            Target = _0RBT_TOKEN_PROCESS,
            Title = "Wanna know secrets?",
            Description =
            "Explore what you can know",
            Schema = {
              Tags = json.decode(JsonSchemaTags()),
            },
          },
        })
      })
    else
      print("bal no pass")
      Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          GetData = {
            Target = _0RBT_TOKEN_PROCESS,
            Title = "Wanna know secrets?",
            Description = "You cant, ya broke",
            Schema = nil,
          },
        })
      })
    end
  end
)


Handlers.add(
  'SchemaExternal',
  Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
  function(msg)
    print('SchemaExternal')
    Send({
      Target = _0RBT_TOKEN_PROCESS,
      Tags = {
        Action = 'Balance',
        Recipient = msg.From,
      },
    })
  end
)