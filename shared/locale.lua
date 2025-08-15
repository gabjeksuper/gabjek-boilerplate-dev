
L = function(key, ...)
    local loc = Config and Config.Locale or 'en'
    local dict = Locales and Locales[loc] or Locales['en']
    local str = dict and dict[key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end
