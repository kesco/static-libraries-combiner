# static-libraries-combiner

A cmake function to bundle multiple static libraries into a single static library.

## Usage

```cmake
# include the combiner cmake file
include(${CMAKE_SOURCE_DIR}/../combiner.cmake)

# use the function to combine the libraries
combine_static_libraries(${TARGET_LIB} ${TARGET_LIB}_Bundle)
```
