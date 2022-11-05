cmake_minimum_required(VERSION 3.0.0)
project(parser VERSION 0.1.0)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED true)

find_program(LEX_EXE
    flex
)
if(LEX_EXE STREQUAL "LEX_EXE-NOTFOUND")
    message(FATAL_ERROR "flex executable not found")
endif(LEX_EXE STREQUAL "LEX_EXE-NOTFOUND")

find_program(YACC_EXE
    bison
)
if(YACC_EXE STREQUAL "YACC_EXE-NOTFOUND")
    message(FATAL_ERROR "bison executable not found")
endif(YACC_EXE STREQUAL "YACC_EXE-NOTFOUND")

# lex source file macro
MACRO(LEX_FILE _filepath)
    GET_FILENAME_COMPONENT(_filename ${_filepath} NAME)
    ADD_CUSTOM_COMMAND(
        OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${_filename}.c
        COMMAND ${LEX_EXE}
                -o${_filename}.c
                ${CMAKE_CURRENT_SOURCE_DIR}/${_filepath}
        DEPENDS ${_filepath} )
ENDMACRO(LEX_FILE)

# yacc source file macro
MACRO(YACC_FILE _filepath)
    GET_FILENAME_COMPONENT(_basename ${_filepath} NAME_WE)
    ADD_CUSTOM_COMMAND(
        OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.tab.c
                ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.tab.h
        COMMAND ${YACC_EXE} -d
                ${CMAKE_CURRENT_SOURCE_DIR}/${_filepath}
        DEPENDS ${_filepath}
    )
ENDMACRO(YACC_FILE)

YACC_FILE(src/parser.y)
SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/parser.tab.c GENERATED)
LEX_FILE(src/lexer.lex)
SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/lexer.lex.c GENERATED)

add_executable(parser
    parser.tab.c
    lexer.lex.c
)
