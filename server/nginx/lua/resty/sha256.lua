-- Copyright (C) 2012 by Yichun Zhang (agentzh)


local sha = require "resty.sha"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C
local setmetatable = setmetatable
local error = error


module(...)

_VERSION = '0.08'


local mt = { __index = _M }


ffi.cdef[[
typedef struct SHA256state_st
        {
        SHA_LONG h[8];
        SHA_LONG Nl,Nh;
        SHA_LONG data[SHA_LBLOCK];
        unsigned int num,md_len;
        } SHA256_CTX;

int SHA256_Init(SHA256_CTX *c);
int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
int SHA256_Final(unsigned char *md, SHA256_CTX *c);
]]

local digest_len = 32

local buf = ffi_new("char[?]", digest_len)
local ctx_ptr_type = ffi.typeof("SHA256_CTX[1]")


function new(self)
    local ctx = ffi_new(ctx_ptr_type)
    if C.SHA256_Init(ctx) == 0 then
        return nil
    end

    return setmetatable({ _ctx = ctx }, mt)
end


function update(self, s)
    return C.SHA256_Update(self._ctx, s, #s) == 1
end


function final(self)
    if C.SHA256_Final(buf, self._ctx) == 1 then
        return ffi_str(buf, digest_len)
    end

    return nil
end


function reset(self)
    return C.SHA256_Init(self._ctx) == 1
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)

