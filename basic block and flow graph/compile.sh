filename=$threeaddr
flex $filename".l"
bison $filename".y" -d
g++ lex.yy.c $filename".tab.c" -lfl
