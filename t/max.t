#!perl

use strict;
use warnings;

use Test::More;

use DBIx::Class::QueryLog;

my $triggered;
my $ql = DBIx::Class::QueryLog->new(
    max_log_event_generator => sub {
        my $self = shift;

        my $max = 2;
        my $i   = 0;

        sub {
            return unless $i++ == $max;

            $triggered++;
        }
    },
);

$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
ok(!$triggered, 'not yet triggered');
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
ok(!$triggered, 'still not triggered');
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
is($triggered, 1, 'triggered once');
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
is($triggered, 1, 'not triggered again');

subtest 'reset_max_log_event' => sub {

    $ql->reset_max_log_event;
    $triggered = 0;

    $ql->query_start('SELECT * from foo');
    $ql->query_end('SELECT * from foo');
    ok(!$triggered, 'not yet triggered');
    $ql->query_start('SELECT * from foo');
    $ql->query_end('SELECT * from foo');
    ok(!$triggered, 'still not triggered');
    $ql->query_start('SELECT * from foo');
    $ql->query_end('SELECT * from foo');
    is($triggered, 1, 'triggered once');
    $ql->query_start('SELECT * from foo');
    $ql->query_end('SELECT * from foo');
    is($triggered, 1, 'not triggered again');

};

done_testing;
