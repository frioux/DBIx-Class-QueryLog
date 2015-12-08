package DBIx::Class::QueryLog::NotifyOnMax;

use Moo;

extends 'DBIx::Class::QueryLog';

has _max_count => (
   is => 'ro',
   builder => sub { 1_000 },
   init_arg => 'max_count',
);

has notified => ( is => 'rw' );

sub notify {
   my $self = shift;

   my $max = $self->_max_count;
   warn "Max query count ($max) exceeded; did you forget to ->reset your query logger?";
   $self->notified(1);
}

sub query_end {
   my ($self, @rest) = @_;

   my $had_cur = $self->current_query;

   $self->next::method(@rest);

   $self->notify
      if defined $had_cur &&
         !$self->notified  &&
         $self->count > $self->_max_count
}

sub reset {
   my ($self, @rest) = @_;

   $self->next::method(@rest);

   $self->notified(undef);
}

1;

__END__

=pod

=head1 SYNOPSIS

 my $schema = ... # Get your schema!
 my $ql = DBIx::Class::QueryLog::NotifyOnMax->new(
   max_count => 100,
 );
 $schema->storage->debugobj($ql);
 $schema->storage->debug(1);
   ... # get warning when you do more than 100 queries

=head1 DESCRIPTION

More than once I've run into memory leaks that are caused by the user using
L<DBIx::Class::QueryLog> and forgetting to call L<DBIx::Class::QueryLog/reset>.
This subclass of C<DBIx::Class::QueryLog> simply warns after C<1_000> queries
have gone through it.  If you want to do something more complex, subclasses
which override the L</notify> method are a good idea.

=head1 METHODS

=head2 new

Overridden version of L<DBIx::Class::QueryLog/new>, simply adds an optional
C<max_count> parameter which defaults to C<1_000>.

=head2 notify

This is the method that runs when the C<max_count> has been exceeded.  Takes no
parameters.  Make sure to call C<< $self->notified(1) >> if you want the event
to only take place once after the threshold has been exceeded.
