package NJH::Normalize;

# Normalize street names for comparison
use Geo::Coder::Abbreviations;

our $abbreviations;

sub normalize($);
# sub abbreviate($);

sub normalize($) {
	my $street = shift;

	$abbreviations ||= Geo::Coder::Abbreviations->new();

	$street = uc($street);
	if($street =~ /(.+)\s+(.+)\s+(.+)/) {
		my $a;
		if($a = $abbreviations->abbreviate($2)) {
			$street = "$1 $a $3";
		} elsif($a = $abbreviations->abbreviate($3)) {
			$street = "$1 $2 $a";
		}
	} elsif($street =~ /(.+)\s(.+)$/) {
		if(my $a = $abbreviations->abbreviate($2)) {
			$street = "$1 $a";
		}
	}
	$street =~ s/^0+//;	# Turn 04th St into 4th St
	return $street;
}

# sub abbreviate($) {
	# my $type = uc(shift);

	# $abbreviations ||= Geo::Coder::Abbreviations->new();

	# if(my $rc = $abbreviations->abbreviate($type)) {
		# return $rc;
	# }
	# return $type;
# }

1;
