# Relic Toolkit builder for Julia

Builds [Relic Toolkit](https://github.com/blenessy/relic) for the [RelicToolkit.jl](https://github.com/blenessy/RelicToolkit.jl) project.

# Built Libs

All libs link to GMP because, mostly because that is already conveniently provided by Julia.

| Name                                | PBC       | ARITH         | OPSYS                          | ARCH  |
| ----------------------------------- | --------- | ------------- | ------------------------------ | ----- |
| `librelic_gmp_pbc_bls381`           | BLS381    | `gmp`         | `MACOSX,LINUX`                 | `X64` |
| `librelic_gmp_pbc_bn254`            | BN256     | `gmp`         | `MACOSX,LINUX`                 | `X64` |

# Status

**Under heavy development - don't use this yet.**
