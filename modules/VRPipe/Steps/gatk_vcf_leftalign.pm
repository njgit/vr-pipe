=head1 NAME

VRPipe::Steps::gatk_vcf_leftalign - a step

=head1 DESCRIPTION

*** more documentation to come

=head1 AUTHOR

Chris Joyce <cj5@sanger.ac.uk>.

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

#Example generic command for UnifiedGenotyper GATK v1.3
#java -Xmx2g -jar GenomeAnalysisTK.jar \
#   -R ref.fasta \
#   -T LeftAlignVariants \
#   --variant input.vcf \
#   -o output.vcf
 
class VRPipe::Steps::gatk_vcf_leftalign extends VRPipe::Steps::gatk {
	around options_definition {
		return { 
            %{$self->$orig},
			reference_fasta => VRPipe::StepOption->get(description => 'absolute path to reference genome fasta'),
			leftalign_options => VRPipe::StepOption->get(description => 'any addional general GATK options to pass the LeftAligner', optional => 1, default_value => '--phone_home NO_ET'),
	    };
    }

    method inputs_definition {
        return {
        vcf_files => VRPipe::StepIODefinition->get(type => 'vcf', max_files => -1, description => 'input vcf files'),
		};
    }

    method body_sub {
        return sub {
            my $self = shift;
            my $options = $self->options;
			$self->handle_standard_options($options);
            
            my $reference_fasta = $options->{reference_fasta};
            my $leftalign_options = $options->{leftalign_options};
            
            my $req = $self->new_requirements(memory => 1200, time => 1);
            my $jvm_args = $self->jvm_args($req->memory);

            foreach my $vcf (@{$self->inputs->{vcf_files}}) {
			
				my $basename = $vcf->basename;
				$basename =~ s/vcf\.gz/aln.vcf.gz/;
				my $vcf_out = $self->output_file(output_key => 'vcf_files', basename => $basename, type => 'vcf');
				my $input_path = $vcf->path;
				my $output_path = $vcf_out->path;

				my $cmd = $self->java_exe.qq[ $jvm_args -jar ].$self->jar.qq[ -T LeftAlignVariants -R $reference_fasta $leftalign_options --variant $input_path -o $output_path];
                $self->dispatch_wrapped_cmd('VRPipe::Steps::gatk_vcf_leftalign', 'leftaln_vcf', [$cmd, $req, {output_files => [$vcf_out]}]);
			}
        };
    }
    method outputs_definition {
        return { vcf_files => VRPipe::StepIODefinition->get(type => 'vcf', max_files => -1, description => 'output vcf files') };
    }
    method post_process_sub {
        return sub { return 1; };
    }
    method description {
        return "Runs the gatk UnifiedGenotyper indel left-aligner against vcf files";
    }
    method max_simultaneous {
        return 0; # meaning unlimited
    }
    method leftaln_vcf (ClassName|Object $self: Str $cmd_line) {

        my ($input_path, $output_path) = $cmd_line =~ /\-\-variant (\S+) \-o (\S+)$/;

        my $input_file = VRPipe::File->get(path => $input_path);
        my $input_recs = $input_file->num_records;
        $input_file->disconnect;

        system($cmd_line) && $self->throw("failed to run [$cmd_line]");
        
        my $output_file = VRPipe::File->get(path => $output_path);
        $output_file->update_stats_from_disc;
        my $output_recs = $output_file->num_records;
        
        unless ($output_recs == $input_recs) {
            $output_file->unlink;
			$self->throw("Output VCF has different number of data lines from input (input $input_recs, output $output_recs)");
        }
        else {
            return 1;
        }
    }
}

1;
