
Util = {}

local function now_ms()
    if GetGameTimer then return GetGameTimer() end
    return math.floor(os.clock() * 1000)
end

function Util.Debug(...)
    if Config and Config.Debug then
        local t = {}
        for i=1,select('#', ...) do t[#t+1] = tostring(select(i, ...)) end
        print('[DEBUG] ' .. table.concat(t, ' '))
    end
end

local _json_encode = (json and json.encode) or function(tbl)
    local ok, res = pcall(function() return tostring(tbl) end)
    return ok and res or '<tbl>'
end

function Util.ToJSON(tbl) return _json_encode(tbl) end

function Util.SanitizeText(s, maxlen)
    if type(s) ~= 'string' then return '' end
    s = s:gsub('%c', ''):gsub('[\r\n]', ' ')
    if maxlen and #s > maxlen then s = s:sub(1, maxlen) end
    return s
end

local buckets = {}
function Util.RateLimit(key, max, window_s)
    local b = buckets[key]
    local now = now_ms()
    local win = (window_s or 10) * 1000
    if not b or (now - b.start) > win then
        buckets[key] = { start = now, count = 1 }
        return true
    else
        if b.count < (max or 5) then
            b.count = b.count + 1
            return true
        else
            return false
        end
    end
end

function Util.PlayerActive(id)
    id = tonumber(id)
    if not id then return false end
    return GetPlayerName(id) ~= nil
end
