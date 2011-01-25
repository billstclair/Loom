package kv;
use strict;
use Loom::KV;

sub text_to_hash
	{
	my $text = shift;

	return Loom::KV->new->hash($text);
	}

sub hash_to_text
	{
	my $hash = shift;

	return Loom::KV->new->text($hash);
	}

return 1;
