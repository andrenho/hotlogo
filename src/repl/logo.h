#ifndef LOGO_H
#define LOGO_H

#include <string>
using namespace std;

class Logo {
public:
    Logo();
    ~Logo();

    void OpenList();
    void CloseList();
    void Add(string const& s);
    void Add(double d);
    
    void AddCommand(string const& s);

    void Eval() const;
    void Print() const;
    void Error(string const& s);

private:
    struct lua_State* L = nullptr;

    string StackDump() const;

    int level = 0;

    int parameters_left = 0;
};

#endif

// vim: ts=4:sw=4:sts=4:expandtab
