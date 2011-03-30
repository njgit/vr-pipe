use VRPipe::Base;

class t::VRPipe::Track extends VRPipe::Persistent {
    has 'trackid' => (is => 'rw',
                      isa => IntSQL[16],
                      traits => ['VRPipe::Persistent::Attributes'],
                      is_auto_increment => 1,
                      is_primary_key => 1);
    
    has 'cd' => (is => 'rw',
                 isa => IntSQL[64],
                 traits => ['VRPipe::Persistent::Attributes']);
    
    has 'title' => (is => 'rw',
                    isa => Varchar[64],
                    traits => ['VRPipe::Persistent::Attributes']);
    
    __PACKAGE__->make_persistent(belongs_to => {cd => 't::VRPipe::CD'});
}

1;