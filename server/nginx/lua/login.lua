--load libraries
local ck = require "resty.cookie"
local redis = require "resty.redis"
local aes = require "resty.aes"
local str = require "resty.string"
local split = require "utils"
local ini = require "2ion.ini"
local uuid = require "uuid"

--load config
local conf = ini.read("/home/pi/dev/seneschal/server/daemons/config/site.ini")
secret = conf['openresty']['secret']

--configure libraries
local cookie,err = ck:new()
if not cookie then
  ngx.log(ngx.ERR, err)
  return
end

local red = redis:new()
red:set_timeout(2000)
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect to redis server: ", err)
    return
end

local systemCipher = aes:new("AKeyForAES-256-CBC", secret, aes.cipher(256,"cbc"), aes.hash.sha512, 1000)

--read in post  / get arguments
ngx.req.read_body()
local args = ngx.req.get_post_args()
local username = args["username"]
local password = args["password"]
local userSecret = args["secret"]
if not username or not password then
  args = ngx.req.get_uri_args()
  username = args["username"]
  password = args["password"]
  secret = args["secret"]
  if not username or not password or not userSecret then
    ngx.status = 401
    ngx.say("failed load username / password / userSecret from post body")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
    return
  end
end

if secret == userSecret
  -- this creates a new user in the system:
  passEntry = JSON:encode({password= password, salt=uuid()})
  passEntryCipher = ngx.encode_base64(systemCipher:encrypt(passEntry))
  ok, err = red:set(username .. ":pass", passEntryCipher)
  if not ok then
      ngx.say("failed to set password: ", err)
      return
  end
else
  ngx.status = 401
  ngx.say("invalid secret")
  ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- --get account password
-- local token, err = red:get(username .. ":pass")
-- if not token or token == ngx.null then
--     ngx.status = 401
--     ngx.say("failed locate account for user ",username)
--     ngx.exit(ngx.HTTP_UNAUTHORIZED)
--     return
-- end
-- local passEntry = JSON:decode(systemCipher:decrypt(ngx.decode_base64(token)))

-- -- check password for validation
-- if password == passEntry["password"] then
--   -- generate cookie (salt + pass)
--   -- for now lookup and include every account, in the future this
--   -- could be limited
--   local userCipher = aes:new("AKeyForAES-256-CBC", passEntry["password"] .. passEntry["salt"], aes.cipher(256,"cbc"), aes.hash.sha512, 1000)
--   local accountTable = JSON:encode({
--     rabbitmq = {
--       username="webclient",
--       password="WwTMfbtzxGNGhte0kxao"
--     },
--     foscam = {
--       username="drew",
--       password="p3anutbutter"
--     }
--   })
--   local encryptedAccountTable = userCipher:encrypt(accountTable)
--   local ok, err = cookie:set({
--     key = "authentication", value = username .. ":" .. ngx.encode_base64(encryptedAccountTable), path = "/",
--     domain = "drewandtrish.com", secure = true, httponly = true,
--     expires = "Wed, 09 Jun 2021 10:18:14 GMT", max_age = 50,
--     extension = "a4334aebaec"
--   });
--   if not ok then
--     ngx.log(ngx.ERR, err)
--     return
--   end
--   ngx.exit(ngx.HTTP_OK)
-- else
--   ngx.exit(ngx.HTTP_UNAUTHORIZED)
-- end


