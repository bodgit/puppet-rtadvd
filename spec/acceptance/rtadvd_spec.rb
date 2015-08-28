require 'spec_helper_acceptance'

describe 'rtadvd' do

  case fact('osfamily')
  when 'OpenBSD'
    conf_file = '/etc/rtadvd.conf'
    interface = 'em1'
    content   = <<-EOS.gsub(/^ +/, '')
      # !!! Managed by Puppet !!!
      #{interface}:\\
      	:raflags#64:
    EOS
    group     = 'wheel'
    service   = 'rtadvd'
    sysctl    = 'net.inet6.ip6.forwarding'
  when 'RedHat'
    conf_file = '/etc/radvd.conf'
    interface = 'ens33'
    content   = <<-EOS.gsub(/^ +/, '')
      # !!! Managed by Puppet !!!
      interface #{interface} {
      	AdvSendAdvert on;
      	AdvManagedFlag off;
      	AdvOtherConfigFlag on;
      	prefix ::/64 {
      		AdvOnLink on;
      		AdvAutonomous on;
      		AdvRouterAddr on;
      	};
      };
    EOS
    group     = 'root'
    service   = 'radvd'
    sysctl    = 'net.ipv6.conf.all.forwarding'
  end

  it 'should work with no errors' do

    pp = <<-EOS
      class { '::rtadvd':
        interfaces => {
          '#{interface}' => {
            'other_configuration' => true,
          },
        },
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe file('/etc/sysctl.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into group }
    its(:content) { should match /^#{sysctl}\s*=\s*1$/ }
  end

  # Badly named type for non-Linux
  describe linux_kernel_parameter(sysctl) do
    its(:value) { should eq 1 }
  end

  describe file(conf_file) do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into group }
    its(:size) { should > 0 }
    its(:content) { should eq content }
  end

  describe command("getcap -a -f #{conf_file}"), :if => fact('osfamily') == 'OpenBSD' do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^#{interface}:(\s+:)?raflags#64:/ }
  end

  describe service(service) do
    it { should be_enabled }
    it { should be_running }
  end
end
