

# 0rbit Llama

Hi! This is how you can use **0rbit** to get **Real World Data** with your Llama. 

## Run A World
- Step 1: Clone the [Template Repository here](https://github.com/0rbit-co/reality-example)
- Step 2: Run an AOS Process in the `config` folder in your terminal with sqlite loaded. Eg:
```
aos sandboxWorld --module=u1Ju_X8jiuq4rX9Nh-ZGRQuYQZgV2MKLMT3CZsykk54
```
- Step 3: Load `Reality.lua`, `WorldTemplate.lua`, and `Chat.lua`
```
.load Reality.lua
.load WorldTemplate.lua
.load Chat.lua
```
- Step 4: Add this process's ID to https://reality-viewer.arweave.net/ and connect using a temporary wallet.
Congratulations you've ran **your own world !**
> Check out [Reality's World guide](https://github.com/elliotsayes/Reality/blob/main/docs/WorldGuide.md) to customize your world.

## Create your 0rbit Llama!

- Step 1: Run an new AOS Process in the `entities` folder in your terminal
- Step 2: Add the Process ID of your world to chat target in `LlamaJsonOnClick.lua`
`CHAT_TARGET = 'YOUR_WORLD_ID'`
- Step 3: Load `LlamaJsonOnClick.lua`
```
.load LlamaJsonOnClick.lua
```
- Step 4: Now add the below in your `WorldTemplate.lua` file with the Process ID of your Llama:
```
RealityEntitiesStatic = {
    ['PID WHERE LLAMA LOADED'] = {
          Position = { 6, 6 },
          Type = 'Avatar',
          Metadata = {
            DisplayName = '0rbit Llama',
            SkinNumber = 3,
            Interaction = {
              Type = 'SchemaForm',
              Id = 'GetRealData'
            },
          },
        },
  }
```
 - Step 5: Reload WorldTemplate.lua in its respective process
```
.load WorldTemplate.lua
```
Refresh you RealityViewer Page and Voila!

**Congratulations you've added your llama  to your world !**

## Before Interacting make sure your Llama process has some $0RBT.
You can check balance by running the following command in llama process terminal:
````lua
Send({Target="BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc", Action="Balance"})
````
Send **[$0RBT](https://docs.0rbit.co/protocol/token)** to the process ID though your wallet.

---

## Connect with us
If you have any doubts, you can connect with us on
- [Discord](https://discord.com/invite/JVSjqaKJgV)
- [X](https://x.com/0rbitco)
