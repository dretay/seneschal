--module definition
local AuthManager = {}
local _VERSION = '0.01'

--load libraries
local JSON = require "JSON"
local URLCODE = require "urlcode"
local ck = require "resty.cookie"
local redis = require "resty.redis"
local aes = require "resty.aes"
local str = require "resty.string"
local split = require "utils"
local ini = require "2ion.ini"
local uuid = require "uuid"

-- Helper functions
local function addXDomainHeaders()
  ngx.header["Access-Control-Allow-Origin"] = ngx.var.http_origin;
  ngx.header["Access-Control-Allow-Credentials"] ='true';
end
local function getParams()
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
    userSecret = args["secret"]
    if not username or not password then
      ngx.status = 401
      ngx.log(ngx.WARN,"failed load username / password from post body")
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
      return
    end
  end
  return username, password, userSecret
end

local function init()
  local conf = ini.read("/home/pi/dev/seneschal/server/daemons/config/site.ini")
  local secret = conf['openresty']['secret']

  --configure cookie library
  local cookie,err = ck:new()
  if not cookie then
    ngx.log(ngx.ERR, err)
    return
  end

  --configure redis library
  local red = redis:new()
  red:set_timeout(2000)
  local ok, err = red:connect("127.0.0.1", 6379)
  if not ok then
      ngx.log(ngx.WARN,"failed to connect to redis server: ".. err)
      return
  end

  --configure system cipher
  local systemCipher = aes:new("AKeyForAES-256-CBC", secret, aes.cipher(256,"cbc"), aes.hash.sha512, 1000)
  return conf, cookie, red, systemCipher, secret
end


local function getAccountTable()
  --load config
  local conf, cookie, red, systemCipher = init()

  --read the cookie
  local cookieValue, err = cookie:get("authentication")
  if not cookieValue then
      ngx.log(ngx.ERR, err)
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end

  --unescape cookie contents
  cookieValue = ngx.unescape_uri(cookieValue)
  --split out the username and the ciphertext
  local username = cookieValue:split(":")[1]
  local cipherText = cookieValue:split(":")[2]

  --get account password out of redis
  local token, err = red:get(username .. ":pass")
  if not token or token == ngx.null then
      ngx.status = 401
      ngx.log(ngx.WARN,"failed locate account for user "..username)
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
      return
  end
  local passEntry = JSON:decode(systemCipher:decrypt(ngx.decode_base64(token)))

  --decrypt the cookie into a lua table
  local userCipher = aes:new("AKeyForAES-256-CBC", passEntry["password"] .. passEntry["salt"], aes.cipher(256,"cbc"), aes.hash.sha512, 1000)
  local accountTable = JSON:decode(userCipher:decrypt(ngx.decode_base64(cipherText)))

  return accountTable
end

--exported module functions
function AuthManager.getCreds(resource)
  addXDomainHeaders()
  local accountTable = getAccountTable()
  --extract / return the appropriate credentials
  ngx.print(JSON:encode(accountTable[resource]))
  return ngx.exit(ngx.OK)
end

function AuthManager.authByGetRewrite(resource, userField, passField)
  addXDomainHeaders()
  local accountTable = getAccountTable()
  --extract / return the appropriate credentials
  local args = ngx.req.get_uri_args()
  args[userField] = accountTable[resource]["username"]
  args[passField] =accountTable[resource]["password"]
  ngx.log(ngx.INFO,"finished rewriting ")
  ngx.req.set_uri_args(args)
end

function AuthManager.authByBasic(resource, userField, passField)
  addXDomainHeaders()
  local accountTable = getAccountTable()
  --extract / return the appropriate credentials
  local args = ngx.req.get_uri_args()
  local username = accountTable[resource]["username"]
  local password = accountTable[resource]["password"]
  local encodedAuth = ngx.encode_base64(username .. ":" .. password)
  ngx.req.set_header("Authorization", "Basic " .. encodedAuth)
end

function AuthManager.createUser()
  local conf, cookie, red, systemCipher, secret = init()

  --read in post  / get arguments
  local username, password, userSecret = getParams()

  if secret == userSecret then
    -- this creates a new user in the system:
    local passEntry = JSON:encode({password= password, salt=uuid()})
    local passEntryCipher = ngx.encode_base64(systemCipher:encrypt(passEntry))
    local ok, err = red:set(username .. ":pass", passEntryCipher)
    if not ok then
        ngx.log(ngx.WARN,"failed to set password: ".. err)
        return
    end
  else
    ngx.status = 401
    ngx.log(ngx.WARN,"invalid user secret".. userSecret)
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end
end
function AuthManager.login()
  addXDomainHeaders()

  --load config
  local conf, cookie, red, systemCipher = init()

  --read in post  / get arguments
  local username, password = getParams()

  --get account password
  local token, err = red:get(username .. ":pass")
  if not token or token == ngx.null then
      ngx.status = 401
      ngx.log(ngx.WARN,"failed locate account for user "..username)
      ngx.exit(ngx.HTTP_UNAUTHORIZED)
      return
  end
  local passEntry = JSON:decode(systemCipher:decrypt(ngx.decode_base64(token)))

  -- check password for validation
  if password == passEntry["password"] then
    -- generate cookie (salt + pass)
    -- for now lookup and include every account, in the future this
    -- could be limited
    local userCipher = aes:new("AKeyForAES-256-CBC", passEntry["password"] .. passEntry["salt"], aes.cipher(256,"cbc"), aes.hash.sha512, 1000)
    local accountTable = JSON:encode({
      rabbitmq = {
        username=conf["rabbitmq-webclient"]["username"],
        password=conf["rabbitmq-webclient"]["password"],
      },
      foscam = {
        username=conf["foscam"]["username"],
        password=conf["foscam"]["password"],
      }
    })
    local encryptedAccountTable = userCipher:encrypt(accountTable)
    -- expire in something like a 10 years
    -- local expires = 3600 * 24 * 365 * 10
    -- local ok, err = cookie:set({
    --   key = "authentication", value = username .. ":" .. ngx.encode_base64(encryptedAccountTable), path = "/",
    --   domain = ".drewandtrish.com",
    --   expires = ngx.cookie_time(ngx.time() + expires)
    -- });
    -- if not ok then
    --   ngx.log(ngx.ERR, err)
    --   return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    -- end
    -- return ngx.redirect("/html/index-optimize.html#/controls/mainFloor");
    ngx.say(username .. ":" .. ngx.encode_base64(encryptedAccountTable))
  else
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end
end

return AuthManager
