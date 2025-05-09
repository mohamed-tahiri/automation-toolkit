# scripts/lib/log.sh
INFO()    { echo -e "\e[34m[INFO]\e[0m $1"; }
SUCCESS() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
ERROR()   { echo -e "\e[31m[ERROR]\e[0m $1" >&2; }

