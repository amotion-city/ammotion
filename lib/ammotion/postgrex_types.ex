Postgrex.Types.define(Ammo.PostgrexTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(), json: Jason)
