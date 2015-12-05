#include "lpu.h"

extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>
}

#include <functional>
#include <iostream>
using namespace std;

void 
LPU::InitializePrimitives()
{
    functions["att"] = Function { 0, [](lua_State* L) { 
        (void) L;
        cout << "ATT" << endl; 
        return 0;
    } };

    functions["pf"] = Function { 1, [](lua_State* L) { 
        (void) L;
        cout << "PF" << endl; 
        return 0;
    } };

}


void 
LPU::RegisterFunctions()
{
    for(auto const& kv: functions) {
        lua_pushcfunction(L, kv.second.f);
        lua_setglobal(L, kv.first.c_str());
    }
}


// vim: ts=4:sw=4:sts=4:expandtab
