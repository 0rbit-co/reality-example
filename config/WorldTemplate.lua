--#region Model

RealityInfo = {
    Dimensions = 2,
    Name = 'ExampleReality',
    ['Render-With'] = '2D-Tile-0',
  }
  
  RealityParameters = {
    ['2D-Tile-0'] = {
      Version = 0,
      Spawn = { 5, 7 },
      -- This is a tileset themed to Llama Land main island
      Tileset = {
        Type = 'Fixed',
        Format = 'PNG',
        TxId = 'h5Bo-Th9DWeYytRK156RctbPceREK53eFzwTiKi0pnE', -- TxId of the tileset in PNG format
      },
      -- This is a tilemap of sample small island
      Tilemap = {
        Type = 'Fixed',
        Format = 'TMJ',
        TxId = 'koH7Xcao-lLr1aXKX4mrcovf37OWPlHW76rPQEwCMMA', -- TxId of the tilemap in TMJ format
        -- Since we are already setting the spawn in the middle, we don't need this
        -- Offset = { -10, -10 },
      },
    },
  }

  RealityEntitiesStatic = { ['E4jWlWy1XgoQaZOkwvCTLZakZGHjp9ORqRHZHDXtu_E'] = { Position = { 6, 6 }, Type = 'Avatar', Metadata = { DisplayName = '0rbit Llama', SkinNumber = 3, Interaction = { Type = 'SchemaForm', Id = 'GetRealData' }, }, }, }
  
  -- RealityEntitiesStatic = {
  --   ['PID WHERE LLAMAJSONONCLICK LOADED'] = {
  --         Position = { 6, 6 },
  --         Type = 'Avatar',
  --         Metadata = {
  --           DisplayName = '0rbit Llama',
  --           SkinNumber = 3,
  --           Interaction = {
  --             Type = 'SchemaForm',
  --             Id = 'GetRealData'
  --           },
  --         },
  --       },
  -- }

--   RealityEntitiesStatic = {
--   ['PID WHERE LLAMAJSONONSEND LOADED'] = {
--     Position = { 7, 7 },
--     Type = 'Avatar',
--     Metadata = {
--       DisplayName = 'Llama Getter',
--       SkinNumber = 3,
--       Interaction = {
--         Type = 'SchemaExternalForm',
--         Id = 'GetData'
--       },
--     },
--   },
-- }
  
  --#endregion
  
  return print("Loaded Reality Template")