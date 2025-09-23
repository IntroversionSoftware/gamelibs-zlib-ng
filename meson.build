project('zlib', 'c', version: '1.2.11')

compiler = meson.get_compiler('c')
link_deps = [
]

c_flags = [
    '-DZLIB_COMPAT',
    '-D_GNU_SOURCE',
]

incdirs = ['.']

sources = [
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

if host_machine.cpu_family() == 'x86' or host_machine.cpu_family() == 'x86_64'
    c_flags += [
        #'-DX86_AVX2',
        #'-DX86_AVX512',
        #'-DX86_AVX512VNNI',
        '-DX86_FEATURES',
        #'-DX86_HAVE_XSAVE_INTRIN',
        #'-DX86_PCLMULQDQ_CRC',
        '-DX86_SSE2',
        '-DX86_SSE41',
        '-DX86_SSE42',
        #'-DX86_SSSE3',
        #'-DX86_VPCLMULQDQ_CRC',
    ]
    sources += [
        'arch/x86/adler32_avx2.c',
        'arch/x86/adler32_avx512.c',
        'arch/x86/adler32_avx512_vnni.c',
        'arch/x86/adler32_sse42.c',
        'arch/x86/adler32_ssse3.c',
        'arch/x86/chorba_sse2.c',
        'arch/x86/chorba_sse41.c',
        'arch/x86/chunkset_avx2.c',
        'arch/x86/chunkset_avx512.c',
        'arch/x86/chunkset_sse2.c',
        'arch/x86/chunkset_ssse3.c',
        'arch/x86/compare256_avx2.c',
        'arch/x86/compare256_avx512.c',
        'arch/x86/compare256_sse2.c',
        'arch/x86/crc32_pclmulqdq.c',
        'arch/x86/crc32_vpclmulqdq.c',
        'arch/x86/slide_hash_avx2.c',
        'arch/x86/slide_hash_sse2.c',
        'arch/x86/x86_features.c',
    ]
endif
if host_machine.cpu_family() == 'aarch64'
    c_flags += [
        '-DARM_FEATURES',
        '-DARM_CRC32',
        '-DARM_NEON',
        '-DARM_NEON_HASLD4',
    ]
    sources += [
        'arch/arm/adler32_neon.c',
        'arch/arm/arm_features.c',
        'arch/arm/chunkset_neon.c',
        'arch/arm/compare256_neon.c',
        'arch/arm/crc32_armv8.c',
        'arch/arm/slide_hash_armv6.c',
        'arch/arm/slide_hash_neon.c',
    ]
endif

incdirs = include_directories(incdirs)

lib = static_library(
    'z',
    sources,
    c_args: c_flags,
    include_directories: incdirs,
    dependencies: link_deps,
)

zlib_dep = declare_dependency(
    include_directories: incdirs,
    dependencies: link_deps,
    link_with: lib,
    version: meson.project_version()
)

meson.override_dependency('zlib', zlib_dep)

# vim: set ts=4 sts=4 sw=4 et:
