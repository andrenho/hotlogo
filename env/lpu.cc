#include "lpu.h"

#include <iostream>

extern void yyerror(const char* s);

LPU::LPU()
{
    functions["att"] = Function { "att", 0, [](LPU&) { 
        cout << "ATT" << endl; 
        return LValue();
    } };

    functions["pf"] = Function { "pf", 1, [](LPU& lpu) { 
        double steps = lpu.GetParameter(1, LType::NUMBER).number;
        cout << "Turtle moves " << steps << endl; 
        return LValue();
    } };

    functions["pd"] = Function { "pd", 1, [](LPU& lpu) { 
        double steps = lpu.GetParameter(1, LType::NUMBER).number;
        cout << "Turtle rotates " << steps << endl; 
        return LValue();
    } };
}


void 
LPU::Push(LValue const& lv)
{
    stack.push_back(lv);

    size_t sz = stack.size();
    for(size_t i=1; i <= MAX_PARAMETERS; ++i) {
        if(sz > i) {
            LValue& p = stack[sz-i-1];
            if(p.type == LType::FUNCTION && p.func.parameters == i) {
                p.func.f(*this);
                stack.erase(begin(stack)+i-1, end(stack));
                return;
            }
        }
    }

    yyerror(("I don't know what to do with " + stack.back().ToString() + ".").c_str());
    stack.clear();
}


void 
LPU::PushIdentifier(string const& id)
{
    // check if function
    auto it = functions.find(id);
    if(it != end(functions)) {
        Function& f = it->second;   // TODO - move this block to push
        if(f.parameters == 0) {
            f.f(*this); 
        } else {
            stack.push_back(f);
        }
        return;
    }

    // not found
    yyerror(("I have not yet learned '" + id + "'").c_str());
    stack.clear();
}


LValue const&
LPU::GetParameter(size_t n, LType type)
{
    LValue const& lv = stack[stack.size()-n];
    if(lv.type != type) {
        yyerror("Invalid type");
        stack.clear();
    }
    return lv;
}


void 
LPU::DumpStack() const
{
    for(auto const& p: stack) {
        switch(p.type) {
            case LType::NOTHING:
                printf("()\n");
                break;
            case LType::NUMBER:
                printf("%f\n", p.number);
                break;
            case LType::FUNCTION:
                printf("*%s\n", p.func.internal_name.c_str());
                break;
            default:
                abort();
        }
    }
}


// vim: ts=4:sw=4:sts=4:expandtab
