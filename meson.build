project('zlib', 'c', version: '1.2.11')

compiler = meson.get_compiler('c')
link_deps = [
]

c_flags = [
    '-DZLIB_COMPAT',
    '-D_GNU_SOURCE',
]

incdirs = ['.']

# Generic (non-architecture-specific) sources
generic_sources = [
    'arch/generic/adler32_c.c',
    'arch/generic/adler32_fold_c.c',
    'arch/generic/chunkset_c.c',
    'arch/generic/compare256_c.c',
    'arch/generic/crc32_braid_c.c',
    'arch/generic/crc32_c.c',
    'arch/generic/crc32_chorba_c.c',
    'arch/generic/crc32_fold_c.c',
    'arch/generic/slide_hash_c.c',
    'adler32.c',
    'compress.c',
    'cpu_features.c',
    'crc32.c',
    'crc32_braid_comb.c',
    'deflate.c',
    'deflate_fast.c',
    'deflate_huff.c',
    'deflate_medium.c',
    'deflate_quick.c',
    'deflate_rle.c',
    'deflate_slow.c',
    'deflate_stored.c',
    'functable.c',
    'gzlib.c',
    'gzwrite.c',
    'infback.c',
    'inflate.c',
    'inftrees.c',
    'insert_string.c',
    'insert_string_roll.c',
    'trees.c',
    'uncompr.c',
    'zutil.c',
]

if compiler.get_id() == 'gcc' or compiler.get_id() == 'clang' or compiler.get_id() == 'clang-cl'
    c_flags += [
        '-DHAVE_ATTRIBUTE_ALIGNED',
        '-DHAVE_BUILTIN_ASSUME_ALIGNED',
        '-DHAVE_BUILTIN_CTZ',
        '-DHAVE_BUILTIN_CTZLL',
        '-DHAVE_CPUID_GNU',
    ]
endif
if compiler.get_id() == 'msvc'
    c_flags += [
        '-DHAVE_CPUID_MS',
    ]
endif

incdirs = include_directories(incdirs)

arch_libs = []

if host_machine.cpu_family() == 'x86' or host_machine.cpu_family() == 'x86_64'
    c_flags += [
        '-DX86_AVX2',
        '-DX86_AVX512',
        '-DX86_AVX512VNNI',
        '-DX86_FEATURES',
        '-DX86_HAVE_XSAVE_INTRIN',
        '-DX86_PCLMULQDQ_CRC',
        '-DX86_SSE2',
        '-DX86_SSE41',
        '-DX86_SSE42',
        '-DX86_SSSE3',
        '-DX86_VPCLMULQDQ_CRC',
    ]

    x86_features_lib = static_library(
        'z_x86_features',
        ['arch/x86/x86_features.c'],
        c_args: c_flags + ['-fno-lto', '-mxsave'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [x86_features_lib]

    # SSE2 files
    sse2_lib = static_library(
        'z_sse2',
        [
            'arch/x86/chorba_sse2.c',
            'arch/x86/chunkset_sse2.c',
            'arch/x86/compare256_sse2.c',
            'arch/x86/slide_hash_sse2.c',
        ],
        c_args: c_flags + ['-fno-lto', '-msse2'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [sse2_lib]

    # SSSE3 files
    ssse3_lib = static_library(
        'z_ssse3',
        [
            'arch/x86/adler32_ssse3.c',
            'arch/x86/chunkset_ssse3.c',
        ],
        c_args: c_flags + ['-fno-lto', '-mssse3'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [ssse3_lib]

    # SSE4.1 files
    sse41_lib = static_library(
        'z_sse41',
        ['arch/x86/chorba_sse41.c'],
        c_args: c_flags + ['-fno-lto', '-msse4.1'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [sse41_lib]

    # SSE4.2 files
    sse42_lib = static_library(
        'z_sse42',
        ['arch/x86/adler32_sse42.c'],
        c_args: c_flags + ['-fno-lto', '-msse4.2'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [sse42_lib]

    # AVX2 files
    avx2_lib = static_library(
        'z_avx2',
        [
            'arch/x86/adler32_avx2.c',
            'arch/x86/chunkset_avx2.c',
            'arch/x86/compare256_avx2.c',
            'arch/x86/slide_hash_avx2.c',
        ],
        c_args: c_flags + ['-fno-lto', '-mavx2'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [avx2_lib]

    # AVX512 files (base set)
    avx512_lib = static_library(
        'z_avx512',
        [
            'arch/x86/adler32_avx512.c',
            'arch/x86/compare256_avx512.c',
        ],
        c_args: c_flags + ['-fno-lto', '-mavx512f', '-mavx512bw', '-mavx512vl'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [avx512_lib]

    # AVX512 + BMI2 files
    avx512_bmi2_lib = static_library(
        'z_avx512_bmi2',
        ['arch/x86/chunkset_avx512.c'],
        c_args: c_flags + ['-fno-lto', '-mavx512f', '-mavx512bw', '-mavx512vl', '-mbmi2'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [avx512_bmi2_lib]

    # AVX512 + VNNI files
    avx512_vnni_lib = static_library(
        'z_avx512_vnni',
        ['arch/x86/adler32_avx512_vnni.c'],
        c_args: c_flags + ['-fno-lto', '-mavx512f', '-mavx512bw', '-mavx512vl', '-mavx512vnni'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [avx512_vnni_lib]

    # PCLMUL files
    pclmul_lib = static_library(
        'z_pclmul',
        ['arch/x86/crc32_pclmulqdq.c'],
        c_args: c_flags + ['-fno-lto', '-mssse3', '-mpclmul'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [pclmul_lib]

    # VPCLMULQDQ files
    vpclmul_lib = static_library(
        'z_vpclmul',
        ['arch/x86/crc32_vpclmulqdq.c'],
        c_args: c_flags + ['-fno-lto', '-mpclmul', '-mavx512f', '-mvpclmulqdq'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [vpclmul_lib]
endif

if host_machine.cpu_family() == 'aarch64'
    c_flags += [
        '-DARM_FEATURES',
        '-DARM_CRC32',
        '-DARM_NEON',
        '-DARM_NEON_HASLD4',
    ]

    # ARM architecture-specific files - just need -fno-lto
    arm_lib = static_library(
        'z_arm',
        [
            'arch/arm/adler32_neon.c',
            'arch/arm/arm_features.c',
            'arch/arm/chunkset_neon.c',
            'arch/arm/compare256_neon.c',
            'arch/arm/crc32_armv8.c',
            'arch/arm/slide_hash_armv6.c',
            'arch/arm/slide_hash_neon.c',
        ],
        c_args: c_flags + ['-fno-lto'],
        include_directories: incdirs,
        dependencies: link_deps,
    )
    arch_libs += [arm_lib]
endif

# Build the main generic library
main_lib = static_library(
    'z_main',
    generic_sources,
    c_args: c_flags,
    include_directories: incdirs,
    dependencies: link_deps,
)

# Combine all libraries into the final static library
all_libs = [main_lib] + arch_libs

lib = static_library(
    'z',
    # No sources here - we're just combining the other libraries
    link_whole: all_libs,
    include_directories: incdirs,
)

zlib_dep = declare_dependency(
    include_directories: incdirs,
    dependencies: link_deps,
    link_with: lib,
    version: meson.project_version()
)

meson.override_dependency('zlib', zlib_dep)

# vim: set ts=4 sts=4 sw=4 et:
