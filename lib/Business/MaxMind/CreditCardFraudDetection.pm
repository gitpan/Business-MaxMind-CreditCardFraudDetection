package Business::MaxMind::CreditCardFraudDetection;

use strict;

use vars qw($VERSION);

use Digest::MD5;
use LWP::UserAgent;
use base 'Business::MaxMind::HTTPBase';

# input fields
my @allowed_fields = qw/i domain city region postal country bin binName
		binPhone custPhone license_key requested_type forwardedIP emailMD5
		shipAddr txnID sessionID/;

$VERSION = '1.3';

sub _init {
  my $self = shift;
  $self->{url} = 'app/ccv2r';
  $self->{check_field} = 'score';
  $self->{timeout} ||= 10; # provide a default value of 10 seconds for timeout if not set by user
  %{$self->{allowed_fields}} = map {$_ => 1} @allowed_fields
}

sub filter_field {
  my ($self, $name, $value) = @_;

  if ($name eq 'emailMD5') {
    if ($value =~ m!\@!) {
      return Digest::MD5::md5_hex(lc($value));
    }
  }
  return $value;
}

1;
__END__

=head1 NAME

Business::MaxMind::CreditCardFraudDetection - Access free and paid MaxMind credit card fraud detection services

=head1 ABSTRACT

This module queries the MaxMind credit card fraud scoring service and returns the results.  The service
uses a free e-mail database, an IP address geography database, a bank identification number, and proxy checks
to return a risk factor score representing the likelihood that the credit card transaction is fraudulent.

=head1 SYNOPSIS

This example queries the credit card fraud scoring service and displays the results:

  my $ccfs = Business::MaxMind::CreditCardFraudDetection->new(isSecure => 1, debug => 0, timeout => 10);
  $ccfs->input( i => '24.24.24.24',
                domain => 'yahoo.com',
                city => 'New York',
                region => 'NY',
                postal => '10011',
                country => 'US',
                bin => '549099', # optional
                binName => 'MBNA America Bank', # optional
                binPhone => '800 421 2110', # optional
                custPhone => '212-242', # Area Code + Local Exchange
                license_key => 'LICENSE_KEY_HERE' # optional
              );
  $ccfs->query;
  my $hash_ref = $ccfs->output;

=head1 METHODS

=over 4

=item new

Class method that returns a Business::MaxMind::CreditCardFraudDetection object.  If isSecure is set to 1, it will use a
secure connection.  If debug is set to 1, will print debugging output to standard error.  timeout parameter is used
to set timeout in seconds, if absent default value for timeout is 10 seconds.

=item input

Sets input fields.  The input fields are

=begin html

<ul>
  <li><b>i:</b> Client IP Address (IP address of customer placing order)
  <li><b>domain:</b> E-mail domain (e.g. hotmail.com, aol.com)
  <li><b>city, region, postal, country:</b> Billing City/State/ZipCode/Country
  <li><b>bin:</b> BIN number, first 6 digits of credit card that identifies the issuing bank, optional
  <li><b>binName:</b> Name of the bank which issued the credit card based on BIN number, optional
  <li><b>binPhone:</b> Customer service phone number listed on back of credit card, optional
  <li><b>custPhone:</b> Area code and local exchange of customer's phone number, optional
  <li><b>license_key:</b> License Key, for registered users, optional
</ul>

=end html

See L<http://www.maxmind.com/app/ccv> for full list of input fields.

Returns 1 on success, 0 on failure.

=item query

Sends out query to MaxMind server and waits for response.  If the primary
server fails to respond, it sends out a request to the secondary server.

=item output

Returns the output returned by the MaxMind server as a hash reference.

=item error_msg

Returns the error message from an input or query method call.

=back

=head1 SEE ALSO

L<http://www.maxmind.com/app/ccv_overview>

=head1 AUTHOR

TJ Mather, E<lt>tjmather@maxmind.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by MaxMind LLC

All rights reserved.  This package is free software and is licensed under
the GPL.  For details, see the COPYING file.

=cut
