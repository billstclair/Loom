package Loom::Qty;
use strict;
use Loom::Int128;

=pod

=head1 NAME

This object formats quantities in various ways.  This might not be the most
elegant way to do these rather tricky functions, but it sure does the job
reliably.

=cut

sub new
	{
	my $class = shift;
	my $s = bless({},$class);
	return $s;
	}

# Format an integer as a ones-complement float.  For example, "-1" renders as
# "-0" (with scale 0).

sub ones_complement_float
	{
	my $s = shift;
	my $value = shift;
	my $scale = shift;
	my $min_precision = shift;
	my $max_precision = shift;

	if ($value =~ /^-/)
		{
		my $bv = Loom::Int128->from_dec($value);
		$bv->increment;
		$value = $bv->to_dec;
		$value = "-".$value if $value eq "0";
		}

	return
	$s->twos_complement_float($value,$scale,$min_precision,$max_precision);
	}

# Convert integer to float.  Examples:
#
# ("1234567",3)   => "1234.567"
# ("1230000",4)   => "123"
# ("1230000",4,2) => "123.00"
#
# Return null if not valid in any way.

sub twos_complement_float
	{
	my $s = shift;
	my $int_rep = shift;    # string
	my $scale = shift;      # the float is $int_rep * (10 ^ -$scale)
	my $min_precision = shift;
	my $max_precision = shift;

	$scale = "" if !$s->valid_scale($scale);
	$min_precision = "" if !$s->valid_scale($min_precision);
	$max_precision = "" if !$s->valid_scale($max_precision);

	$scale = 0 if $scale eq "";
	$min_precision = 0 if $min_precision eq "";
	$max_precision = $scale if $max_precision eq "";

	return "" if $int_rep !~ /^-?[0-9]+$/;

	return $int_rep if $scale eq "0";  # just an int, so return it

	my $format = "%0${scale}s";

	my $sign = "";
	if ($int_rep =~ /^-/)
		{
		$sign = "-";
		$int_rep = substr($int_rep,1);
		}

	$int_rep =~ s/^0+//;  # strip any existing leading zeroes
	$int_rep = sprintf($format, $int_rep);
		# pad leading zeroes so length is at least $scale

	my $int_part = substr($int_rep,0,length($int_rep)-$scale);
	$int_part = "0" if $int_part eq "";

	my $frac_part = $scale > 0 ? substr($int_rep,-$scale) : "";
	$frac_part = substr($frac_part,0,$max_precision);

	while (length($frac_part) > $min_precision &&
		substr($frac_part,-1) eq '0')
		{
		substr($frac_part,-1) = "";
		}

	my $float_rep = $sign . $int_part;
	$float_rep .= ".$frac_part" if $frac_part ne "";

	return $float_rep;
	}

# Convert float to integer.  Examples:
#
# ("0.16",6)     => "160000"
# (".000001",6)  => "1"
# ("12345678901234.567890",6) => "12345678901234567890"
#
# Return null string if not valid.  This includes the case where there is too
# much precision in the number, e.g. "0.001" when the scale is only 2.

sub float_to_int
	{
	my $s = shift;
	my $float_rep = shift;   # string
	my $scale = shift;

	$scale = "" if !$s->valid_scale($scale);
	$scale = 0 if $scale eq "";

	return "" if $float_rep !~ /^-?([0-9]*)((?:\.[0-9]+)?)$/;

	my $int_part = $1;
	my $frac_part = $2;

	my $sign = "";
	if ($float_rep =~ /^-/)
		{
		$sign = "-";
		$float_rep = substr($float_rep,1);
		}

	$frac_part = substr($frac_part,1) if $frac_part ne "";
		# drop decimal point

	my $num_zeroes = $scale - length($frac_part);
	return "" if $num_zeroes < 0;  # too much precision

	$frac_part .= '0' x $num_zeroes;
	$frac_part = substr($frac_part,0,$scale);

	my $int_rep = $int_part.$frac_part;

	$int_rep =~ s/^0+//;
	$int_rep = "0" if $int_rep eq "";
	$int_rep = $sign . $int_rep;

	return $int_rep;
	}

# Multiply a 128-bit integer value by a positive float value, returning a
# 128-bit integer value.
#
# We use this for assessing current values of raw Loom quantities, e.g. when we
# apply a time-based factor or a specific price factor.  These factors can be
# arbitrary IEEE floating point values, and we need to compute the product
# sensibly, portably, and reliably.  This is fairly tricky, but I've developed
# a full test suite for it.

sub multiply_float
	{
	my $s = shift;
	my $str_val = shift;        # 128-bit integer value as decimal string
	my $float_factor = shift;   # positive floating point number

	my $float_max_factor = 1e+12;  # This seems ample and quite portable.

	if ($float_factor < 0)
		{
		# The factor is negative, set it to 0.
		$float_factor = 0;
		}
	elsif ($float_factor > $float_max_factor)
		{
		# The factor is too big, so clip it to the maximum.
		$float_factor = $float_max_factor;
		}

	my $float_pow_ten = "1000000000";  # 9 places after decimal point
	my $str_factor = sprintf("%.0f", int($float_factor * $float_pow_ten));

	my $bv_val = Bit::Vector->new_Dec(256,$str_val);
	my $bv_factor = Bit::Vector->new_Dec(256,$str_factor);

	$bv_val->Multiply($bv_val,$bv_factor);
	my $dummy_remainder = Bit::Vector->new(256);
	my $bv_pow_ten = Bit::Vector->new_Dec(256,$float_pow_ten);
	$bv_val->Divide($bv_val,$bv_pow_ten,$dummy_remainder);

	# This interval clipping code may not be efficient, but it's reliable.
	{
	my $sign = $bv_val->Sign;

	if ($sign > 0)
		{
		my $max_val = Bit::Vector->new(256);
		$max_val->from_Dec("170141183460469231731687303715884105727");
		$bv_val->Copy($max_val) if $bv_val->Compare($max_val) > 0;
		}
	elsif ($sign < 0)
		{
		my $min_val = Bit::Vector->new(256);
		$min_val->from_Dec("-170141183460469231731687303715884105728");
		$bv_val->Copy($min_val) if $bv_val->Compare($min_val) < 0;
		}
	}

	return $bv_val->to_Dec;
	}

# Return true if the string is valid for use as a scale or min_precision
# parameter.  A valid string is either null or a two-digit number.

sub valid_scale
	{
	my $s = shift;
	my $str = shift;

	return 0 if !defined $str;
	return 1 if $str eq "";
	return 0 if length($str) > 2;
	return 1 if $str =~ /^\d{1,2}$/;
	return 0;
	}

return 1;

__END__

# Copyright 2008 Patrick Chkoreff
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions
# and limitations under the License.
