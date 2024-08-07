-- ProcessName: LlamaJoker
-- ProcessId: D6sbK-aNv7doE9gjVbLxMbGKk58MToUTTq9j786UQsQ

-- This process should be used with an aos-sqlite module:
-- https://github.com/permaweb/aos-sqlite

-- Requires the `@rakis/DbAdmin` and `@sam/Llama-Herder` APM package
-- aos> .load-blueprint apm
-- aos> APM.update()
-- aos> APM.install('@rakis/DbAdmin')
-- aos> APM.install('@sam/Llama-Herder')

-- Note: `LlamaHerder` requires wrapped $AR tokens to pay for AI processing
-- You can get wrapper $AR from https://aox.xyz
-- Once you have some, send a small amount (e.g. 0.001) from
--   your wallet (e.g. ArConnect) to your agent's processId

-- To add this agent to your world, add something like the following to your world configuration:
-- RealityEntitiesStatic = {
--   ['<your agent process id here>'] = {
--     Position = { 10, 10 },
--     Type = 'Avatar',
--     Metadata = {
--       DisplayName = 'Llama Joker',
--       SkinNumber = 3,
--       Interaction = {
--         Type = 'SchemaExternalForm',
--         Id = 'MakeJoke'
--       },
--     },
--   },
-- }

-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'OqvzTvpHYrfswvVZdsSldVTNBnyBOk7kZf-oqDdvUjg'

local json = require('json')
local sqlite3 = require('lsqlite3')

Llama = Llama or nil

LLAMA_TOKEN_PROCESS = 'pazXumQI-HPH7iFGfTC-4_7biSnqz_U67oFAGry5zUY'
LLAMA_TOKEN_DENOMINATION = 12
LLAMA_TOKEN_MULTIPLIER = 10 ^ LLAMA_TOKEN_DENOMINATION
LLAMA_JOKE_PRICE_WHOLE_MIN = 5
LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY = LLAMA_JOKE_PRICE_WHOLE_MIN * LLAMA_TOKEN_MULTIPLIER

LLAMA_GIVER_PROCESS = 'D5r-wBDfgo_Cx52uYoI8YiHp7QTqvpPbL8TtcbCoaXk'

JokerDb = JokerDb or sqlite3.open_memory()
JokerDbAdmin = JokerDbAdmin or require('DbAdmin').new(JokerDb)

SQLITE_TABLE_LLAMA_CREDIT = [[
  CREATE TABLE IF NOT EXISTS LlamaCredit (
    MessageId TEXT PRIMARY KEY,
    Timestamp INTEGER,
    Sender TEXT,
    Quantity INTEGER,
    JokeTopic TEXT,
    Refunded INTEGER DEFAULT 0
  );
]]

function InitDb()
  JokerDb:exec(SQLITE_TABLE_LLAMA_CREDIT)
end

JokerInitialized = JokerInitialized or false
if (not JokerInitialized) then
  InitDb()
  Llama = require('@sam/Llama-Herder')
  Llama.getPrices()
  JokerInitialized = true
end

function ValidateLlamaQuantity(quantity)
  return quantity ~= nil
      and quantity >= LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY
      and quantity <= LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY
end

function ValidateJokeTopic(joke)
  return joke ~= nil and type(joke) == 'string' and joke:len() > 0 and joke:len() <= 20
end

function FormatLlamaTokenAmount(amount)
  return string.format("%.1f", amount / LLAMA_TOKEN_MULTIPLIER)
end

function HandleJoke(rawJoke)
  print("HandleJoke")
  print(rawJoke)

  -- Read up until the end tag, if it exists
  local jokeText = rawJoke:match("(.*)<|end|>")
  -- Read up until the first newline, if it exists
  jokeText = (jokeText or rawJoke):match("^(.-)\n") or jokeText

  if jokeText == nil or jokeText:len() == 0 then
    Send({
      Target = CHAT_TARGET,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'Llama Joker',
      },
      Data = "I'm sorry, I couldn't come up with a joke. I'm not feeling very funny today.",
    })
    return
  end

  Send({
    Target = CHAT_TARGET,
    Tags = {
      Action = 'ChatMessage',
      ['Author-Name'] = 'Llama Joker',
    },
    Data = "Ok, I think I've got a good one: " .. jokeText,
  })
end

function DispatchJokeMessage(jokeTopic)
  print("DispatchJokeMessage")
  local systemPrompt = "Tell a joke on the given topic, on one line"
  local prompt = [[<|system|>
]] .. systemPrompt .. [[<|end|>
<|user|>
Topic: ]] .. jokeTopic .. [[<|end|>
<|assistant|>
]]
  print(prompt)
  Llama.run(
    prompt,
    40,
    HandleJoke
  )
end

Handlers.add(
  "CreditNoticeHandler",
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  function(msg)
    -- print("CreditNoticeHandler")
    if msg.From ~= LLAMA_TOKEN_PROCESS then
      return print("Credit Notice not from $LLAMA")
    end

    -- Sender is from a trusted process
    local sender = msg.Tags.Sender
    local messageId = msg.Id

    local quantity = tonumber(msg.Tags.Quantity)
    if not ValidateLlamaQuantity(quantity) then
      return print("Invalid quantity")
    end

    local jokeTopic = msg.Tags['X-JokeTopic']
    if not ValidateJokeTopic(jokeTopic) then
      return print("Invalid vote")
    end

    -- Save metadata
    local stmt = JokerDb:prepare [[
      INSERT INTO LlamaCredit
      (MessageId, Timestamp, Sender, Quantity, JokeTopic)
      VALUES (?, ?, ?, ?, ?)
    ]]
    stmt:bind_values(messageId, msg.Timestamp, sender, quantity, jokeTopic)
    stmt:step()
    stmt:finalize()

    -- Send the $LLAMA on to the Llama Giver
    Send({
      Target = LLAMA_TOKEN_PROCESS,
      Tags = {
        Action = 'Transfer',
        Recipient = LLAMA_GIVER_PROCESS,
        Quantity = msg.Tags.Quantity,
      },
    })

    -- Write in Chat
    Send({
      Target = CHAT_TARGET,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'Llama Joker',
      },
      Data = "A joke about '" ..
          jokeTopic .. "' huh? That's a tough one, let me check my Great Book of Jokes (7th Edition)...",
    })

    DispatchJokeMessage(jokeTopic)
  end
)

-- Schema

function JokeSchemaTags()
  return [[
{
"type": "object",
"required": [
  "Action",
  "Recipient",
  "Quantity",
  "X-JokeTopic"
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
    "type": "number",
    "default": ]] .. LLAMA_JOKE_PRICE_WHOLE_MIN .. [[,
    "minimum": ]] .. LLAMA_JOKE_PRICE_WHOLE_MIN .. [[,
    "maximum": ]] .. LLAMA_JOKE_PRICE_WHOLE_MIN .. [[,
    "title": "$LLAMA cost (]] .. LLAMA_JOKE_PRICE_WHOLE_MIN .. [[)",
    "$comment": "]] .. LLAMA_TOKEN_MULTIPLIER .. [["
  },
  "X-JokeTopic": {
    "type": "string",
    "minLength": 1,
    "maxLength": 20,
    "default": "Llamas",
    "title": "Topic for your Joke.",
  }
}
}
]]
end

Handlers.add(
  'TokenBalanceResponse',
  function(msg)
    local fromToken = msg.From == LLAMA_TOKEN_PROCESS
    local hasBalance = msg.Tags.Balance ~= nil
    return fromToken and hasBalance
  end,
  function(msg)
    local account = msg.Tags.Account
    local balance = tonumber(msg.Tags.Balance)
    print('Account: ' .. account .. ', Balance: ' .. balance)

    if (balance >= (LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY)) then
      Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          MakeJoke = {
            Target = LLAMA_TOKEN_PROCESS,
            Title = "Wanna hear a joke?",
            Description =
            "When you've ended up at a place like this, all you can do is laugh! I'm known for my improv—send me a little $LLAMA and I'll come up with a joke just for you.",
            Schema = {
              Tags = json.decode(JokeSchemaTags()),
              -- Data
              -- Result?
            },
          },
        })
      })
    else
      Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          MakeJoke = {
            Target = LLAMA_TOKEN_PROCESS,
            Title = "Wanna hear a joke?",
            Description = "Your $LLAMA account is already a joke! Come back if you get some serious $LLAMA.",
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
      Target = LLAMA_TOKEN_PROCESS,
      Tags = {
        Action = 'Balance',
        Recipient = msg.From,
      },
    })
  end
)