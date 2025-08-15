
assert = assert

describe('Locale helper', function()
    _G.Config = { Locale = 'en' }
    _G.Locales = { en = { hello = 'Hello %s' } }
    dofile('shared/locale.lua')
    it('formats string with args', function()
        local res = _G.L('hello', 'world')
        assert.are.equal('Hello world', res)
    end)
end)

describe('Rate limiter', function()
    _G.Config = {}
    dofile('shared/util.lua')
    it('allows first call then blocks over max within window', function()
        local key = 'test:1'
        assert.is_true(Util.RateLimit(key, 1, 1))
        local a = Util.RateLimit(key, 1, 1)
        assert.is_false(a)
    end)
end)
