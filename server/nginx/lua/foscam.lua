--get request arguments
local args = ngx.req.get_uri_args()

--grab token and remove from args table
local token = ngx.decode_base64(args["token"])
args["token"] = nil

--decrypt token and build username / password
local aes = require "resty.aes"
local str = require "resty.string"
local split = require "utils"
local aes_256_cbc_sha512x5 = aes:new("AKeyForAES-256-CBC", "SALT", aes.cipher(256,"cbc"), aes.hash.sha512, 1000)

local decrypted = JSON:decode(aes_256_cbc_sha512x5:decrypt(token))

local username = decrypted.foscam:split(":")[1]
local password = decrypted.foscam:split(":")[2]

--add username and password to request arguments
args["user"] =username
args["pwd"] =password
ngx.req.set_uri_args(args)
