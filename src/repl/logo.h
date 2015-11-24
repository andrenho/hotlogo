#ifndef LOGO_H
#define LOGO_H

#include <memory>
using namespace std;

class Logo {
public:
    Logo();

    void OpenList();
    void CloseList();
    void Add(string const& s);
    void Add(double d);

    void Eval() const;

private:
    unique_ptr<struct lua_State, void(*)(struct lua_State*)> L;


};

#endif

// vim: ts=4:sw=4:sts=4:expandtab
