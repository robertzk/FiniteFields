Finite Field Arithmetic in Ruby
============

Arithmetic over finite fields in Ruby

Here's an example multiplication table generator: http://therobert.org/finite_fields

Examples
========

    irb(main):104:0> ff = FiniteField.new(5, 2)
    Constructing irreducible polynomial...
    Found Polynomial of degree 2 mod 5: x^2 + 3x + 4...
    You can now play with this field as it is realized inside F_5[X] / (x^2 + 3x + 4)
    => Finite Field of degree 25 = 5^2 represented by F_25[x] / (x^2 + 3x + 4)
    irb(main):105:0> x = FiniteFieldElement.new(ff, 1, 0)
    => x
    irb(main):106:0> x + 1
    => x + 1
    irb(main):107:0> x + 5
    => x
    irb(main):108:0> 1/x
    => x + 3
    irb(main):109:0> x**2
    => 2x + 1
    irb(main):110:0> x**3
    => 2
    irb(main):111:0> x**-3
    => 3
    irb(main):112:0> x**2 / (x**3 + 1)
    => 4x + 2
    irb(main):113:0> 1 / x
    => x + 3
    irb(main):114:0> 5 - x/(x+1)
    => 2x + 3

