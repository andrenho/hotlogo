#include "logo.h"

#include <cassert>
#include <cstdlib>
#include <cstring>
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
    putenv(strdup("LUA_PATH=../?.lua;;"));
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
Logo::OpenList(string const& s)
{
    ++level;
    lua_newtable(L);
    if(s != "") {
        lua_pushstring(L, s.c_str());
        lua_seti(L, -2, luaL_len(L, -2) + 1);
    }
}


void 
Logo::OpenListInv(string const& s)
{
    ++level;
    lua_newtable(L);
    lua_pushstring(L, s.c_str());
    lua_seti(L, -2, luaL_len(L, -2) + 1);
    lua_insert(L, 1);
    lua_seti(L, -2, luaL_len(L, -2) + 1);
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

    if(parameters_left > 0) {
        --parameters_left;
        if(parameters_left == 0) {
            CloseList();
        }
    }
}


void 
Logo::Add(double d)
{
    lua_pushnumber(L, d);
    if(level == 0) {
        //Eval();  -- TODO
    } else {
        lua_seti(L, -2, luaL_len(L, -2) + 1);
    }

    if(parameters_left > 0) {
        --parameters_left;
        if(parameters_left == 0) {
            CloseList();
        }
    }
}


void 
Logo::AddCommand(string const& s)
{
    // find number of parameters of this command
    lua_getglobal(L, "parameter_count");
    lua_pushstring(L, s.c_str());
    lua_pcall(L, 1, 1, 0);
    int n_pars = lua_tonumber(L, -1);
    lua_pop(L, 1);

    if(n_pars == -1) {
        Error("Ainda não aprendi " + s);
    }

    parameters_left = n_pars + 1;  // +1 because we are counting the command itself
    OpenList();
    Add(s);
}


void 
Logo::AddTempFunction(string const& s, int n_pars)
{
    // find number of parameters of this command
    lua_getglobal(L, "add_temp_function");
    lua_pushstring(L, s.c_str());
    lua_pushnumber(L, n_pars);
    lua_pcall(L, 2, 0, 0);
}


void
Logo::Eval() const
{
    lua_getglobal(L, "eval");
    if(lua_gettop(L) != 2) {
        StackDump();
        assert(lua_gettop(L) == 2);
    }
    lua_insert(L, 1);

    lua_pushboolean(L, 1);
    lua_pcall(L, 2, 1, 0);
    
    // lua_pcall(L, 1, 1, 0);

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
    } else if(t == LUA_TBOOLEAN) {
        if(lua_toboolean(L, 1)) { printf("sim\n"); } else { printf("não\n"); }
    } else if(t != LUA_TNIL) {
        printf("unsupported type %s\n", lua_typename(L, t));
    }

    lua_pop(L, 1);
}



void 
Logo::Error(string const& s)
{
    extern void yyerror(const char* s);
    yyerror(s.c_str());
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
