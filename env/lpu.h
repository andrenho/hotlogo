#ifndef LPU_H
#define LPU_H

#include <cstring>

#include <map>
#include <functional>
#include <string>
#include <vector>
using namespace std;

enum class LType { NOTHING, NUMBER, FUNCTION };

struct Function {
    string internal_name;
    size_t parameters;
    function<class LValue(class LPU&)> f;
};


struct LValue {
    LType type;
    union {
        double number;
        Function func;
    };

    LValue() : type(LType::NOTHING) {}
    LValue(double number) : type(LType::NUMBER), number(number) {}
    LValue(Function const& func) : type(LType::FUNCTION), func(func) {}

    string ToString() const {
        switch(type) {
            case LType::NOTHING: return "nothing";
            case LType::NUMBER: return to_string(number);
            case LType::FUNCTION: return func.internal_name;
        }
        abort();
    }

    // stuff stupidly required from C++ compiler
    ~LValue() {}
    LValue(LValue const& lv) { memcpy(this, &lv, sizeof(*this)); }  // simply copy object
    LValue& operator=(const LValue& n) { memcpy(this, &n, sizeof(*this)); return *this; }
};


//
// Logo processing unit
//
class LPU {
public:
    LPU();

    void Push(LValue const& lv);
    void PushIdentifier(string const& id);

    LValue const& GetParameter(size_t n, LType type);

    void DumpStack() const;

private:
    map<string,Function> functions;
    vector<LValue> stack;

    static const int MAX_PARAMETERS = 9;
};


#endif

// vim: ts=4:sw=4:sts=4:expandtab
