=head1 NAME

VRPipe::Steps::fastqc_quality_report - a step

=head1 DESCRIPTION

*** more documentation to come

=head1 AUTHOR

NJWalker <nw11@sanger.ac.uk>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012 Genome Research Limited.

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

class VRPipe::Steps::fastqc_quality_report with VRPipe::StepRole {
use File::Basename;
    method options_definition {
        return { fastqc_exe => VRPipe::StepOption->get(description => 'path to your fastqc executable', optional => 1, default_value => 'fastqc')}
    
    }
    method inputs_definition {
        return {
                # sequence file - fastq for now
    fastq_files => VRPipe::StepIODefinition->get(type => 'fq', max_files => -1, description => '1 or more fastq files to calculate quality reports for')     
   
        };
    }
    method body_sub {
        return sub {
            my $self = shift;
            my $options = $self->options;
            my $fastqc = $options->{fastqc_exe};
            $self->set_cmd_summary(VRPipe::StepCmdSummary->get(exe => 'fastqc', version => VRPipe::StepCmdSummary->determine_version($fastqc . ' --version', '^FastQC v(.+)$'), summary => 'fastqc --noextract file1 '));
            my $req = $self->new_requirements(memory => 500, time => 1);
            
            foreach my $seq_file  (@{$self->inputs->{fastq_files}}) {
               my ($name) = fileparse( $seq_file->basename, ('.fastq') );
               my $report_file = $self->output_file( output_key => 'fastq_report_files',
                                          basename => $name .'_fastqc.zip',
                                          type => 'bin',
                                          metadata => $seq_file->metadata);
               my $seq_file_path = $seq_file->path;
               my $report_file_dir = $report_file->path->dir; 
               $self->dispatch([qq[$fastqc --noextract $seq_file_path --outdir $report_file_dir ], $req, {output_files => [$report_file] }]);
           }
     };
    }
    method outputs_definition {
        return { fastq_report_files => VRPipe::StepIODefinition->get(type => 'bin', description => 'a zip file containing the fastqc quality report files') };
    }
    method post_process_sub {
        return sub { return 1; };
    }
    method description {
        return "Produces quality report using fastqc";
    }
    method max_simultaneous {
        return 0; # meaning unlimited
    }
}
