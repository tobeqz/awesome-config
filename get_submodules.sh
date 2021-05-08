git submodule init &&
git submodule update &&
cd get_cpu_usage &&
cargo build --release &&
cd ../get_mem_usage &&
cargo build --release &&
cd ../spotify_manage &&
cargo build --release
