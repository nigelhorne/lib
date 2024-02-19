package NJH::Place;

# A place - a geographic location
# SEE ALSO: L<Geo::Location>

use strict;
use warnings;
use Class::Simple;

my @ISA = ('Class::Simple');

use overload (
        # '==' => \&equal,
        # '!=' => \&not_equal,
        '""' => \&as_string,
        bool => sub { 1 },
        fallback => 1   # So that boolean tests don't cause as_string to be called
);

sub new
{
	my $proto = shift;
	if(my $class = ref($proto) || $proto) {
		my %args = (ref($_[0]) eq 'HASH') ? %{$_[0]} : @_;
		return bless \%args, $class;
	}
}

=head2	as_string

Prints the object in human-readable format.

=cut

sub as_string {
	my $self = shift;

	if($self->{'location'}) {
		return $self->{'location'};
	}

	my $rc = $self->{'name'};
	if($rc) {
		$rc = ucfirst(lc($rc));
	}

	# foreach my $field('house_number', 'number', 'road', 'street', 'AccentCity', 'city', 'county', 'region', 'state_district', 'state', 'country') {
	foreach my $field('house_number', 'number', 'road', 'street', 'city', 'county', 'region', 'state_district', 'state', 'country') {
		if(my $value = ($self->{$field} || $self->{ucfirst($field)})) {
			if($rc) {
				if(($field eq 'street') || ($field eq 'road')) {
					if($self->{'number'} || $self->{'house_number'}) {
						$rc .= ' ';
					} else {
						$rc .= ', '
					}
				} else {
					$rc .= ', ';
				}
			} elsif($rc) {
				$rc .= ', ';
			}
			my $leave_case = 0;
			if(my $country = $self->{'country'} // $self->{'Country'}) {
				if(uc($country) eq 'US') {
					if(($field eq 'state') || ($field eq 'Region') || (lc($field) eq 'country')) {
						$leave_case = 1;
						if(lc($field) eq 'country') {
							$value = 'US';
						}
					}
				} elsif(($country eq 'Canada') || ($country eq 'Australia')) {
					if($field eq 'state') {
						$leave_case = 1;
					}
				} elsif(uc($country) eq 'GB') {
					if(lc($field) eq 'country') {
						$leave_case = 1;
						$value = 'GB';
					}
				}
			}
			if($leave_case) {
				$rc .= $value;
			} else {
				$rc .= $self->_sortoutcase($value);
				if((($field eq 'street') || ($field eq 'road')) &&
				   ($rc =~ /(.+)\s([NS][ew])$/)) {
					# e.g South Street NW
					$rc = "$1 " . uc($2);
				}
			}
		}
	}

	return $self->{'location'} = $rc;
}

sub _sortoutcase {
	my $field = lc($_[1]);
	my $rc;

	foreach (split(/ /, $field)) {
		if($rc) {
			$rc .= ' ';
		}
		$rc .= ucfirst($_);
	}

	return $rc;
}

=head2	attr

Get/set location attributes, e.g. city

    $location->city('London');
    $location->country('UK');
    print $location->as_string(), "\n";

=cut

sub AUTOLOAD {
	our $AUTOLOAD;
	my $key = $AUTOLOAD;

	$key =~ s/.*:://;

	return if($key eq 'DESTROY');

	my $self = shift;

	if(my $value = shift) {
		$self->{$key} = $value;
	}

	return $self->{$key};
}

1;
