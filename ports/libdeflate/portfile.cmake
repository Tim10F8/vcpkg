vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ebiggers/libdeflate
    REF "v${VERSION}"
    SHA512 c20a772aeeac593c34e8a68be80b23cb116699141de269d94df072636b6c90572f541b3344d830325cf45b03e7a1303e0274d79ce96c360fd421d4eb05ae1f92
    HEAD_REF master
    PATCHES
        remove_wrong_c_flags_modification.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        compression   LIBDEFLATE_COMPRESSION_SUPPORT
        decompression LIBDEFLATE_DECOMPRESSION_SUPPORT
        gzip          LIBDEFLATE_GZIP_SUPPORT
        zlib          LIBDEFLATE_ZLIB_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBDEFLATE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBDEFLATE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBDEFLATE_BUILD_SHARED_LIB=${LIBDEFLATE_BUILD_SHARED}
        -DLIBDEFLATE_BUILD_STATIC_LIB=${LIBDEFLATE_BUILD_STATIC}
        -DLIBDEFLATE_BUILD_GZIP=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdeflate")
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libdeflate.h" "defined(LIBDEFLATE_DLL)" "1")
    elseif(NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdeflate.pc" " -ldeflate" " -ldeflatestatic")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdeflate.pc" " -ldeflate" " -ldeflatestatic")
        endif()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
