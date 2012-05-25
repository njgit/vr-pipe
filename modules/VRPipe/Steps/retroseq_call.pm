use VRPipe::Base;

class VRPipe::Steps::retroseq_call with VRPipe::StepRole {
    method options_definition {
        return { 
            retroseq_exe => VRPipe::StepOption->get(description => 'full path to retroseq.pl', optional => 1, default_value => 'retroseq.pl'),
            retroseq_ref => VRPipe::StepOption->get(description => '-ref option, genome ref FASTA file'),
            retroseq_filter => VRPipe::StepOption->get(description => '-filter option, tab file with TE type and BED file of reference elements to filter out', optional => 1),
            retroseq_call_options => VRPipe::StepOption->get(description => 'retroseq -call additional options excluding input, output and filter files'),
        };
    }
    method inputs_definition {
        return { 
			bam_files => VRPipe::StepIODefinition->get(type => 'bam',
                         description => 'bam files', 
                         max_files => -1),
			rseq_bed => VRPipe::StepIODefinition->get(type => 'txt',   
                        description => 'retroseq candidate supporting read pairs in BED format', 
                         metadata => {source_bam => 'the bam file analysed by the retroseq -discover'},
                         max_files => -1),
		};
    }
    method body_sub {
        return sub {
            my $self = shift;
            
            my $options = $self->options;
            my $retroseq_exe = $options->{retroseq_exe};
            my $retroseq_ref = $options->{'retroseq_ref'};
            my $retroseq_filter = $options->{'retroseq_filter'};
            my $retroseq_call_options = $options->{'retroseq_call_options'};

            my $req = $self->new_requirements(memory => 500, time => 1);
            
			# put bed file metadata into hash for bam name lookup
			my(%bed_files);
            foreach my $bed ( @{$self->inputs->{rseq_bed}} ) {
                my $source_bam = $bed->metadata->{source_bam};
                my $bed_path = $bed->path->stringify;
				$bed_files{$source_bam}=$bed_path;
            }

            foreach my $bam_file (@{$self->inputs->{bam_files}}) {
                my $bam_path = $bam_file->path;

                my $basename = $bam_file->basename;
                $basename =~ s/\.bam$/.rseq.vcf.PE/;	# Assuming Paired End reads 

				my $rseq_vcf = $self->output_file(output_key => 'rseq_vcf', basename => $basename, type => 'vcf');

				my $output_path = $rseq_vcf->path;
				$output_path =~ s/\.PE$//;	# remove suffix for the -output parameter

				my $cmd = "$retroseq_exe -call -bam $bam_path -input $bed_files{$bam_path} -ref $retroseq_ref";
				$cmd .= " -filter $retroseq_filter" if $retroseq_filter;
				$cmd .= " $retroseq_call_options -output $output_path";

				$self->dispatch_wrapped_cmd('VRPipe::Steps::retroseq_call', 'run_rseq_call', [$cmd, $req, {output_files => [$rseq_vcf]}]);
            }
        };
    }
    method outputs_definition {
        return { rseq_vcf => VRPipe::StepIODefinition->get(type => 'txt',
                                                               description => 'VCF of retroseq TE calls',
                                                               max_files => -1) };
    }
    method post_process_sub {
        return sub { return 1; };
    }
    method description {
        return "Generates a VCF of TE calls from BAM and retroseq discovery output";
    }
    method max_simultaneous {
        return 0; # meaning unlimited
    }
    
    method run_rseq_call (ClassName|Object $self: Str $cmd_line) {

        system($cmd_line) && $self->throw("failed to run [$cmd_line]");
        
        my ($output_path) = $cmd_line =~ /.* -output (\S+)$/;
		$output_path .= '.PE';	# paired end

        my $output_file = VRPipe::File->get(path => $output_path);
        $output_file->update_stats_from_disc;
        
        if ($output_file->lines == 0) {
            $output_file->unlink;
			$self->throw("Output $output_path is empty)");
        }
        else {
            return 1;
        }
    }
    
}

1;