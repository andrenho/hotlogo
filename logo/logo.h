#ifndef LOGO_H
#define LOGO_H

#include <string>
#include <vector>
using namespace std;

class Value {
    public:
        enum Type {
            NUMBER,
            FUNCTION,
            LIST,
        };

        // TODO - validate types
        Value(Type type, double n) { impl_.n = n; }
        Value(Type type, string const& s) { impl_.s = s; }
        Value(Type type, vector<Value> const& v) { impl_.v = v; }

        ~Value() {}

        Value& operator=(const Value& v) {
            impl_ = v.impl_;
            return *this;
        }

        Value(const Value& v) {
            impl_ = v.impl_;
        }

    private:
        union Impl {
            double n;
            string s;
            vector<Value> v;

            Impl() {
                new(&s) string;
            }
            ~Impl() {}
            Impl& operator=(const Impl& v) {
                n = v.n; s = v.s; this->v = v.v;
                return *this;
            }
        } impl_;

        Type type;
};

#endif

// vim: ts=4:sw=4:sts=4:expandtab
