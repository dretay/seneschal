--get request arguments
local args = ngx.req.get_uri_args()

--grab token and remove from args table
local token = ngx.decode_base64(args["token"])
args["token"] = nil

--decrypt token and build username / password
local aes = require "resty.aes"
local str = require "resty.string"
local split = require "utils"
local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC", "145a2f0e39c6d84c58ccba257dd43908", aes.cipher(256,"cbc"), aes.hash.sha512, 1000)

local decrypted = JSON:decode(aes_256_cbc_sha512x5:decrypt(token))

t = {username = decrypted.rabbitmq:split(":")[1], password = decrypted.rabbitmq:split(":")[2]}

ngx.say(JSON:encode(t))
