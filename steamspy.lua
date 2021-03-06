-- Require data from Steam API reading JSON from SteamSpy's API (http://steamspy.com/api.php?request=genre&genre=Indie)
--[[
json = require("json")
https = require("ssl.https")
socket = require("socket")

steam_data = json.decode(io.open("steam_data_2019.json"):read("*a"))
n = 0
for app_id, app_data in pairs(steam_data) do
    local min_owners = app_data.owners:sub(1, app_data.owners:find("%.")-2):gsub(',', '')
    if tonumber(app_data.initialprice) >= 999 and tonumber(min_owners) >= 20000 then
        local body, code, headers, status = https.request("https://store.steampowered.com/api/appdetails?appids=" .. app_id)
        if tonumber(code) == 200 then
            local data = json.decode(body)
            local release_date = data[app_id].data.release_date.date
            print(app_data.name, tonumber(min_owners), tonumber(app_data.initialprice), release_date)
        end
        socket.sleep(2)
        n = n + 1
    end
end
print(n)
]]--

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from-1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

all_data = {}
local owners = {20000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000}
for line in io.lines("game_data_2019") do
  local game_data = line:split("|")
  local game = {}
  for k, v in pairs(game_data) do
    if k == 1 then game.name = v
    elseif k == 2 then game.owners = tonumber(v)
    elseif k == 3 then game.price = tonumber(v)
    elseif k == 4 then 
      day, month, year = v:match("(%d%d?) (%S+) (%d%d%d%d)")
      game.date = {day = tonumber(day), month = month, year = tonumber(year)}
    end
  end
  table.insert(all_data, game)
end

--[[
table.sort(all_data, function(a, b) return (a.date.year or 0) < (b.date.year or 0) end)
for _, v in ipairs(all_data) do
  print(v.name, v.owners, v.price, v.date.day, v.date.month, v.date.year)
end
]]--

year_buckets = {}
month_buckets = {}
day_buckets = {}
price_buckets = {}
for _, v in ipairs(all_data) do
  local year = v.date.year or 0
  if not year_buckets[year] then year_buckets[year] = 0 end
  year_buckets[year] = year_buckets[year] + 1

  local month = v.date.month or 0
  if not month_buckets[month] then month_buckets[month] = 0 end
  month_buckets[month] = month_buckets[month] + 1

  local day = v.date.day or 0
  if not day_buckets[day] then day_buckets[day] = 0 end
  day_buckets[day] = day_buckets[day] + 1

  local price = v.price or 0
  if not price_buckets[price] then price_buckets[price] = 0 end
  price_buckets[price] = price_buckets[price] + 1
end

--[[
for year, n in pairs(year_buckets) do
    print(year, n)
end
]]--

--[[
for month, n in pairs(month_buckets) do
    print(month, n)
end
]]--

--[[
for day, n in pairs(day_buckets) do
    print(day, n)
end
]]--

for price, n in pairs(price_buckets) do
    print(price, n)
end

--[[
all_data = {}
local owners = {20000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000}
for line in io.lines("game_data_2019") do
    local name, i, j = '', 1, 1
    while name == '' do
        i = line:find(tostring(owners[j]), 1)
        if i then name = line:sub(1, i-1) end
        j = j + 1
    end

    local min_owners, j = 0, #owners
    local start, finish = nil, nil
    while min_owners == 0 do
        start, finish = line:find(owners[j], 1)
        if start and finish then min_owners = owners[j] end
        j = j - 1
    end

    local match = line:match("%d%d%d%d?%d?")
    if match then price = tonumber(line:match("%d%d%d%d?%d?"):sub(2, -2)) end

    print(name, price)

    if price then
        start, finish = line:find(tostring(price))
        date = line:sub(finish+1, -1)
        day, month, year = date:match("(%d%d?) (%S+) (%d%d%d%d)")
        table.insert(all_data, {name = name, owners = min_owners, price = price, year = tonumber(year), month = month, day = tonumber(day)})
    else 
        table.insert(all_data, {name = name, owners = min_owners, price = price})
    end
end

table.sort(all_data, function(a, b) return (a.year or 0) < (b.year or 0) end)
year_buckets = {}
month_buckets = {}
day_buckets = {}
for _, v in ipairs(all_data) do
    local year = v.year or 0
    if not year_buckets[year] then year_buckets[year] = 0 end
    year_buckets[year] = year_buckets[year] + 1

    local month = v.month or 0
    if not month_buckets[month] then month_buckets[month] = 0 end
    month_buckets[month] = month_buckets[month] + 1

    local day = v.day or 0
    if not day_buckets[day] then day_buckets[day] = 0 end
    day_buckets[day] = day_buckets[day] + 1
end

for year, n in pairs(year_buckets) do
    print(year, n)
end

for month, n in pairs(month_buckets) do
    print(month, n)
end

for day, n in pairs(day_buckets) do
    print(day, n)
end
]]--
