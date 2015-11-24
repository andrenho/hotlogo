#include "logo.h"

#include <cassert>
#include <cstdlib>
extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>
}

Logo::Logo()
    : L(luaL_newstate(), [](lua_State* L) { lua_close(L); })
{
    putenv("LUA_PATH=../?.lua;;");
    int r = luaL_loadfile(L.get(), "../eval-apply/eval-apply.lua");
    assert(r == LUA_OK);
}


void 
Logo::OpenList()
{
}


void 
Logo::CloseList()
{
}


void 
Logo::Add(string const& s)
{
}


void 
Logo::Add(double d)
{
}


// vim: ts=4:sw=4:sts=4:expandtab
