[ -d target/objects ] && find target/objects -name '*.o' -exec rm {} \;
[ -f target/aoc2022 ] && rm target/aoc2022

for i in $(find src -name '*.asm'); do
  rel=$(realpath --relative-to=src/ $i)
  mkdir -p $(dirname target/objects/$rel)
  nasm -g -F dwarf -felf64 $i -o target/objects/${rel%.asm}.o
done

ld $(find target/objects -name '*.o') -o target/aoc2022

target/aoc2022
