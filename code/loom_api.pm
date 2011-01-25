package loom_api;
use strict;
use kv;
use LWP::UserAgent;

# We maintain a table of user agents, one per process, in case your code does
# a fork.  That's because the LWP and SSL code gets a little confused if every
# process shares the same user agent object.  I discovered this when writing
# an API stress test that spawns several processes.

my $g_user_agent_table = {};

sub user_agent
	{
	my $pid = $$;
	my $ua = $g_user_agent_table->{$pid};

	if (!defined $ua)
		{
		# Set the number of connections to cache for "Keep Alive".
		$ua = LWP::UserAgent->new(keep_alive => 20);

		# Set the number of seconds to wait before aborting connection.
		$ua->timeout(30);

		$g_user_agent_table->{$pid} = $ua;
		}

	return $ua;
	}

# Get the the $url and return the response from the server as text.
# Die if there's any problem with the connection.
sub get_text
	{
	my $url = shift;

	my $response = user_agent()->get($url);

	return $response->decoded_content if $response->is_success;

	die $response->status_line;
	}

# Get the $url and return the response from the server as a Perl hash.
# Die if there's any problem with the connection.
sub get_hash
	{
	my $url = shift;

	my $text = get_text($url);
	return kv::text_to_hash($text);
	}

return 1;
