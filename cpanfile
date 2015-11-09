requires    'Class::Accessor';
requires    'Moose' => '0.90';
requires    'Time::HiRes';
requires    'DBIx::Class'       => '0.07000';

on test => sub {
   requires    'Test::More';
};
