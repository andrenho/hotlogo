#include "logo.h"

#include <cassert>
#include <cstdlib>
extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>
}

#include <iostream>
#include <sstream>


Logo::Logo()
    : L(luaL_newstate())
{
    putenv("LUA_PATH=../?.lua;;");
    luaL_openlibs(L);
    int r = luaL_loadfile(L, "../eval-apply/eval-apply.lua");
    assert(r == LUA_OK);
    lua_pcall(L, 0, 0, 0);
}


Logo::~Logo()
{
    lua_close(L);
}


void 
Logo::OpenList()
{
    ++level;
    lua_newtable(L);
}


void 
Logo::CloseList()
{
    --level;
    if(level > 0) {
        lua_seti(L, -2, luaL_len(L, -2) + 1);
    } else {
        Eval();
    }
}


void 
Logo::Add(string const& s)
{
    lua_pushstring(L, s.c_str());
    if(level == 0) {
        Eval();
    } else {
        lua_seti(L, -2, luaL_len(L, -2) + 1);
    }
}


void 
Logo::Add(double d)
{
    lua_pushnumber(L, d);
    if(level == 0) {
        Eval();
    } else {
        lua_seti(L, -2, luaL_len(L, -2) + 1);
    }
}


void
Logo::Eval() const
{
    lua_getglobal(L, "eval");
    assert(lua_gettop(L) == 2);
    lua_insert(L, 1);
    lua_pcall(L, 1, 1, 0);
    Print();
}


void 
Logo::Print() const
{
    assert(lua_gettop(L) == 1);

	int t = lua_type(L, 1);
    if(t == LUA_TNUMBER) {
        printf("%g\n", lua_tonumber(L, 1));
    } else if(t == LUA_TSTRING) {
        printf("\"%s\"\n", lua_tostring(L, 1));
    } else if(t != LUA_TNIL) {
        printf("unsupported type %s\n", lua_typename(L, t));
    }

    lua_pop(L, 1);
}



string
Logo::StackDump() const
{
    int top = lua_gettop(L);

    auto inspect = [&](int i) {
        lua_getglobal(L, "inspect");
        lua_pushvalue(L, i);
        lua_pcall(L, 1, 1, 0);
        string s(lua_tostring(L, -1));
        lua_pop(L, 1);
        return s;
    };

    stringstream ss;
    ss << "Current lua stack:\n";
    for(int i=1; i<=top; ++i) {
        ss << "  " << i << "/" << i-top-1 << ": " << inspect(i) << "\n";
    }
    ss << "-----------------\n";
    cerr << ss.str();
    cerr.flush();
    return ss.str();
}



// vim: ts=4:sw=4:sts=4:expandtab
