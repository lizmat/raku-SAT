=begin pod

=head1 NAME

SAT - Generic SAT solver interfaces

=head1 SYNOPSIS

  use SAT;

  # TODO

=head1 DESCRIPTION

TODO

=end pod

unit module SAT;

role Solver {
    multi method solve (:$now where *.so, |c --> Bool) {
        await self.solve: |c
    }

    multi method solve (IO::Path $file, |c --> Promise) {
        self.solve: $file.lines, |c
    }

    multi method solve (Str $DIMACS, |c --> Promise) {
        self.solve: $DIMACS.lines, |c
    }

    multi method solve (List $lines, |c --> Promise) {
        self.solve: $lines.Supply, |c
    }

    multi method solve (Seq $lines, |c --> Promise) {
        self.solve: $lines.Supply, |c
    }

    multi method solve (Supply $lines --> Promise) {
        self.solve: $lines, my $dummy;
    }

    multi method solve (Supply $lines, $witness is rw --> Promise) { … }
}

# TODO: Support approximate counters
role Counter {
    multi method count (:$now where *.so, |c --> Bool) {
        await self.count: |c
    }

    multi method count (IO::Path $file --> Promise) {
        self.count: $file.lines
    }

    multi method count (Str $DIMACS --> Promise) {
        self.count: $DIMACS.lines
    }

    multi method count (List $lines --> Promise) {
        self.count: $lines.Supply
    }

    multi method count (Seq $lines --> Promise) {
        self.count: $lines.Supply
    }

    multi method count (Supply $lines --> Promise) { … }
}

role Enumerator {
    multi method enumerate (:$now where *.so, |c --> List) {
        self.enumerate(|c).List
    }

    multi method enumerate (IO::Path $file --> Supply) {
        self.enumerate: $file.lines
    }

    multi method enumerate (Str $DIMACS --> Supply) {
        self.enumerate: $DIMACS.lines
    }

    multi method enumerate (List $lines --> Supply) {
        self.enumerate: $lines.Supply
    }

    multi method enumerate (Seq $lines --> Supply) {
        self.enumerate: $lines.Supply
    }

    multi method enumerate (Supply $lines --> Supply) { … }
}

# TODO
# role Maximizer { }

sub sat-solve (|c) is export {
    for SAT::Solver::.values.grep(* ~~ SAT::Solver) {
        try .new.solve(|c)
        andthen .return
    }
    die "no suitable SAT::Solver found";
}

sub sat-count (|c) is export {
    for SAT::Counter::.values.grep(* ~~ SAT::Counter) {
        try .new.count(|c)
        andthen .return
    }
    die "no suitable SAT::Counter found";
}

sub sat-enumerate (|c) is export {
    for SAT::Enumerator::.values.grep(* ~~ SAT::Enumerator) {
        try .new.enumerate(|c)
        andthen .return
    }
    die "no suitable SAT::Enumerator found";
}

=begin pod

=head1 AUTHOR

 Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
