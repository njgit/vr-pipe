use VRPipe::Base;

class VRPipe::Steps::picard extends VRPipe::Steps::java {
    around options_definition {
        return { %{$self->$orig},
                 picard_path => VRPipe::StepOption->get(description => 'path to Picard jar files', optional => 1, default_value => "$ENV{PICARD}"),
                };
    }
    method inputs_definition {
        return { };
    }
    method body_sub {
        return sub { return 1; };
    }
    method outputs_definition {
        return { };
    }
    method post_process_sub {
        return sub { return 1; };
    }
    method description {
        return "Generic step for using Picard";
    }
    method max_simultaneous {
        return 0; # meaning unlimited
    }
}

1;