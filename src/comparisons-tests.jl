### comparisons-tests.jl
#
# Copyright (C) 2016, 2017 Mosè Giordano.
#
# Maintainer: Mosè Giordano <mose AT gnu DOT org>
# Keywords: uncertainty, error propagation, physics
#
# This file is a part of Measurements.jl.
#
# License is MIT "Expat".
#
### Commentary:
#
# This file contains definition of comparison and test functions that support
# Measurement objects.
#
### Code:

import Base: ==, isless, <, <=, isnan, isfinite, isinf, isinteger, iszero

# Two measurements are equal if they have same value and same uncertainty.
# NB: Two measurements are egal (===) if they are exactly the same thing,
# i.e. if they share all the same fields, including the (hopefully) unique tag.
# If you need stricter equality use "===" instead of "==".
==(a::Measurement, b::Measurement) = (a.val==b.val && a.err==b.err)

# Comparison with Real: they are equal if the value of Measurement is equal to
# the number.  If you want to treat the Real like a measurement convert it with
# `Measurement'.
==(a::Measurement{<:AbstractFloat}, b::Irrational) = false
==(a::Measurement, b::Rational) = a.val==b
==(a::Measurement, b::Real) = a.val==b
==(a::Irrational, b::Measurement{<:AbstractFloat}) = false
==(a::Rational, b::Measurement) = a==b.val
==(a::Real, b::Measurement) = a==b.val

# Order relation is based on the value of measurements, uncertainties are ignored
for cmp in (:<, :<=)
    @eval begin
        ($cmp)(a::Measurement, b::Measurement) = ($cmp)(a.val, b.val)
        ($cmp)(a::Measurement, b::Rational) = ($cmp)(a.val, b)
        ($cmp)(a::Measurement, b::Real) = ($cmp)(a.val, b)
        ($cmp)(a::Rational, b::Measurement) = ($cmp)(a, b.val)
        ($cmp)(a::Real, b::Measurement) = ($cmp)(a, b.val)
    end
end

for f in (:isnan, :isfinite, :isinf)
    @eval ($f)(a::Measurement) = ($f)(a.val)
end
# "isinteger" should check the number is exactly an integer, without uncertainty.
isinteger(a::Measurement) = isinteger(a.val) && iszero(a.err)
# "iszero" is supposed to check the number is the additive identity element, so we must
# check also the uncertainty is zero.
iszero(a::Measurement) = iszero(a.val) && iszero(a.err)
