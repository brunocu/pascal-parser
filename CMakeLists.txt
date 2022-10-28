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

LEX_FILE(src/lexer.lex)
SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/lexer.lex.c GENERATED)

add_executable(parser lexer.lex.c)
