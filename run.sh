for i in *.asm; do
  nasm -g -F dwarf -felf64 $i -o target/objects/${i%.asm}.o
done

ld target/objects/*.o -o target/aoc2022

target/aoc2022
