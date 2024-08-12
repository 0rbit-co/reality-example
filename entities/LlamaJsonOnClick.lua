-- ADD to your World or WorldTemplate.lua using below
-- RealityEntitiesStatic = {
--     ['PID WHERE LLAMA LOADED'] = {
--           Position = { 6, 6 },
--           Type = 'Avatar',
--           Metadata = {
--             DisplayName = '0rbit Llama',
--             SkinNumber = 3,
--             Interaction = {
--               Type = 'SchemaForm',
--               Id = 'GetRealData'
--             },
--           },
--         },
--   }

local json = require('json')

-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'YOU_WORLD_ID'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_TOKEN_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"

change = false

function Validate0rbtQuantity(quantity)
  return quantity == 1000000000000
end

function ValidateJsonResource(resource)
  return resource ~= nil and type(resource) == 'string'
end


Handlers.add('Schema', Handlers.utils.hasMatchingTag('Action', 'Schema'), 
function(msg)
	print('Schema')
	local sender = msg.From
  change = false
  print("in schema".. tostring(change))
	Send({
		Target = msg.From,
		Tags = {
			Type = 'Schema'
		},
		Data = json.encode({
			GetRealData = {
				Title = "What data would you like to see?",
				Description = "Connect with 0rbit community at \n Discord: https://discord.com/invite/JVSjqaKJgV \nTwitter (X): https://x.com/0rbitco \n      Docs: https://docs.0rbit.co/",
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
								title = "Enter API URL:",
								minLength = 5,
								maxLength = 250,
                default= "https://dummyjson.com/recipes/1",
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
      print("in send req".. tostring(change)) 
      local url = msg.Tags["X-Response"] 
      local prefix = "https://dummyjson.com/recipes/"
      if(string.sub(url, 1, #prefix) ~= prefix) then 
        change = true
        print("in if cond".. tostring(change))
      end
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
        print("in recieve".. tostring(change))
        local res = json.decode(msg.Data)
        -- USE constrained string to display some of the data raw, long strings are skipped and not displayed
        local constrainedString = string.sub(json.encode(res), 1, 150)
        -- Edit and Format res or Constrained String to display Data Recieved Properly
        -- BELOW IS THE FORMATTING FOR https://dummyjson.com/recipes/1 
        -- PLEASE CHANGE FORMATTING TO SUIT RESPECTIVE URL
        local difficultyLevel =""
        local nameOf =""
        local cookTime =""
        if change == false then
        -- Traverses through decoded json to find key value pairs and assign to local variable for better display
        for k, v in pairs(res) do
          if k == "name" then
            nameOf = v
          elseif k == "difficulty" then
            difficultyLevel = v
          elseif k == "cookTimeMinutes" then
            cookTime = v
          end
        end
        print(Colors.green .. "You have received the data from the 0rbit process.")
        -- Write in Chat
        Send({
          Target = CHAT_TARGET,
          Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = '0rbit Llama',
          },
          Data = "Recipe is " .. nameOf .. " with a difficulty level of " .. difficultyLevel .. " and cook time of " .. cookTime .." minutes. Have Fun!",
        })
        print("Recipe is " .. nameOf .. " with a difficulty level of " .. difficultyLevel .. " and cook time of " .. cookTime .." minutes. Have Fun!")
      -- PROCESS A GENERAL URL WITHOUT FORMATTING
      else
        Send({
          Target = CHAT_TARGET,
          Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = '0rbit Llama',
          },
          Data = "Data is: " .. constrainedString .. "..." ,
        })
        print(constrainedString)
      end
    end
)