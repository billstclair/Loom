package Loom::Web::DB_Adapt;
use strict;
use Loom::Quote::C;

# This module maps keys used in the old GNU database into corresponding path
# names now used directly on the file system.  This enables all the DB code
# to work the same as always without change.  It is also used to port the old
# data over to the file system (see port_data).
#
# Note how we handle issuer keys (grid_I) specially.  In the GNU DB we stored
# the issuer hash as a packed 32 byte binary value.  On the file system I
# decided to store it in readable hexadecimal instead of binary.  So for those
# keys we map the value in and out.

sub new
	{
	my $class = shift;
	my $db = shift;

	my $s = bless({},$class);
	$s->{db} = $db;
	return $s;
	}

sub get
	{
	my $s = shift;
	my $key = shift;

	my $val = $s->{db}->get($s->map_key($key));

	if ($key =~ /^grid_I/)
		{
		$val = pack("H*",$val) if length($val) == 64;
		}

	return $val;
	}

sub put
	{
	my $s = shift;
	my $key = shift;
	my $val = shift;

	if ($key =~ /^grid_I/)
		{
		$val = unpack("H*",$val) if length($val) == 32;
		}

	$s->{db}->put($s->map_key($key),$val);
	return;
	}

sub commit
	{
	my $s = shift;
	return $s->{db}->commit;
	}

sub cancel
	{
	my $s = shift;
	return $s->{db}->cancel;
	}

sub map_key
	{
	my $s = shift;
	my $key = shift;

	if ($key =~ /^grid_V/)
		{
		# Grid value.
		die if length($key) != 54;

		my $type = unpack("H*",substr($key,6,16));
		die if length($type) != 32;

		my $hash = unpack("H*",substr($key,22,32));
		die if length($hash) != 64;

		my $path_type = $s->hex_path($type);
		my $path_hash = $s->hex_path($hash);

		return "grid/$path_type/V/$path_hash";
		}
	elsif ($key =~ /^grid_I/)
		{
		# Grid issuer location.
		die if length($key) != 22;

		my $type = unpack("H*",substr($key,6,16));
		die if length($type) != 32;

		my $path_type = $s->hex_path($type);
		return "grid/$path_type/I";
		}
	elsif ($key =~ /^ar_C/)
		{
		# Archive value.
		die if length($key) != 36;

		my $hash2 = unpack("H*",substr($key,4,32));
		die if length($hash2) != 64;

		my $path_hash2 = $s->hex_path($hash2);
		return "archive/$path_hash2";
		}
	else
		{
		# Unrecognized key.
		my $C = Loom::Quote::C->new;
		my $q_key = $C->quote($key);
		print STDERR "ERROR: $q_key\n";
		die;
		}
	}

sub hex_path
	{
	my $s = shift;
	my $hex_loc = shift;

	die if length($hex_loc) < 4;

	my $level1 = substr($hex_loc,0,2);
	my $level2 = substr($hex_loc,2,2);

	my $path = "$level1/$level2/$hex_loc";
	return $path;
	}

return 1;

__END__

# Copyright 2010 Patrick Chkoreff
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
