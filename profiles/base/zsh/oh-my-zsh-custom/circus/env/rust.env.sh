# ==============================================================================
# Rust Configuration
#
# Environment variables for Rust development.
# ==============================================================================

# --- Cargo & Rustup Directories -----------------------------------------------

# Cargo home directory (contains registry, git checkouts, binaries)
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

# Rustup home directory (contains toolchains, components)
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

# --- Cargo Settings -----------------------------------------------------------

# Use sparse registry protocol (faster updates since Rust 1.68)
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Enable incremental compilation for debug builds
export CARGO_INCREMENTAL=1

# --- Rust Compiler Settings ---------------------------------------------------

# Use lld linker if available (faster linking)
# Uncomment if you have lld installed: brew install llvm
# export RUSTFLAGS="-C link-arg=-fuse-ld=lld"

# Enable frame pointers for better profiling
# export RUSTFLAGS="-C force-frame-pointers=yes"

# --- sccache Configuration ----------------------------------------------------

# Use sccache for faster rebuilds (if installed)
# Install with: cargo install sccache
# if command -v sccache &>/dev/null; then
#     export RUSTC_WRAPPER=sccache
# fi

# --- Source Cargo Environment -------------------------------------------------

# Source cargo environment if it exists (adds ~/.cargo/bin to PATH)
[[ -f "$CARGO_HOME/env" ]] && source "$CARGO_HOME/env"
