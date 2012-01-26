use VRPipe::Base;

class VRPipe::Steps::cram_index extends VRPipe::Steps::cramtools {
    around options_definition {
        return { %{$self->$orig},
                 reference_fasta => VRPipe::StepOption->get(description => 'absolute path to reference fasta file'),
                 cramtools_index_options => VRPipe::StepOption->get(description => 'Options for cramtools index command to index a cram file', optional => 1),
               };
    }
    method inputs_definition {
        return { cram_files => VRPipe::StepIODefinition->get(type => 'cram', max_files => -1, description => '1 or more cram files') };
    }
    method body_sub {
        return sub {
            my $self = shift;
            my $options = $self->options;
            my $cramtools = VRPipe::Utils::cramtools->new(cramtools_path => $options->{cramtools_path}, java_exe => $options->{java_exe});
            my $cramtools_jar = Path::Class::File->new($cramtools->cramtools_path, 'cramtools.jar');
            my $ref = Path::Class::File->new($options->{reference_fasta});
            $self->throw("reference_fasta must be an absolute path") unless $ref->is_absolute;
            
            my $opts = $options->{cramtools_index_options};
            if ($opts =~ /$ref|--input-cram-file|--reference-fasta-file/) {
                $self->throw("cramtools_index_options should not include the reference or input options");
            }
            
            $self->set_cmd_summary(VRPipe::StepCmdSummary->get(exe => 'cramtools', 
                                   version => $cramtools->determine_cramtools_version(),
                                   summary => 'java $jvm_args -jar cramtools.jar index --input-cram-file $cram_file --reference-fasta-file $reference_fasta '.$opts));
            
            my $req = $self->new_requirements(memory => 4000, time => 3);
            my $memory = $req->memory;
            
            foreach my $cram (@{$self->inputs->{cram_files}}) {
                my $cram_index_file = $self->output_file(output_key => 'cram_index_files',
                                                   output_dir => $cram->dir,
                                                   basename => $cram->basename.'crai',
                                                   type => 'cram',
                                                   metadata => $cram->metadata);
                
                my $temp_dir = $options->{tmp_dir} || $cram_index_file->dir;
                my $jvm_args = $cramtools->jvm_args($memory, $temp_dir);
                
                my $this_cmd = $cramtools->java_exe." $jvm_args -jar $cramtools_jar index --input-cram-file ".$cram->path." --reference-fasta-file $ref $opts";
                $self->dispatch_wrapped_cmd('VRPipe::Steps::cram_index', 'cram_index_and_check', [$this_cmd, $req, {output_files => [$cram_index_file]}]); 
            }
        };
    }
    method outputs_definition {
        return { cram_index_files => VRPipe::StepIODefinition->get(type => 'bin', max_files => -1, description => 'a cram index file') };
    }
    method post_process_sub {
        return sub { return 1; };
    }
    method description {
        return "Indexes cram files using cramtools";
    }
    method max_simultaneous {
        return 0; # meaning unlimited
    }
    method cram_index_and_check (ClassName|Object $self: Str $cmd_line) {
        my ($cram_path) = $cmd_line =~ /--input-bam-file (\S+)/;
        $cram_path || $self->throw("cmd_line [$cmd_line] was not constructed as expected");
        my $crai_path = $cram_path.'crai';
        
        my $cram_file = VRPipe::File->get(path => $cram_path);
        my $crai_file = VRPipe::File->get(path => $crai_path);

        $cram_file->disconnect;
        system($cmd_line) && $self->throw("failed to run [$cmd_line]");

        $crai_file->update_stats_from_disc(retries => 3);

        my $correct_magic = [qw(037 213 010 000)];

        if ($crai_file->check_magic($crai_file->path, $correct_magic)) {
            return 1;
        }
        else {
            $crai_file->unlink;
            $self->throw("cmd [$cmd_line] failed because index file $crai_path had the incorrect magic");
        }
    }
}

1;
