#include "lpu.h"

#include <cassert>
extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>
}

#include <iostream>

extern void yyerror(const char* s);

LPU::LPU()
    : L(luaL_newstate())
{
    InitializePrimitives();
    RegisterFunctions();
}


LPU::~LPU()
{
    lua_close(L);
}


void 
LPU::Push(double d)
{
    if(parameters_expected.empty()) {
        yyerror(("I don't know what to do with " + to_string(d)).c_str());  // TODO
    }

    buffer << d;
    --parameters_expected.top();

    while(!parameters_expected.empty()) {
        if(parameters_expected.top() == 0) {
            buffer << ") ";
            parameters_expected.pop();
            if(!parameters_expected.empty()) {
                --parameters_expected.top();
            }
        } else {
            buffer << ",";
            break;
        }
    }

    ExecuteBuffer();
}


void 
LPU::PushIdentifier(string const& s)
{
    auto it = functions.find(s);
    if(it != end(functions)) {
        Function& f = it->second;

        buffer << s << "(";

        if(f.parameters > 0) {
            parameters_expected.push(f.parameters);
        } else {
            buffer << ") ";
        }
        
        ExecuteBuffer();
        return;
    }

    yyerror(("Invalid function " + s).c_str());  // TODO
}


void 
LPU::Add(string const& s) 
{ 
    buffer << s;
    ExecuteBuffer();
}


void 
LPU::ExecuteBuffer()
{
    int r = luaL_loadstring(L, buffer.str().c_str());
    if(r == LUA_ERRSYNTAX) {
        return;  // input is incomplete
    }
    assert(r == LUA_OK);
    r = lua_pcall(L, 0, LUA_MULTRET, 0);  // TODO - replace last parameter for message handler
    assert(r == LUA_OK);
    buffer.str("");  // clear buffer
}


void 
LPU::PrintBuffer() const
{
    cout << buffer.str() << endl;
}


// vim: ts=4:sw=4:sts=4:expandtab
