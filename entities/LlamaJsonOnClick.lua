-- ADD to your World or WorldTemplate.lua using below
-- RealityEntitiesStatic = {
--     ['PID WHERE LLAMA LOADED'] = {
--           Position = { 6, 6 },
--           Type = 'Avatar',
--           Metadata = {
--             DisplayName = 'Llama OnClick',
--             SkinNumber = 3,
--             Interaction = {
--               Type = 'SchemaForm',
--               Id = 'OnClicking'
--             },
--           },
--         },
--   }

local json = require('json')

-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'YOUR WORLD ID'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_TOKEN_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"

ReceivedData = ReceivedData or {}

function Validate0rbtQuantity(quantity)
  return quantity == 1000000000000
end

function ValidateJsonResource(resource)
  return resource ~= nil and type(resource) == 'string'
end


Handlers.add('Schema', Handlers.utils.hasMatchingTag('Action', 'Schema'), function(msg)
	print('Schema')
	local sender = msg.From
	Send({
		Target = msg.From,
		Tags = {
			Type = 'Schema'
		},
		Data = json.encode({
			OnClicking = {
				Title = "Send url you want to fetch from",
				Description = "",
				Schema = {
					Tags = {
						type = "object",
						required = {
							"Action",
                            "Quantity"
						},
						properties = {
							Action = {
								type = "string",
								const = "SendReq"
							},
                            Quantity = {
                                type = "string",
                                const = "1000000000000"
                            },
                            ["X-Response"] = {
								type = "string",
								title = "Your response to the situation?",
								minLength = 5,
								maxLength = 250,
							}
						}
					}
				}
			}
		})
	})
end)

Handlers.add('SendReq', 
  Handlers.utils.hasMatchingTag('Action', 'SendReq'), 
    function(msg)
      print("SAYING Send")
      local url = msg.Tags["X-Response"] 
      print(msg.Tags.Quantity)
      Send({
              Target = _0RBT_TOKEN_PROCESS,
                Action = 'Transfer',
                Recipient = _0RBIT,
                Quantity = msg.Tags.Quantity,
                ["X-Url"] = url,
                ["X-Action"] = "Get-Real-Data"
            }) 
      print(msg.Tags["X-Response"])
    end
)

Handlers.add(
    "Receive-Data",
    Handlers.utils.hasMatchingTag("Action", "Receive-Response"),
    function(msg)
        local res = json.decode(msg.Data)
        local constrainedString = string.sub(json.encode(res), 1, 150)
        print(Colors.green .. "You have received the data from the 0rbit process.")
        -- Write in Chat
        Send({
          Target = CHAT_TARGET,
          Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Llama Json',
          },
          Data = "Data is:" .. constrainedString ,
        })
        print("Data is:" .. constrainedString)
    end
)