#ifndef LPU_H
#define LPU_H

#include <cstring>

#include <map>
#include <functional>
#include <string>
#include <sstream>
#include <stack>
using namespace std;

enum class LType { NOTHING, NUMBER, FUNCTION };

struct Function {
    size_t parameters;
    int (*f)(struct lua_State* L);
};


//
// Logo processing unit
//
class LPU {
public:
    LPU();
    ~LPU();

    void Add(string const& s);
    void Push(double d);
    void PushIdentifier(string const& s);

    void RegisterFunction(string const& name);

    void PrintBuffer() const;

private:
    void InitializePrimitives();
    void RegisterFunctions();
    void ExecuteBuffer();

    stringstream buffer;

    stack<int> parameters_expected;

    map<string,Function> functions;

    static const int MAX_PARAMETERS = 9;

    struct lua_State* L;
};


#endif

// vim: ts=4:sw=4:sts=4:expandtab
