package NJH::PDFPage;

use strict;
use warnings;

# Add text to a page on a PDF document

our $pixelsperline = 16;	# point size 12
our $page_number = 1;

sub new
{
	my $class = shift;
	my $pdf = shift;	# PDF::API2 object

	$pixelsperline = 16;

	return bless { y => 750, page => $pdf->page(), page_number => $page_number++ }, $class;
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

sub page_number
{
	my $self = shift;

	return $self->{'page_number'};
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

	if(my $text = $self->{'text'}) {
		# Print the page number
		# FIXME: not all page numbers get printed
		$text->translate(300, $pixelsperline * 3);
		my $string = '- ' . $self->{'page_number'} . ' -';
		$text->text($string);
		$text->textend();
	}
}
# TODO: DESTROY - add a page number

1;
