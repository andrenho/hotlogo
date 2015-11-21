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
    string internal_name;
    size_t parameters;
    function<void(class LPU&)> f;
};


//
// Logo processing unit
//
class LPU {
public:
    LPU();

    void Add(string const& s) { buffer << s; }
    void Push(double d);
    void PushIdentifier(string const& s);

    void PrintBuffer() const;

private:
    stringstream buffer;

    stack<int> parameters_expected;

    map<string,Function> functions;

    static const int MAX_PARAMETERS = 9;
};


#endif

// vim: ts=4:sw=4:sts=4:expandtab
