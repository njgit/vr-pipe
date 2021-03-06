=head1 NAME

VRPipe::Parser::bamcheck - parse bamcheck files

=head1 SYNOPSIS

    use VRPipe::Parser;
    
    # create object, supplying bas file
    my $pars = VRPipe::Parser->create('bamcheck', {file => 'my.bam.bamcheck'});
    
    # unlike normal parsers, you do not use parsed_record() or next_record();
    # instead access information in the bamcheck file through the following
    # methods
    
    # methods that return simple single values corresponding to the SN lines in
    # the bamcheck file:
    my $val = $pars->sequences();
    my $val = $pars->is_paired();
    my $val = $pars->is_sorted();
    my $val = $pars->first_fragments();
    my $val = $pars->last_fragments();
    my $val = $pars->reads_mapped();
    my $val = $pars->reads_unmapped();
    my $val = $pars->reads_unpaired();
    my $val = $pars->reads_paired();
    my $val = $pars->reads_duplicated();
    my $val = $pars->reads_mq0();
    my $val = $pars->total_length();
    my $val = $pars->bases_mapped();
    my $val = $pars->bases_mapped_cigar();
    my $val = $pars->bases_trimmed();
    my $val = $pars->bases_duplicated();
    my $val = $pars->mismatches();
    my $val = $pars->error_rate();
    my $val = $pars->average_length();
    my $val = $pars->maximum_length();
    my $val = $pars->average_quality();
    my $val = $pars->insert_size_average();
    my $val = $pars->insert_size_standard_deviation();
    my $val = $pars->inward_oriented_pairs();
    my $val = $pars->outward_oriented_pairs();
    my $val = $pars->pairs_with_other_orientation();
    
    # COV lines give the coverage:
    my $cov_hash = $pars->coverage(); # keys are coverage in bp, vals are counts
    my $cum_hash = $pars->cumulative_coverage; # as above, but cumulative counts
    my $mean = $pars->mean_coverage(); # a number
    
    # The remaining sections of the file can be accessed by calling one of the
    # following methods, which all return an array ref. Each element of this ref
    # corresponds to a line from that section, and the element is an array ref
    # of all the values on the line, excluding the first column.
    my $array_ref = $pars->first_fragment_qualities(); # FFQ lines
    my $array_ref = $pars->last_fragment_qualities(); # LFQ lines
    my $array_ref = $pars->first_fragment_gc(); # GCF lines
    my $array_ref = $pars->last_fragment_gc(); # GCL lines
    my $array_ref = $pars->indel_cycles(); # IC lines
    my $array_ref = $pars->indel_dist(); # ID lines
    my $array_ref = $pars->insert_size(); # IS lines
    my $array_ref = $pars->gc_depth(); # GCD lines
    my $array_ref = $pars->mismatches_per_cycle(); # MPC lines
    my $array_ref = $pars->gc_content_per_cycle(); # GCC lines
    my $array_ref = $pars->read_lengths(); # RL lines

=head1 DESCRIPTION

A parser for bamcheck files, which are bam statistic files, as produced by
the B<bamcheck> executable.

=head1 AUTHOR

Sendu Bala <sb10@sanger.ac.uk>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011-2012 Genome Research Limited.

This file is part of VRPipe.

VRPipe is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see L<http://www.gnu.org/licenses/>.

=cut

use VRPipe::Base;

class VRPipe::Parser::bamcheck with VRPipe::ParserRole {
    has 'sequences' => (is => 'ro',
                        isa => 'Int',
                        writer => '_sequences');
    
    has 'is_paired' => (is => 'ro',
                        isa => 'Bool',
                        writer => '_is_paired');
    
    has 'is_sorted' => (is => 'ro',
                        isa => 'Bool',
                        writer => '_is_sorted');
    
    has 'first_fragments' => (is => 'ro',
                              isa => 'Int',
                              writer => '_first_fragments');
    
    has 'last_fragments' => (is => 'ro',
                             isa => 'Int',
                             writer => '_last_fragments');
    
    has 'reads_mapped' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_mapped');
    
    has 'reads_unmapped' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_unmapped');
    
    has 'reads_unpaired' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_unpaired');
    
    has 'reads_paired' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_paired');
    
    has 'reads_duplicated' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_duplicated');
    
    has 'reads_mq0' => (is => 'ro',
                           isa => 'Int',
                           writer => '_reads_mq0');
    
    has 'total_length' => (is => 'ro',
                           isa => 'Int',
                           writer => '_total_length');
    
    has 'bases_mapped' => (is => 'ro',
                           isa => 'Int',
                           writer => '_bases_mapped');
    
    has 'bases_mapped_cigar' => (is => 'ro',
                           isa => 'Int',
                           writer => '_bases_mapped_cigar');
    
    has 'bases_trimmed' => (is => 'ro',
                           isa => 'Int',
                           writer => '_bases_trimmed');
    
    has 'bases_duplicated' => (is => 'ro',
                           isa => 'Int',
                           writer => '_bases_duplicated');
    
    has 'mismatches' => (is => 'ro',
                           isa => 'Int',
                           writer => '_mismatches');
    
    has 'error_rate' => (is => 'ro',
                           isa => 'Num',
                           writer => '_error_rate');
    
    has 'average_length' => (is => 'ro',
                         isa => 'Num',
                         writer => '_average_length');
    
    has 'maximum_length' => (is => 'ro',
                         isa => 'Int',
                         writer => '_maximum_length');
    
    has 'average_quality' => (is => 'ro',
                         isa => 'Num',
                         writer => '_average_quality');
    
    has 'insert_size_average' => (is => 'ro',
                         isa => 'Num',
                         writer => '_insert_size_average');
    
    has 'insert_size_standard_deviation' => (is => 'ro',
                                  isa => 'Num',
                                  writer => '_insert_size_standard_deviation');
    
    has 'inward_oriented_pairs' => (is => 'ro',
                         isa => 'Int',
                         writer => '_inward_oriented_pairs');
    
    has 'outward_oriented_pairs' => (is => 'ro',
                         isa => 'Int',
                         writer => '_outward_oriented_pairs');
    
    has 'pairs_with_other_orientation' => (is => 'ro',
                         isa => 'Int',
                         writer => '_pairs_with_other_orientation');
    
    has '_coverage' => (traits    => ['Hash'],
                        is        => 'ro',
                        isa       => 'HashRef[Str]',
                        default   => sub { {} },
                        handles   => { '_set_coverage' => 'set',
                                       coverage => 'get' });
    
    has '_cum_coverage' => (traits    => ['Hash'],
                            is        => 'ro',
                            isa       => 'HashRef[Str]',
                            default   => sub { {} },
                            handles   => { cumulative_coverage => 'get' });
    
    has 'mean_coverage' => (is => 'ro',
                            isa => 'Num',
                            writer => '_mean_coverage');
    
    our %mapping = (FFQ => 'first_fragment_qualities',
                    LFQ => 'last_fragment_qualities',
                    GCF => 'first_fragment_gc',
                    GCL => 'last_fragment_gc',
                    IC  => 'indel_cycles',
                    ID  => 'indel_dist',
                    IS  => 'insert_size',
                    GCD => 'gc_depth',
                    MPC => 'mismatches_per_cycle',
                    GCC => 'gc_content_per_cycle',
                    RL  => 'read_lengths'); # we don't actually use this mapping except to confirm what sections we understand
    
    has 'first_fragment_qualities' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_FFQ' => 'push' });
    
    has 'last_fragment_qualities' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_LFQ' => 'push' });
    
    has 'first_fragment_gc' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_GCF' => 'push' });
    
    has 'last_fragment_gc' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_GCL' => 'push' });
    
    has 'indel_cycles' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_IC' => 'push' });
    
    has 'indel_dist' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_ID' => 'push' });
    
    has 'insert_size' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_IS' => 'push' });
    
    has 'gc_depth' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_GCD' => 'push' });
    
    has 'mismatches_per_cycle' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_MPC' => 'push' });
    
    has 'gc_content_per_cycle' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_GCC' => 'push' });
    
    has 'read_lengths' => (traits    => ['Array'],
                                       is        => 'ro',
                                       isa       => 'ArrayRef[ArrayRef[Str]]',
                                       default   => sub { [] },
                                       handles   => { '_push_RL' => 'push' });
    
=head2 parsed_record

 Title   : parsed_record
 Usage   : my $parsed_record= $obj->parsed_record()
 Function: Get the data structure that will hold the last parsed record
           requested by next_record()
 Returns : array ref, currently empty, since only SN lines are parsed so far,
           and their content can be found with other methods
 Args    : n/a

=cut
    
=head2 next_record

 Title   : next_record
 Usage   : while ($obj->next_record()) { # look in parsed_record }
 Function: next_record does nothing in this parser; use the various methods to
           to access the data, which is all parsed automatically
 Returns : 0
 Args    : n/a

=cut
    method next_record {
        return 0;
    }
    
    method _get_header {
        my $fh = $self->fh() || return;
        return 1 if $self->_header_parsed();
        
        my $saw = 0;
        my $cov_count = 0;
        my $cov_total = 0;
        my $cum_cov = $self->_cum_coverage;
        while (<$fh>) {
            next if /^#/;
            
            if (/^SN\s+([^:]+):\s+(\S+)/) {
                my $method = $1;
                my $value = $2;
                my $orig_method = $method;
                $method =~ s/\s+/_/g;
                $method = 'first_fragments' if $method eq '1st_fragments';
                $method = 'bases_mapped_cigar' if $method eq 'bases_mapped_(cigar)';
                $method = lc('_'.$method);
                unless ($self->can($method)) {
                    $self->warn("unexpected SN line $orig_method");
                    next;
                }
                $self->$method($value);
                $saw++;
            }
            elsif (my ($range, $cov, $count) = $_ =~ /^COV\s+(\S+)\s+(\d+)\s+(\d+)/) {
                if ($range eq '[1000<]') {
                    $cov = 1001;
                }
                $self->_set_coverage($cov => $count);
                
                if ($cov > 0) {
                    # sum to get mean coverage, ignoring the >1000 outliers
                    if ($cov <= 1000) {
                        $cov_count += $count;
                        $cov_total += $count * $cov;
                    }
                    
                    # build up the cumulative coverage
                    foreach my $past_cov (1..$cov) {
                        $cum_cov->{$past_cov} += $count;
                    }
                }
            }
            else {
                my ($key, @items) = split(/\t/, $_);
                $self->throw("'$key' sections are not understood! Is this really a bamcheck file?") unless exists $mapping{$key};
                
                my $method = "_push_$key";
                chomp($items[-1]);
                $self->$method(\@items);
            }
        }
        $self->_mean_coverage(sprintf("%0.2f", $cov_total / $cov_count));
        
        if ($saw >= 22) {
            $self->_set_header_parsed();
            return 1;
        }
        
        $self->throw("Unable to parse all SN lines (only saw $saw) - is this a bamcheck file?")
    }
}

1;