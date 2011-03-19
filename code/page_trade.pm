use strict;

my $g_trade_url;
my $g_vendor_url;
my $g_set_vendor;
my $g_set_offer_product;
my $g_set_accept_product;
my $g_set_product_offer_by_vendor;
my $g_set_product_accept_by_vendor;

sub vendor_url
	{
	my $vendor = shift;
	my $url = shift;

	$g_vendor_url->{$vendor} = $url;
	return;
	}

sub vendor_offer
	{
	my $vendor = shift;
	my $product = shift;

	$g_set_vendor->{$vendor} = 1;
	$g_set_offer_product->{$product} = 1;
	$g_set_product_offer_by_vendor->{$product}->{$vendor} = 1;
	}

sub vendor_accept
	{
	my $vendor = shift;
	my $product = shift;

	$g_set_vendor->{$vendor} = 1;
	$g_set_accept_product->{$product} = 1;
	$g_set_product_accept_by_vendor->{$product}->{$vendor} = 1;
	}

sub vendor_trade_url
	{
	my $vendor = shift;
	my $offer = shift;
	my $accept = shift;
	my $url = shift;

	$g_trade_url->{$vendor}->{$offer}->{$accept} = $url;
	return;
	}

sub vendors_who_offer
	{
	my $product = shift;

	return
	[sort_names(keys %{$g_set_product_offer_by_vendor->{$product}})];
	}

sub vendors_who_accept
	{
	my $product = shift;

	return
	[sort_names(keys %{$g_set_product_accept_by_vendor->{$product}})];
	}

# LATER soft-code this into archive data

sub page_trade_read_data
	{
	# If we've already read the data, don't read it again.
	return if defined $g_vendor_url;

	$g_vendor_url = {};
	$g_trade_url = {};
	$g_set_vendor = {}; # LATER not used yet

	$g_set_accept_product = {};
	$g_set_offer_product = {};

	$g_set_product_accept_by_vendor = {};
	$g_set_product_offer_by_vendor = {};

	vendor_url("Capulin","http://capulin.com");
	vendor_offer("Capulin","Coffee");

	# You can do special characters like this:
	#vendor_offer("Capulin","Coffee &#1046;");

	vendor_accept("Capulin","Bitcoin");
	vendor_accept("Capulin","Capulin Coffee Units");
	vendor_accept("Capulin","PC Gold Grams");

	vendor_url("GoldNow","http://goldnow.st");
	vendor_offer("GoldNow","Bank Wire");
	vendor_offer("GoldNow","Card Funding");
	vendor_offer("GoldNow","MoneyGram");
	vendor_offer("GoldNow","Usage Tokens");

	vendor_offer("GoldNow","GNB Gold Grams");
	vendor_offer("GoldNow","GNB Silver Ounces");
	vendor_offer("GoldNow","iGolder");
	vendor_offer("GoldNow","Liberty Reserve");
	vendor_offer("GoldNow","Pecunix");
	vendor_offer("GoldNow","Web Money");

	vendor_accept("GoldNow","Bank Wire");
	vendor_accept("GoldNow","Money Order");
	vendor_accept("GoldNow","MoneyGram");

	vendor_accept("GoldNow","GNB Gold Grams");
	vendor_accept("GoldNow","GNB Silver Ounces");
	vendor_accept("GoldNow","iGolder");
	vendor_accept("GoldNow","Liberty Reserve");
	vendor_accept("GoldNow","Pecunix");
	vendor_accept("GoldNow","Web Money");

	vendor_url("GSF System","https://www.gsfsystem.ch");
	vendor_offer("GSF System","Bank Wire");
	vendor_offer("GSF System","GSF Gold Globals");
	vendor_offer("GSF System","GSF Silver Isles");
	vendor_offer("GSF System","Usage Tokens");

	vendor_accept("GSF System","Bank Wire");
	vendor_accept("GSF System","GSF Gold Globals");
	vendor_accept("GSF System","GSF Silver Isles");

	vendor_offer("pc-vault","Gold Krugerrand");
	vendor_accept("pc-vault","Gold Krugerrand");
	vendor_offer("pc-vault","PC Gold Grams");
	vendor_accept("pc-vault","PC Gold Grams");

	vendor_offer("pc-vault","Cash");
	vendor_accept("pc-vault","Cash");
	vendor_offer("pc-vault","PC FR Tokens");
	vendor_accept("pc-vault","PC FR Tokens");

	vendor_offer("pc-vault","Usage Tokens");
	vendor_accept("pc-vault","Usage Tokens");
	vendor_accept("pc-vault","Pecunix");

	vendor_url("Grass Hill Alpacas",
	"http://www.grasshillalpacas.com/alpacaproductsforloomassets.html");

	vendor_offer("Grass Hill Alpacas","Alpaca Products");
	vendor_offer("Grass Hill Alpacas","GSF Gold Globals");
	vendor_offer("Grass Hill Alpacas","GSF Silver Isles");
	vendor_accept("Grass Hill Alpacas","Bitcoin");
	vendor_accept("Grass Hill Alpacas","Capulin Coffee Units");
	vendor_accept("Grass Hill Alpacas","GSF Gold Globals");
	vendor_accept("Grass Hill Alpacas","GSF Silver Isles");
	vendor_accept("Grass Hill Alpacas","PC Gold Grams");

	vendor_trade_url("Grass Hill Alpacas",
	"Alpaca Products","Bitcoin",
	"http://www.grasshillalpacas.com/alpacaproductsforbitcoinoffer.html");

	vendor_trade_url("Grass Hill Alpacas",
	"Alpaca Products","Capulin Coffee Units",
	"http://www.grasshillalpacas.com/alpacaproductsforloomassets.html");

	vendor_trade_url("Grass Hill Alpacas",
	"Alpaca Products","GSF Gold Globals",
	"http://www.grasshillalpacas.com/alpacaproductsforloomassets.html");

	vendor_trade_url("Grass Hill Alpacas",
	"Alpaca Products","GSF Silver Isles",
	"http://www.grasshillalpacas.com/alpacaproductsforloomassets.html");

	vendor_trade_url("Grass Hill Alpacas",
	"Alpaca Products","PC Gold Grams",
	"http://www.grasshillalpacas.com/alpacaproductsforloomassets.html");

	vendor_url("OffshoreCashier","http://offshorecashier.com");
	vendor_accept("OffshoreCashier","Bank Wire");
	vendor_accept("OffshoreCashier","Offshore Cashier EUR");
	vendor_accept("OffshoreCashier","Offshore Cashier USD");
	vendor_accept("OffshoreCashier","Offshore Cashier Gold Grams");
	vendor_accept("OffshoreCashier","Offshore Cashier Silver Grams");

	vendor_offer("OffshoreCashier","Bank Wire");
	vendor_offer("OffshoreCashier","Offshore Cashier EUR");
	vendor_offer("OffshoreCashier","Offshore Cashier USD");
	vendor_offer("OffshoreCashier","Offshore Cashier Gold Grams");
	vendor_offer("OffshoreCashier","Offshore Cashier Silver Grams");

	vendor_offer("OffshoreCashier","Gold American Eagle");
	vendor_offer("OffshoreCashier","Gold Krugerrand");
	vendor_offer("OffshoreCashier","Gold Canadian Maple Leaf");

	vendor_url("Simply Your Food","http://simplyyourfood.com");

	vendor_offer("Simply Your Food","Food Supplies");
	vendor_offer("Simply Your Food","Simply Your Food Currency");
	vendor_offer("Simply Your Food","Medical Consultation");
	vendor_accept("Simply Your Food","Simply Your Food Currency");
	vendor_accept("Simply Your Food","Waterman Hours");
	vendor_accept("Simply Your Food","GNB Gold Grams");
	vendor_accept("Simply Your Food","GSF Gold Globals");
	vendor_accept("Simply Your Food","PC Gold Grams");
	vendor_accept("Simply Your Food","Check");
	vendor_accept("Simply Your Food","Money Order");
	vendor_accept("Simply Your Food","Credit Card");

	vendor_url("Rayservers","http://rayservers.com");

	vendor_offer("Rayservers","Computers");
	vendor_offer("Rayservers","Network Services");
	vendor_offer("Rayservers","GSF Gold Globals");
	vendor_offer("Rayservers","GSF Silver Isles");
	vendor_offer("Rayservers","Bank Wire");

	vendor_accept("Rayservers","GSF Gold Globals");
	vendor_accept("Rayservers","GSF Silver Isles");
	vendor_accept("Rayservers","Bank Wire");

	vendor_url("Metropipe","http://metropipe.net");
	vendor_offer("Metropipe","Network Services");
	vendor_accept("Metropipe","Bitcoin");
	vendor_accept("Metropipe","iGolder");
	vendor_accept("Metropipe","Pecunix");
	vendor_accept("Metropipe","Paypal");
	vendor_accept("Metropipe","Credit Card");
	vendor_accept("Metropipe","c-gold");
	vendor_accept("Metropipe","Liberty Reserve");

	vendor_url("Nanaimo","http://nanaimogold.com");
	vendor_offer("Nanaimo","Pecunix");
	vendor_offer("Nanaimo","Paypal");
	vendor_offer("Nanaimo","Western Union");
	vendor_offer("Nanaimo","Liberty Reserve");
	vendor_offer("Nanaimo","c-gold");
	vendor_offer("Nanaimo","HD-Money");
	vendor_offer("Nanaimo","Bitcoin");
	vendor_offer("Nanaimo","EuroGoldCash");

	vendor_accept("Nanaimo","Western Union");
	vendor_accept("Nanaimo","MoneyGram");
	vendor_accept("Nanaimo","Cash");
	vendor_accept("Nanaimo","Bank Deposit");
	vendor_accept("Nanaimo","Pecunix");
	vendor_accept("Nanaimo","Liberty Reserve");
	vendor_accept("Nanaimo","c-gold");
	vendor_accept("Nanaimo","HD-Money");
	vendor_accept("Nanaimo","Bitcoin");
	vendor_accept("Nanaimo","EuroGoldCash");

	return;
	}

sub page_trade_search
	{
	page_trade_read_data();

	my $offer_product = http_get("offer");
	my $accept_product = http_get("accept");

	emit(<<EOM
<p>
Click an item in each column.  As you click, entries will highlight in gold to
reflect new possibilities.

<p>
<table border=1 cellpadding=2 style='border-collapse:collapse;'>
<colgroup>
<col width=215>
<col width=215>
<col width=215>
</colgroup>
<tr>
EOM
);

	my $warm_color = "#fff7b5";

	for my $type (qw(offer accept))
		{
		my $table = "";

		my $label = $type eq "offer"
			? "You seek:"
			: "in exchange for:";

		$table .= <<EOM;
<h2> $label </h2>
<table border=0 cellpadding=2 style='border-collapse:collapse;'>
EOM
		my @products;
		if ($type eq "offer")
			{
			@products = keys %{$g_set_offer_product};
			}
		elsif ($type eq "accept")
			{
			@products = keys %{$g_set_accept_product};
			}

		@products = sort_names(@products);

		for my $product (@products)
			{
			my $highlight = 0;
			if ($type eq "offer" && $product eq $offer_product)
				{
				$highlight = 1;
				}
			elsif ($type eq "accept" && $product eq $accept_product)
				{
				$highlight = 1;
				}

			my $style = $highlight ? " class=highlight_link" : "";

			my $context = op_new
				(
				"offer",$offer_product,
				"accept",$accept_product,
				);

			op_put($context,$type,$product);

			my $url = make_url("/trade",op_pairs($context));

			my $q_product = html_semiquote($product);
			$q_product = qq{<a$style href="$url">$q_product</a>};

			my $possible = 0;
			if ($type eq "offer" && $accept_product ne "")
				{
				my $vendors = intersect(
					vendors_who_offer($product),
					vendors_who_accept($accept_product));
				$possible = (@$vendors > 0);
				}
			elsif ($type eq "accept" && $offer_product ne "")
				{
				my $vendors = intersect(
					vendors_who_offer($offer_product),
					vendors_who_accept($product));
				$possible = (@$vendors > 0);
				}

			my $cell_style = $possible
				? " style='background-color:$warm_color'" : "";

			$table .= <<EOM;
<tr>
<td$cell_style> $q_product </td>
</tr>
EOM
			}
		$table .= <<EOM;
</table>
EOM
		emit(<<EOM
<td valign=top>
$table
</td>
EOM
);
		}

	my $vendors = intersect(
		vendors_who_offer($offer_product),
		vendors_who_accept($accept_product));

	my $table .= <<EOM;
<table border=0 cellpadding=2 style='border-collapse:collapse;'>
EOM
	for my $vendor (@$vendors)
		{
		my $q_vendor = html_semiquote($vendor);

		my $url;
		if ($offer_product ne "" && $accept_product ne "")
			{
			$url =
			$g_trade_url->{$vendor}->{$offer_product}->{$accept_product};
			}

		$url = $g_vendor_url->{$vendor} if !defined $url;

		$q_vendor = qq{<a href="$url">$q_vendor</a>} if defined $url;

		$table .= <<EOM;
<tr>
<td> $q_vendor </td>
</tr>
EOM
		}
	$table .= <<EOM;
</table>
EOM

	emit(<<EOM
<td valign=top>
<h2> Possible vendors: </h2>
$table
</td>
EOM
);

	emit(<<EOM
</tr>
</table>
EOM
);

	return;
	}

sub page_trade_get_listed
	{
	emit(<<EOM
<p>
To obtain a listing on the Find Trades page, we ask that you
<a href="http://rayservers.com/gold">get verified by the GSF System</a>.
Verification by this trusted party helps people do business safely.
Otherwise, you're on your own.
EOM
);

	return;
	}

sub page_trade_respond
	{
	top_link(highlight_link("/","Home",0));

	my $query = http_get("q");

	top_link(highlight_link("/trade","Find Trades",($query eq "")));
	top_link(highlight_link("/trade?q=get-listed",
		"Get Listed Here",($query eq "get-listed")));

	if ($query eq "")
		{
		set_title("Find Trades");
		page_trade_search();
		}
	elsif ($query eq "get-listed")
		{
		set_title("Get Listed");
		page_trade_get_listed();
		}
	else
		{
		page_not_found();
		}

	##sloop_disconnect();  # for testing

	return;
	}

return 1;
