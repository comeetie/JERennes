library(readr)
cdef=cols(
  journey_id = col_double(),
  trip_id = col_character(),
  journey_start_datetime = col_datetime(format = ""),
  journey_start_date = col_character(),
  journey_start_time = col_time(format = ""),
  journey_start_lon = col_double(),
  journey_start_lat = col_double(),
  journey_start_insee = col_character(),
  journey_start_department = col_character(),
  journey_start_town = col_character(),
  journey_start_towngroup = col_character(),
  journey_start_country = col_character(),
  journey_end_datetime = col_datetime(format = ""),
  journey_end_date = col_character(),
  journey_end_time = col_time(format = ""),
  journey_end_lon = col_double(),
  journey_end_lat = col_double(),
  journey_end_insee = col_character(),
  journey_end_department = col_character(),
  journey_end_town = col_character(),
  journey_end_towngroup = col_character(),
  journey_end_country = col_character(),
  passenger_seats = col_double(),
  operator_class = col_character(),
  journey_distance = col_double(),
  journey_duration = col_double(),
  has_incentive = col_character()
)

data=read_delim("RPC_2022-07.csv",delim=";",col_types = cdef)

library(sf)
library(dplyr)


locations = data |> 
  rename(name=journey_start_town,lat=journey_start_lat,lon=journey_start_lon) |>
  bind_rows(data |> 
              rename(name=journey_end_town,lat=journey_end_lat,lon=journey_end_lon)) |>
  group_by(name,lat,lon) |> 
  summarize() |> 
  ungroup() |>
  mutate(id=1:n()) 

write_csv(locations|>select(id,name,lat,lon),"locations.csv")


flows = data |>
  left_join(locations|>select(lat,lon,id)|>rename(origin=id),by=c("journey_start_lat"="lat","journey_start_lon"="lon")) |> 
  left_join(locations|>select(lat,lon,id)|>rename(dest=id),by=c("journey_end_lat"="lat","journey_end_lon"="lon")) |> 
  count(origin,dest) |> 
  rename(count=n)

write_csv(flows |> select(origin,dest,count),"flows.csv")



locations_towns = data |> 
  rename(id=journey_start_insee,name=journey_start_town,lat=journey_start_lat,lon=journey_start_lon) |>
  bind_rows(data |> 
              rename(id=journey_end_insee,name=journey_end_town,lat=journey_end_lat,lon=journey_end_lon)) |>
  group_by(id) |> 
  summarize(lat=first(lat),lon=first(lon),name=first(name)) |> 
  ungroup()

write_csv(locations_towns|>select(id,name,lat,lon),"locations_towns.csv")


flows_towns = data |> rename(origin=journey_start_insee,dest=journey_end_insee) |>
  count(origin,dest) |> 
  rename(count=n)

write_csv(flows_towns |> select(origin,dest,count),"flows_towns.csv")

library(lubridate)
flows_towns_dates = data |> rename(origin=journey_start_insee,dest=journey_end_insee) |>
  mutate(time=round_date(journey_start_datetime,"hour")) |>
  count(origin,dest,time) |> 
  rename(count=n) |>
  mutate(time=as.character(time)) |> 
  select(origin,dest,count,time)

write_csv(flows_towns_dates ,"flows_towns_dates.csv")



devtools::install_github("FlowmapBlue/flowmapblue.R")
library(flowmapblue)
mapboxAccessToken <- 'pk.eyJ1IjoiY29tZWV0aWUiLCJhIjoiY2xiNmE3dTJrMGI0ZTNub2E3c3RhNWdsbCJ9.eaHsSZnu_0vZD40IUq0DNA'
flowmapblue(locations_towns, flows_towns, mapboxAccessToken, clustering=TRUE, darkMode=TRUE, animation=FALSE)
