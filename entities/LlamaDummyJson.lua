local json = require('json')


-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'vKbkWePtJIXSRKYWU1iaqMQKbHH43E3QblpN9NR8GV8'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_TOKEN_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"

ReceivedData = ReceivedData or {}

function Validate0rbtQuantity(quantity)
  return quantity == 1000000000000
end

function ValidateJsonResource(resource)
  return resource ~= nil and type(resource) == 'string'
end


function Register()
  print("Registering as Reality Entity")
  Send({
    Target = CHAT_TARGET,
    Tags = {
      Action = "Reality.EntityCreate",
    },
    Data = json.encode({
      Type = "Avatar",
      Metadata = {
        DisplayName = "Llama Json",
        SkinNumber = 8,
       
      },
      Position = {5, 5}
    }),
  })
end

function Temp() 
  Send({
    Target = CHAT_TARGET,
    Tags = {
      Action = "Reality.EntityUpdatePosition",
    },
    Data = json.encode({
      Position = {5, 5},
    }),
  })
end

Temp();

Register();

Handlers.add(
  "CreditNoticeHandler",
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  function(msg)
    -- print("CreditNoticeHandler")
    if msg.From ~= _0RBT_TOKEN_PROCESS then
      return print("Credit Notice not from $0RBT")
    end

    -- Sender is from a trusted process
    local sender = msg.Tags.Sender
    local messageId = msg.Id

    local quantity = tonumber(msg.Tags.Quantity)
    if not Validate0rbtQuantity(quantity) then
      return print("Invalid quantity")
    end

    -- local jsonResource = msg.Tags['X-JsonResource']
    -- if not ValidateJsonResource(jsonResource) then
    --   return print("Invalid")
    -- end

    -- -- Save metadata
    -- local stmt = JokerDb:prepare [[
    --   INSERT INTO LlamaCredit
    --   (MessageId, Timestamp, Sender, Quantity, JokeTopic)
    --   VALUES (?, ?, ?, ?, ?)
    -- ]]
    -- stmt:bind_values(messageId, msg.Timestamp, sender, quantity, jokeTopic)
    -- stmt:step()
    -- stmt:finalize()

    -- Send the $0rbt to the Llama Giver

    local url = "https://dummyjson.com/products"

    Send({
      Target = _0RBT_TOKEN_PROCESS,
      Tags = {
        Action = 'Transfer',
        Recipient = _0RBIT,
        Quantity = msg.Tags.Quantity,
        ["X-Url"] = url,
        ["X-Action"] = "Get-Real-Data"
      },
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