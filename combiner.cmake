# Function: combine_static_libraries
# Combines multiple static libraries into a single static library.
#
# Arguments:
#   base_lib:  The name of the base library target. Dependencies of this library
#              will be recursively added to the final static library.
#   target_lib_name:  The name of the target static library to be created.
function(combine_static_libraries base_lib target_lib_name)
  list(APPEND static_libs ${base_lib})

  # Inner function: get_lib_deps_recursively
  # Recursively retrieves all dependent static libraries of a given target.
  #
  # Arguments:
  #   target:  The name of the target to check for dependencies.
  function(get_lib_deps_recursively target)
    set(link_libs LINK_LIBRARIES)
    get_target_property(target_type ${target} TYPE)
    if (${target_type} STREQUAL "INTERFACE_LIBRARY")
      set(link_libs INTERFACE_LINK_LIBRARIES)
    endif()
    get_target_property(public_dependencies ${target} ${link_libs})
    foreach(dependency IN LISTS public_dependencies)
      if(TARGET ${dependency})
        get_target_property(alias ${dependency} ALIASED_TARGET)
        if (TARGET ${alias})
          set(dependency ${alias})
        endif()
        get_target_property(_type ${dependency} TYPE)
        if (${_type} STREQUAL "STATIC_LIBRARY")
          list(APPEND static_libs ${dependency})
        endif()

        get_property(library_already_added
          GLOBAL PROPERTY _${base_lib}_static_bundle_${dependency})
        if (NOT library_already_added)
          set_property(GLOBAL PROPERTY _${base_lib}_static_bundle_${dependency} ON)
          get_lib_deps_recursively(${dependency})
        endif()
      endif()
    endforeach()
    set(static_libs ${static_libs} PARENT_SCOPE)
  endfunction()

  get_lib_deps_recursively(${base_lib})

  list(REMOVE_DUPLICATES static_libs)

  set(target_lib_path
    ${CMAKE_BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${target_lib_name}${CMAKE_STATIC_LIBRARY_SUFFIX})

  if (CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|GNU)$")
    file(WRITE ${CMAKE_BINARY_DIR}/${target_lib_name}.ar.in
      "CREATE ${target_lib_path}\n" )

    foreach(tgt IN LISTS static_libs)
      file(APPEND ${CMAKE_BINARY_DIR}/${target_lib_name}.ar.in
        "ADDLIB $<TARGET_FILE:${tgt}>\n")
    endforeach()

    file(APPEND ${CMAKE_BINARY_DIR}/${target_lib_name}.ar.in "SAVE\n")
    file(APPEND ${CMAKE_BINARY_DIR}/${target_lib_name}.ar.in "END\n")

    file(GENERATE
      OUTPUT ${CMAKE_BINARY_DIR}/${target_lib_name}.ar
      INPUT ${CMAKE_BINARY_DIR}/${target_lib_name}.ar.in)

    set(ar_tool ${CMAKE_AR})
    if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)
      set(ar_tool ${CMAKE_CXX_COMPILER_AR})
    endif()

    add_custom_command(
      COMMAND ${ar_tool} -M < ${CMAKE_BINARY_DIR}/${target_lib_name}.ar
      OUTPUT ${target_lib_path}
      COMMENT "Packing ${target_lib_name}"
      VERBATIM)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    find_program(ar_tool libtool)

    foreach(tgt IN LISTS static_libs)
      list(APPEND static_lib_paths $<TARGET_FILE:${tgt}>)
    endforeach()

    add_custom_command(
      COMMAND ${ar_tool} -static -o ${target_lib_path} ${static_lib_paths}
      OUTPUT ${target_lib_path}
      COMMENT "Packing ${target_lib_name}"
      VERBATIM)
  elseif(MSVC)
    find_program(ar_tool lib)

    foreach(tgt IN LISTS static_libs)
      list(APPEND static_lib_paths $<TARGET_FILE:${tgt}>)
    endforeach()

    add_custom_command(
      COMMAND ${ar_tool} /NOLOGO /OUT:${target_lib_path} ${static_lib_paths}
      OUTPUT ${target_lib_path}
      COMMENT "Packing ${target_lib_name}"
      VERBATIM)
  else()
    message(FATAL_ERROR "Unknown compiler!")
  endif()

  set(custom_target_name combine_universal_lib_for_${base_lib})
  add_custom_target(${custom_target_name} ALL DEPENDS ${target_lib_path})
  add_dependencies(${custom_target_name} ${base_lib})

  add_library(${target_lib_name} STATIC IMPORTED GLOBAL)
  set_target_properties(${target_lib_name}
    PROPERTIES
      IMPORTED_LOCATION ${target_lib_path}
      INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${base_lib},INTERFACE_INCLUDE_DIRECTORIES>)
  add_dependencies(${target_lib_name} ${custom_target_name})

endfunction()