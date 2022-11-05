# Building

## CMake

### Configure

```bash
cmake -S ./ -B ./build/
```

### Building

```bash
cmake --build ./build/ --target all --
```

## Manual

```bash
bison -d src/parser.y
flex src/lexer.lex
gcc parser.tab.c lex.yy.c -o parser
```

# Running

```bash
./parser <input-file>
```
