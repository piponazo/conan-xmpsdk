#include <MD5.h>

#include <iostream>

int main() {
    std::cout << "test app\n";

    std::cout << "Using MD5 functions\n";
    unsigned char digest[16];
    MD5_CTX    context;
    MD5Init ( &context );
    MD5Final(digest, &context);

    std::cout << "Everything fine\n";
}
