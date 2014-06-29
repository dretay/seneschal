local aes = require "resty.aes"
local str = require "resty.string"
local resty_random = require "resty.random"

local salt = str.to_hex(resty_random.bytes(16,true))
local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC", "145a2f0e39c6d84c58ccba257dd43908", aes.cipher(256,"cbc"), aes.hash.sha512, 1000)


local encrypted = aes_256_cbc_sha512x5:encrypt(t)

ngx.say((ngx.encode_base64(encrypted)))
