=begin

    This program looks for a representation of F_p^n by starting with
 1..p-1 as the candidates for the leading coefficient of a polynomial
 P(x) in the ring F_p[x] of polynomials over F_p, then using the digits
 of p^(n-1) - 1 through 0 in base p for the rest of the coefficients,
 and attempting to check if each such enumerated polynomial is irreducible mod p.
 This gives a representation by an irreducible polynomial with "big" coefficients.
 Arithmetic is then defined naturally.

    Below is a log in the Ruby console of some example calculations with the
 polynomial x^2 + x + 1 realized as an element of the finite field
 F_11^3 represented by F_11[x] / (x^3 + 9x^2 + 10x + 10)

 irb(main):130:0> ff = FiniteField.new(11, 3)
  Constructing irreducible polynomial...
  Found Polynomial of degree 3 mod 11: x^3 + 9x^2 + 10x + 10...
  You can now play with this field as it is realized inside F_11[X] / (x^3 + 9x^2 + 10x + 10)
 => Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):131:0> ffe = FiniteFieldElement.new(ff, 1,1,1)
 => Polynomial of degree 2 mod 11: x^2 + x + 1 embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):132:0> ffe + 1
 => Polynomial of degree 2 mod 11: x^2 + x + 2 embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):133:0> ffe + 10
 => Polynomial of degree 2 mod 11: x^2 + x embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):134:0> ffe * ffe
 => Polynomial of degree 2 mod 11: x^2 + 7x + 5 embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):135:0> -ffe
 => Polynomial of degree 2 mod 11: 10x^2 + 10x + 10 embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)
 irb(main):136:0> ffe - ffe
 => Polynomial of degree 0 mod 11: 0 embedded in Finite Field of degree 1331 = 11^3 represented by F_1331[x] / (x^3 + 9x^2 + 10x + 10)

=end

class FiniteFieldPolynomial
  attr_accessor :prime, :coefficients, :degree

  def initialize(prime, *_coefficients)
    @prime = prime
    @coefficients = _coefficients
    self.simplify!
  end

  def is_irreducible
    for x in 0..(@prime - 1)
      return false if self.value(x) == 0
    end
    return true
  end

  def value(x)
    val = 0
    @coefficients.each_with_index do |c, i|
      deg = @degree - i
      val += c * (x ** deg) % @prime
    end
    val % @prime
  end

  def simplify!
    @coefficients.map! { |coeff| coeff % @prime }
    @coefficients.shift while @coefficients.length > 1 && @coefficients[0] == 0
    @degree = @coefficients.length - 1
    self
  end

  def to_s(raw = false)
    (!raw ? "Polynomial of degree #{degree} mod #{prime}: " : '') +
    @coefficients.each_with_index.map do |c, i|
      deg = @degree - i
      monomial = case deg
                 when 0 then ""
                 when 1 then "x"
                 else "x^#{deg}"
                 end

      c == 0 && @coefficients.length > 1 ? nil :
        "#{c == 1 && deg > 0 ? '' : c}#{monomial}"
    end.compact.join(' + ')
  end

  def *(y)
    if y.is_a? Integer
      coeffs = @coefficients.map { |c| 0 }
      coeffs[coeffs.length - 1] = y
      y = self.class.new(@prime, y)
    elsif !y.is_a? self.class
      raise TypeError.new("Can only multiply by polynomials")
    elsif self.prime != y.prime
      raise TypeError.new("Polynomials must come from same prime field")
    end
    
    if (tmp = y.coefficients.select { |c| c != 0 }.count) <= 1
      return self.class.new(prime, 0) if tmp == 0
      non_zero_index = 0
      non_zero_index += 1 while y.coefficients[non_zero_index] == 0
      multiplied_coeffs = self.coefficients.map { |c| c * y.coefficients[non_zero_index] } 
      new_coefficients = multiplied_coeffs + [0] * (y.degree - non_zero_index)
      return self.class.new(prime, *new_coefficients)
    else
      poly = self.class.new(prime, 0)
      y.coefficients.each_with_index do |coeff, index|
        coeffs = [0] * (y.degree + 1)
        coeffs[index] = coeff
        poly = poly + self * self.class.new(prime, *coeffs)
      end
      poly.simplify!
      return poly
    end
  end

  def +(y)
    if y.is_a? Integer
      coeffs = @coefficients.map { |c| 0 }
      coeffs[coeffs.length - 1] = y
      y = self.class.new(@prime, y)
    elsif !y.is_a? self.class
    return self
      raise TypeError.new("Can only add polynomials")
    elsif self.prime != y.prime
      raise TypeError.new("Polynomials must come from same prime field")
    end
    deg = [self.degree, y.degree].max
    coefficients1 = ([0]*(deg - self.degree)).concat self.coefficients
    coefficients2 = ([0]*(deg - y.degree)).concat y.coefficients
    coefficients = coefficients1.each_with_index.map { |c, i|
      c + coefficients2[i] }
    self.class.new(prime, *coefficients)
  end

  def -@
    self.class.new self.prime, *@coefficients.map { |coeff| -coeff }
  end

  def -(y)
    self + (-y)
  end

  def ==(y)
    (self - y).coefficients == [0]
  end

end

class FiniteField
  attr_accessor :prime, :exponent, :degree, :polynomial

  def initialize(p, n)
    @prime = p
    @exponent = n
    @degree = p**n
    puts "Constructing irreducible polynomial..."
    @polynomial = construct_irreducible_polynomial
    unless @polynomial
      raise Exception.new("No irreducible polynomial of degree #{n} mod #{p} found!")
    end
    puts "Found #{@polynomial}..."
    puts <<-end_msg
You can now play with this field as it is realized inside F_#{p}[X] / (#{@polynomial.to_s(true)})
    end_msg
  end

  def self.inverse_in_prime_field(n, p)
    for x in (1..(p-1)).to_a
      return x if (x * n % p) == 1
    end
    return nil # Should never happen
  end

  def to_s
    deg = exponent > 1 ? "#{degree} = #{prime}^#{exponent}" : degree
    "Finite Field of degree #{deg} represented by F_#{degree}[x] / (" +
      "#{polynomial.to_s(true)})"
  end

  protected

  def construct_irreducible_polynomial
    # Super naive way of finding irreducible polynomials
    # of degree n mod p
    for a_n in 1..(@prime - 1)
      coeffs_list = (0..(@prime ** @exponent - 1)).to_a.reverse
      for coeff_encoding in coeffs_list
        coeffs = [a_n]
        while coeff_encoding != 0
          coeffs += [coeff_encoding % @prime]
          coeff_encoding /= @prime
        end
        coeffs += [0] while coeffs.length <= @exponent
        poly = FiniteFieldPolynomial.new(@prime, *coeffs)
        return poly if poly.is_irreducible
      end
    end
    return nil
  end

end

class FiniteFieldElement < FiniteFieldPolynomial
  attr_accessor :finite_field, :coefficients

  def initialize(_finite_field, *_coefficients)
    if _coefficients[0].is_a? FiniteFieldPolynomial
      _coefficients = _coefficients[0].coefficients
    end
    @finite_field = _finite_field
    @coefficients = _coefficients
    super finite_field.prime, *coefficients
  end

  def simplify!
    super

    if self.degree >= finite_field.exponent
      coeffs = (-finite_field.polynomial).coefficients[1..-1]
      @inverse_of_leading_coefficient ||=
        FiniteField.inverse_in_prime_field(
          finite_field.polynomial.coefficients[0], finite_field.prime)
      coeffs = coeffs.map { |c| 
        c * @inverse_of_leading_coefficient % finite_field.prime }
      # coeffs now holds the reduced value of x^n
      deg_diff = (self.degree - finite_field.exponent)
      new_coeffs = [0] * (deg_diff + 1) +
                    self.coefficients[(-self.finite_field.exponent)..-1]
      for i in 0..deg_diff
        # Replace x^n with coeffs
        extra_coeffs = coeffs + [0] * (deg_diff - i)
        # Pad out zeroes on the left
        extra_coeffs = [0] * (self.degree - (extra_coeffs.length - 1)) + extra_coeffs
        unless new_coeffs.length == extra_coeffs.length
          raise "Coefficient lengths do not match"
        end
        new_coeffs = new_coeffs.each_with_index.map do |coeff, index|
          coeff + extra_coeffs[index] * self.coefficients[i]
        end
      end
      self.coefficients = new_coeffs
      return self.simplify!
    end
    self
  end

  def *(y)
    y = sanity_check y
    self.class.new(self.finite_field, self.to_ffp * y.to_ffp)
  end

  def +(y)
    y = sanity_check y 
    self.class.new(self.finite_field, self.to_ffp + y.to_ffp)
  end

  def -@
    self.class.new(self.finite_field, -self.to_ffp)
  end

  def -(y)
    self + (-y)
  end

  def to_ffp
    FiniteFieldPolynomial.new(self.finite_field.prime, *self.coefficients)
  end

  def to_s
    super + " embedded in #{finite_field}"
  end

  protected

  def sanity_check(y)
    y = integer_wrap(y)
    unless y.is_a? self.class
      raise TypeError.new("Can only multiply finite field elements by themselves")
    end
    unless self.finite_field.degree == y.finite_field.degree
      raise TypeError.new("Can only multiply finite field elements by themselves!")
    end
    y
  end

  def integer_wrap(y)
    if y.is_a? Integer
      self.class.new(self.finite_field, y)
    else
      y
    end
  end
  
end

class Fixnum
  unless method_defined?(:'*_old__FiniteFieldPolynomialHack') &&
         method_defined?(:'+_old__FiniteFieldPolynomialHack') &&
         method_defined?(:'-_old__FiniteFieldPolynomialHack')

    alias_method :'*_old__FiniteFieldPolynomialHack', :*
    alias_method :'+_old__FiniteFieldPolynomialHack', :+
    alias_method :'-_old__FiniteFieldPolynomialHack', :-

    def -(y)
      if y.is_a?(FiniteFieldPolynomial)
        return FiniteFieldPolynomial.new(y.prime, [-self]) - y
      elsif y.is_a?(FiniteFieldElement)
        return FiniteFieldElement.new(y.finite_field, [-self]) - y
      end
      return self.send :'-_old__FiniteFieldPolynomialHack', y
    end

    def +(y)
      if y.is_a?(FiniteFieldPolynomial) || y.is_a?(FiniteFieldElement)
        return y + self
      end
      return self.send :'+_old__FiniteFieldPolynomialHack', y
    end

    def *(y)
      if y.is_a?(FiniteFieldPolynomial) || y.is_a?(FiniteFieldElement)
        return y * self
      end
      return self.send :'*_old__FiniteFieldPolynomialHack', y
    end
  end
end
