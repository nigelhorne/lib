package NJH::PDFPage;

# Add text to a page on a PDF document

our $pixelsperline = 16;	# point size 12

sub new
{
	my $class = shift;
	my $pdf = shift;	# PDF::API2 object

	$pixelsperline = 16;

	return bless { y => 750, page => $pdf->page() }, $class;
}

sub newline
{
	my $self = shift;

	$self->{'y'} -= $pixelsperline;

	if($self->{'y'} <= 10) {
		my $i = 0;
		while((my @call_details = (caller($i++)))) {
			print STDERR "\t", $call_details[1], ':', $call_details[2], ' calling function ', $call_details[3], "\n";
		}
		die 'BUG: fallen too low vertically; y = ', $self->{'y'};
	}

	return $self->{'y'};
}

sub full
{
	my $self = shift;

	return $self->{'y'} <= $pixelsperline * 2;
}

sub linesleft
{
	my $self = shift;

	return ($self->{'y'} / $pixelsperline) - 1;	# round fractions down
}

sub y
{
	my $self = shift;
	my $y = shift;

	if($y) {
		if($y <= 10) {
			my $i = 0;
			while((my @call_details = (caller($i++)))) {
				print STDERR "\t", $call_details[1], ':', $call_details[2], ' calling function ', $call_details[3], "\n";
			}
			die "BUG: fallen too low vertically; y = $y";
		}

		$self->{'y'} = $y;
	}

	return $self->{'y'};
}

sub page
{
	my $self = shift;

	return $self->{'page'};
}

sub text
{
	my $self = shift;

	if(!defined($self->{'text'})) {
		my $text = $self->{'text'} = $self->{'page'}->text();
		$text->textstart();
	}
	return $self->{'text'};
}

sub DESTROY {
	if(defined($^V) && ($^V ge 'v5.14.0')) {
		return if ${^GLOBAL_PHASE} eq 'DESTRUCT';	# >= 5.14.0 only
	}
	my $self = shift;

	if($self->{'text'}) {
		$self->{'text'}->textend();
	}
}
# TODO: DESTROY - add a page number

1;
