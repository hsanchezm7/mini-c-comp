# MiniC Compiler

Compiladores

Universidad de Murcia

Curso 2023-2024

## Requisitos
* g++
* Make
* flex
* bison

## Compilar

El código se puede compilar mediante el comando `make` usando el archivo Makefile.

## Ejemplos de uso

Compilar usando make:
```bash
  $ make
```

Una vez compilado, ejecutamos la orden `run` de Make:
```bash
  $ make run
```
La salida estará contenida en un archivo llamado `miniC.s`. 
La salida se puede ejecutar usando el simulador de MIPS [MARS](https://courses.missouristate.edu/KenVollmar/mars/download.htm).

También podemos limpiar los archivos generados en el proceso de compilación:
```bash
  $ make clean
```