#include "lpu.h"

#include <iostream>

extern void yyerror(const char* s);

LPU::LPU()
{
    functions["att"] = Function { "att", 0, [](LPU&) { 
        cout << "ATT" << endl; 
    } };

    functions["pf"] = Function { "pf", 1, [](LPU& lpu) { 
        cout << "Turtle moves" << endl; 
    } };

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
            buffer << ")";
            parameters_expected.pop();
            if(!parameters_expected.empty()) {
                --parameters_expected.top();
            }
        } else {
            break;
        }
    }
    buffer << " ";
}


void 
LPU::PushIdentifier(string const& s)
{
    auto it = functions.find(s);
    if(it != end(functions)) {
        Function& f = it->second;

        buffer << "(" << s;

        if(f.parameters > 0) {
            parameters_expected.push(f.parameters);
            buffer << " ";
        } else {
            buffer << ") ";
        }
        
        return;
    }

    yyerror(("Invalid function " + s).c_str());  // TODO
}


void 
LPU::PrintBuffer() const
{
    cout << buffer.str() << endl;
}


// vim: ts=4:sw=4:sts=4:expandtab
